from machine import Pin, SPI, I2C, RTC, PWM
import time
import network
import urequests as requests
from mfrc522 import MFRC522
from i2c_lcd import I2cLcd
from ssd1306 import SSD1306_I2C
import gc

# ========================================
# KONFIGURASI
# ========================================
WIFI_SSID = "CP"
WIFI_PASSWORD = "12345678"

#API_URL = "http://192.168.137.1/presensi_api/api.php"
API_URL = "http://ur-domain.com/api/api.php"

DEVICE_ID = "CP_PA"

# ========================================
# HARDWARE SETUP
# ========================================
i2c = I2C(0, sda=Pin(19), scl=Pin(23), freq=400000)
LCD_ADDR = 0x27
lcd = I2cLcd(i2c, LCD_ADDR, 2, 16)
oled = SSD1306_I2C(128, 64, i2c)

BTN_START = Pin(14, Pin.IN, Pin.PULL_UP)
BTN_SALAM = Pin(27, Pin.IN, Pin.PULL_UP)
BTN_END = Pin(26, Pin.IN, Pin.PULL_UP)

spi = SPI(2, baudrate=1000000, polarity=0, phase=0,
          sck=Pin(18), mosi=Pin(13), miso=Pin(12))
rfid = MFRC522(spi=spi, gpioRst=15, gpioCs=5)

buzzer = PWM(Pin(25))
buzzer.duty(0)

rtc = RTC()

# ========================================
# VARIABEL GLOBAL
# ========================================
sesi_dimulai = False
guru_salam = False
sesi_akhir = False
waktu_salam = None
id_jadwal_aktif = None
nama_sesi_aktif = ""

# LCD Scrolling
scroll_active = False
scroll_name = ""
scroll_pos = 0
scroll_last = time.ticks_ms()

# OLED Display
current_name = ""
current_status = ""
last_oled_update = time.ticks_ms()

# Debounce button
last_btn_time = {'start': 0, 'salam': 0, 'end': 0}
DEBOUNCE_MS = 200

# Network error handling
wifi_connected = False
network_fail_count = 0
MAX_NETWORK_FAIL = 3

# Mute buzzer
mute_buzzer = False 

# ========================================
# BEEP
# ========================================
def beep(dur=120):
    if mute_buzzer:
        return
    buzzer.freq(4000)
    buzzer.duty(200)
    time.sleep_ms(dur)
    buzzer.duty(0)

def beep_ok():
    beep(200)

def beep_fail():
    beep(100)
    time.sleep_ms(100)
    beep(200)

# ========================================
# LOAD DATA SANTRI DARI CSV
# ========================================
santri_map = {}  # rfid_uid -> nama

def load_santri_csv(filename="santri.csv"):
    global santri_map
    santri_map = {}
    try:
        with open(filename, "r") as f:
            first = True
            for line in f:
                line = line.strip()
                if not line:
                    continue
                if first and line.lower().startswith("rfid_uid"):
                    first = False
                    continue
                first = False

                raw_parts = line.split(",")
                if len(raw_parts) < 2:
                    continue
                uid_raw = raw_parts[0].strip().strip('"').strip("'")
                nama_raw = ",".join(raw_parts[1:]).strip().strip('"').strip("'")

                if uid_raw:
                    santri_map[uid_raw] = nama_raw
        print("✅ Data santri CSV:", len(santri_map), "record")
    except OSError as e:
        print("❌ Gagal baca santri.csv:", e)
    except Exception as e:
        print("❌ Error parsing santri.csv:", e)

# ========================================
# KONEKSI WIFI
# ========================================
def connect_wifi():
    global wifi_connected
    try:
        wlan = network.WLAN(network.STA_IF)

        if wlan.isconnected():
            ip = wlan.ifconfig()[0]
            lcd.clear()
            lcd.putstr("WiFi: Connected")
            lcd.move_to(0, 1)
            lcd.putstr(ip)
            print("✅ WiFi sudah terhubung:", ip)
            time.sleep(2)
            wifi_connected = True
            return True

        if not wlan.active():
            wlan.active(True)
            time.sleep(1)

        lcd.clear()
        lcd.putstr("Connecting WiFi")
        print("Menghubungkan ke:", WIFI_SSID)

        wlan.connect(WIFI_SSID, WIFI_PASSWORD)

        timeout = 20
        while not wlan.isconnected() and timeout > 0:
            lcd.clear()
            lcd.putstr("Connecting...")
            lcd.move_to(0, 1)
            lcd.putstr("Wait: {}s".format(timeout))
            print("Tunggu...", timeout, "s")
            time.sleep(1)
            timeout -= 1

        if wlan.isconnected():
            ip = wlan.ifconfig()[0]
            lcd.clear()
            lcd.putstr("WiFi Connected")
            lcd.move_to(0, 1)
            lcd.putstr(ip)
            print("✅ WiFi TERHUBUNG:", ip)
            time.sleep(2)
            wifi_connected = True
            return True
        else:
            lcd.clear()
            lcd.putstr("WiFi Timeout")
            print("❌ WiFi Timeout")
            time.sleep(2)
            wifi_connected = False
            return False

    except Exception as e:
        lcd.clear()
        lcd.putstr("WiFi Error")
        lcd.move_to(0, 1)
        lcd.putstr(str(e)[:16])
        print("❌ WiFi Error:", e)
        time.sleep(2)
        wifi_connected = False
        return False

# ========================================
# API FUNCTIONS
# ========================================
def api_request(endpoint, data=None):
    """Kirim request ke API dengan timeout pendek dan auto offline."""
    global network_fail_count, wifi_connected
    try:
        if not wifi_connected:
            return {"success": False, "message": "WiFi not connected"}

        url = "{}?action={}".format(API_URL, endpoint)
        print("🌐 API Request:", url)
        if data:
            print("📤 Data:", data)

        gc.collect()
        if data:
            response = requests.post(url, json=data, timeout=3)
        else:
            response = requests.get(url, timeout=3)

        result = response.json()
        response.close()
        print("✅ Response:", result)
        network_fail_count = 0  
        return result

    except OSError as e:
        error_msg = str(e)
        print("❌ OSError:", error_msg)
        network_fail_count += 1
        if network_fail_count >= MAX_NETWORK_FAIL:
            print("⚠️ Banyak error network, masuk MODE OFFLINE")
            wifi_connected = False
        return {"success": False, "message": "Network Error: " + error_msg}
    except Exception as e:
        print("❌ Exception:", e)
        return {"success": False, "message": str(e)}

# ========================================
# LOGIKA SESI
# ========================================
def deteksi_sesi():
    t = time.localtime()
    jam = t[3]
    menit = t[4]
    waktu_menit = jam * 60 + menit

    if 0 <= waktu_menit <= 330:
        return "Subuh"
    elif 331 <= waktu_menit <= 570:
        return "Pagi"
    elif 571 <= waktu_menit <= 1064:
        return "Sore"
    elif 1065 <= waktu_menit <= 1139:
        return "Maghrib"
    elif 1140 <= waktu_menit <= 1900:
        return "Malam"
    else:
        return None

def mulai_sesi():
    global id_jadwal_aktif, nama_sesi_aktif

    nama_sesi = deteksi_sesi()
    if not nama_sesi:
        lcd.clear()
        lcd.putstr("Bukan Waktu")
        lcd.move_to(0, 1)
        lcd.putstr("Sesi!")
        time.sleep(2)
        return False

    if not wifi_connected:
        lcd.clear()
        lcd.putstr("Mode Offline")
        lcd.move_to(0, 1)
        lcd.putstr("Tidak Tersimpan")
        print("⚠️ Mode Offline - data lokal saja")
        time.sleep(2)
        id_jadwal_aktif = -1
        nama_sesi_aktif = nama_sesi
        return True

    data = {"device_id": DEVICE_ID, "nama_sesi": nama_sesi}
    result = api_request("start_session", data)

    if result.get("success"):
        id_jadwal_aktif = int(result.get("id_jadwal", -1))
        nama_sesi_aktif = nama_sesi
        lcd.clear()
        lcd.putstr("Sesi {}".format(nama_sesi))
        lcd.move_to(0, 1)
        lcd.putstr("Dimulai")
        print("Sesi", nama_sesi, "ID:", id_jadwal_aktif)
        time.sleep(2)
        return True
    else:
        lcd.clear()
        lcd.putstr("Error Start")
        lcd.move_to(0, 1)
        lcd.putstr(result.get("message", "")[:16])
        print("Error start_session:", result.get("message"))
        time.sleep(2)
        return False

def catat_salam():
    global waktu_salam

    if not id_jadwal_aktif:
        return False

    if id_jadwal_aktif == -1:
        lcd.clear()
        lcd.putstr("Guru Salam")
        lcd.move_to(0, 1)
        lcd.putstr("(Offline)")
        print("Guru salam (offline)")
        time.sleep(1)
        return True

    if not wifi_connected:
        lcd.clear()
        lcd.putstr("No WiFi")
        time.sleep(1)
        return False

    data = {"id_jadwal": int(id_jadwal_aktif)}
    result = api_request("mark_salam", data)

    if result.get("success"):
        waktu_salam = time.localtime()
        lcd.clear()
        lcd.putstr("Pengajian")
        lcd.move_to(0, 1)
        lcd.putstr("Telah dimulai")
        print("Guru salam tercatat")
        time.sleep(1)
        return True
    else:
        lcd.clear()
        lcd.putstr("Error Salam")
        time.sleep(1)
        return False

def akhiri_sesi():
    global id_jadwal_aktif, nama_sesi_aktif

    if not id_jadwal_aktif:
        return False

    if id_jadwal_aktif == -1 or not wifi_connected:
        lcd.clear()
        lcd.putstr("Sesi {}".format(nama_sesi_aktif))
        lcd.move_to(0, 1)
        lcd.putstr("Selesai (Off)")
        print("Sesi", nama_sesi_aktif, "selesai (offline)")
        time.sleep(2)
        id_jadwal_aktif = None
        nama_sesi_aktif = ""
        return True

    data = {"id_jadwal": int(id_jadwal_aktif)}
    result = api_request("end_session", data)

    if result.get("success"):
        lcd.clear()
        lcd.putstr("Sesi {}".format(nama_sesi_aktif))
        lcd.move_to(0, 1)
        lcd.putstr("Selesai")
        print("Sesi", nama_sesi_aktif, "selesai")
        time.sleep(2)
        id_jadwal_aktif = None
        nama_sesi_aktif = ""
        return True
    else:
        lcd.clear()
        lcd.putstr("Error End")
        time.sleep(1)
        return False

# ========================================
# PRESENSI (NAMA DARI CSV)
# ========================================
def catat_presensi(rfid_uid):
    global guru_salam, waktu_salam

    if not id_jadwal_aktif:
        return {"ok": False, "type": "NO_SESSION"}

    if id_jadwal_aktif == -1 or not wifi_connected:
        lcd.clear()
        lcd.putstr("Mode Offline")
        lcd.move_to(0, 1)
        lcd.putstr("Tidak Tersimpan")
        print("Mode offline - data tidak tersimpan")
        time.sleep(1)
        return {"ok": False, "type": "OFFLINE"}

    status = "H"
    poin = 0

    if guru_salam and waktu_salam:
        t = time.localtime()
        sekarang = t[3] * 60 + t[4]

        t2 = waktu_salam
        salam_menit = t2[3] * 60 + t2[4]
        selisih = sekarang - salam_menit

        if selisih <= 5:
            status = "T1"; poin = 1
        elif selisih <= 15:
            status = "T2"; poin = 2
        else:
            status = "T3"; poin = 3

    data = {
        "id_jadwal": int(id_jadwal_aktif),
        "rfid_uid": rfid_uid,
        "status_manual": status,
        "poin_manual": poin
    }

    result = api_request("record_attendance", data)

    if not result:
        return {"ok": False, "type": "NETWORK", "message": "No response"}

    if result.get("success"):
        nama_api = result.get("nama", "")
        if nama_api:
            nama = nama_api
        else:
            nama = santri_map.get(rfid_uid, "Tidak Dikenal")

        return {"ok": True, "nama": nama, "status": status, "poin": poin}

    msg = result.get("message", "")
    nama = santri_map.get(rfid_uid, "Tidak Dikenal")

    if "Santri tidak ditemukan" in msg:
        err_type = "NOT_FOUND"
    elif "Sudah presensi" in msg:
        err_type = "ALREADY"
    else:
        err_type = "API_ERROR"

    return {
        "ok": False,
        "type": err_type,
        "nama": nama,
        "message": msg
    }

# ========================================
# LCD SCROLLING
# ========================================
def lcd_show_name(name):
    global scroll_active, scroll_name, scroll_pos
    lcd.clear()
    lcd.move_to(0, 0)
    lcd.putstr("Scan:")

    if len(name) <= 16:
        lcd.move_to(0, 1)
        lcd.putstr(name)
        scroll_active = False
    else:
        scroll_active = True
        scroll_name = name
        scroll_pos = 0
        lcd.move_to(0, 1)
        lcd.putstr(name[:16])

def lcd_scroll_handler():
    global scroll_pos, scroll_last, scroll_active

    if not scroll_active:
        return

    now = time.ticks_ms()
    if time.ticks_diff(now, scroll_last) > 80:
        scroll_last = now
        scroll_pos += 1

        if scroll_pos > len(scroll_name) - 16:
            scroll_active = False
            return

        segment = scroll_name[scroll_pos:scroll_pos+16]
        lcd.move_to(0, 1)
        lcd.putstr(segment)

# ========================================
# OLED DISPLAY + BOOT
# ========================================
font8x8 = {
    "H": [0b01000010,0b01000010,0b01000010,0b01111110,0b01000010,0b01000010,0b01000010,0],
    "T": [0b01111110,0b00011000,0b00011000,0b00011000,0b00011000,0b00011000,0b00011000,0],
    "1": [0b00011000,0b00111000,0b00011000,0b00011000,0b00011000,0b00011000,0b01111110,0],
    "2": [0b00111100,0b01000010,0b00000010,0b00011100,0b00100000,0b01000000,0b01111110,0],
    "3": [0b00111100,0b01000010,0b00000010,0b00011100,0b00000010,0b01000010,0b00111100,0],
}

def oled_draw_center(text, y):
    x = (128 - len(text) * 8) // 2
    oled.text(text, x, y)

def oled_xp_loading(pos):
    bar_x = 14
    bar_y = 32
    bar_w = 100
    bar_h = 10

    oled.rect(bar_x, bar_y, bar_w, bar_h, 1)

    block_w = 10
    gap = 4
    for i in range(3):
        x = bar_x + 2 + pos + i * (block_w + gap)
        if x < bar_x + bar_w - block_w - 2:
            oled.fill_rect(x, bar_y + 2, block_w, bar_h - 4, 1)

def oled_boot_frame(pos):
    oled.fill(0)
    oled_draw_center("Presensi", 4)
    oled_draw_center("PPM Jogja", 17)
    oled_xp_loading(pos)
    oled_draw_center("Cepatan Putra", 52)
    oled.show()

def draw_big(ch, x, y):
    if ch not in font8x8:
        return
    pattern = font8x8[ch]
    for r in range(8):
        line = pattern[r]
        for c in range(8):
            if line & (1 << (7 - c)):
                oled.pixel(x + c*2, y + r*2, 1)
                oled.pixel(x + c*2 + 1, y + r*2, 1)
                oled.pixel(x + c*2, y + r*2 + 1, 1)
                oled.pixel(x + c*2 + 1, y + r*2 + 1, 1)

def oled_update():
    global last_oled_update
    now = time.ticks_ms()

    if time.ticks_diff(now, last_oled_update) < 200:
        return

    last_oled_update = now
    oled.fill(0)

    if guru_salam and waktu_salam:
        t_now = time.localtime()
        t1 = waktu_salam

        # konversi ke detik dari tengah malam
        now_sec = t_now[3]*3600 + t_now[4]*60 + t_now[5]
        salam_sec = t1[3]*3600 + t1[4]*60 + t1[5]
        elapsed = now_sec - salam_sec
        if elapsed < 0:
            elapsed = 0

        h = elapsed // 3600
        m = (elapsed % 3600) // 60
        s = elapsed % 60

        if h == 0:
            teks_waktu = "%02d:%02d" % (m, s)
        else:
            teks_waktu = "%02d:%02d:%02d" % (h, m, s)
    else:
        teks_waktu = "--:--"

    x_waktu = (128 - len(teks_waktu)*8) // 2
    oled.text(teks_waktu, x_waktu, 0)

    if current_status != "":
        bw = 16
        total_w = len(current_status) * bw
        x = (128 - total_w) // 2
        cur = x
        for ch in current_status:
            draw_big(ch, cur, 16)
            cur += bw

    if current_name != "":
        if len(current_name) <= 16:
            x = (128 - len(current_name)*8) // 2
            oled.text(current_name, x, 48)
        else:
            b1 = current_name[:16]
            b2 = current_name[16:32]
            oled.text(b1, (128 - 16*8)//2, 44)
            oled.text(b2, (128 - len(b2)*8)//2, 54)

    oled.show()

# ========================================
# BUTTON HANDLER
# ========================================
def check_button(btn, btn_name):
    global last_btn_time
    now = time.ticks_ms()

    if not btn.value():
        if time.ticks_diff(now, last_btn_time[btn_name]) > DEBOUNCE_MS:
            last_btn_time[btn_name] = now
            beep_ok()
            return True
    return False

# ========================================
# MAIN PROGRAM
# ========================================
def main():
    global sesi_dimulai, guru_salam, sesi_akhir
    global current_name, current_status

    load_santri_csv()

    lcd.clear()
    lcd.putstr("   PPM Jogja  ")
    lcd.move_to(0, 1)
    lcd.putstr(" Cepatan Putra")
    time.sleep(1)

    connect_wifi()

    if not wifi_connected:
        lcd.clear()
        lcd.putstr("Mode Offline")
        lcd.move_to(0, 1)
        lcd.putstr("Tanpa WiFi")
        print("⚠️ Mode Offline")
        time.sleep(2)

    lcd.clear()
    lcd.putstr("Untuk mulai sesi")
    lcd.move_to(0, 1)
    lcd.putstr("Tekan START")
    print("✅ Sistem siap. Tekan START.")

    pos = -40
    while not sesi_dimulai:
        oled_boot_frame(pos)
        pos += 2
        if pos > 100:
            pos = -40

        if check_button(BTN_START, 'start'):
            if mulai_sesi():
                sesi_dimulai = True
                guru_salam = False
                sesi_akhir = False
                lcd.clear()
                lcd.putstr("Siap Scan")
                break

        time.sleep(0.04)

    while True:
        if check_button(BTN_SALAM, 'salam') and sesi_dimulai and not guru_salam:
            if catat_salam():
                guru_salam = True

        if check_button(BTN_END, 'end') and sesi_dimulai:
            if akhiri_sesi():
                sesi_dimulai = False
                guru_salam = False
                sesi_akhir = True
                current_name = ""
                current_status = ""
                lcd.clear()
                lcd.putstr("Tekan START")

        lcd_scroll_handler()
        oled_update()

        if not sesi_dimulai or sesi_akhir:
            continue

        stat, _ = rfid.request(rfid.REQIDL)

        if stat == rfid.OK:
            for _ in range(3):
                stat2, uid = rfid.anticoll()
                if stat2 == rfid.OK:
                    break
                time.sleep_ms(10)

            if stat2 == rfid.OK:
                uid_str = " ".join("%02X" % b for b in uid[:4])
                print("RFID Scan:", uid_str)

                result = catat_presensi(uid_str)

                if result and result.get("ok"):
                    beep_ok()
                    current_name = result["nama"]
                    current_status = result["status"]
                    lcd_show_name(result["nama"])
                    print("Presensi:", result["nama"], "-", result["status"], "(Poin:", result["poin"], ")")

                elif result:
                    beep_fail()
                    rtype = result.get("type")
                    nama = result.get("nama", "Tidak Dikenal")
                    msg = result.get("message", "")

                    if rtype == "ALREADY":
                        current_name = nama
                        current_status = ""
                        lcd.clear()
                        lcd.putstr("Sudah presensi")
                        lcd.move_to(0, 1)
                        lcd.putstr(nama[:16])
                        print("Sudah presensi:", nama)

                    elif rtype == "NOT_FOUND":
                        current_name = "Tidak Terdaftar"
                        current_status = ""
                        lcd.clear()
                        lcd.putstr("Kartu Tidak")
                        lcd.move_to(0, 1)
                        lcd.putstr("Terdaftar")
                        print("Santri tidak ditemukan:", uid_str)

                    elif rtype == "NETWORK":
                        current_name = ""
                        current_status = ""
                        lcd.clear()
                        lcd.putstr("Error Jaringan")
                        lcd.move_to(0, 1)
                        lcd.putstr("Coba lagi")
                        print("Network error:", msg)

                    else:
                        current_name = ""
                        current_status = ""
                        lcd.clear()
                        lcd.putstr("Gagal Presensi")
                        lcd.move_to(0, 1)
                        lcd.putstr(msg[:16])
                        print("API error:", msg)

                else:
                    beep_fail()
                    current_name = ""
                    current_status = ""
                    lcd.clear()
                    lcd.putstr("Error Jaringan")
                    lcd.move_to(0, 1)
                    lcd.putstr("Coba lagi")
                    print("No response at all")


                time.sleep(0.4)

# ========================================
# RUN
# ========================================
try:
    main()
except KeyboardInterrupt:
    print("\nProgram dihentikan")
    lcd.clear()
    lcd.putstr("Program Stop")
except Exception as e:
    print("Error:", e)
    lcd.clear()
    lcd.putstr("Error!")
    lcd.move_to(0, 1)
    lcd.putstr(str(e)[:16])




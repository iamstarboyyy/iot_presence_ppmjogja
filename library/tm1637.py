from tm1637 import TM1637
from time import sleep

# Pin Lolin32 Lite (sesuai default kamu)
CLK = 19   # pin Clock
DIO = 23   # pin Data

display = TM1637(clk=CLK, dio=DIO)
display.brightness = 0 # kecerahan (0–7)

# Tampilkan angka awal
display.number(1234)
sleep(2)

# Hitung naik
for i in range(0, 10000):
    display.number(i)
    sleep(0.05)

<?php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

// Konfigurasi Database
$host = 'localhost';
$dbname = 'ur_db_name';
$username = 'ur_db_uname';
$password = 'ur_db_pass';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
    exit;
}

// Ambil action dari query string
$action = isset($_GET['action']) ? $_GET['action'] : '';

// Ambil data JSON dari request body
$input = json_decode(file_get_contents('php://input'), true);

// Router
switch($action) {
    case 'login':
        login($pdo, $input);
        break;
    case 'logout':
        logout($pdo, $input);
        break;
    case 'checksession':
        checkSession($pdo, $input);
        break;
    case 'startsession':
        startSession($pdo, $input);
        break;
    case 'marksalam':
        markSalam($pdo, $input);
        break;
    case 'endsession':
        endSession($pdo, $input);
        break;
    case 'recordattendance':
        recordAttendance($pdo, $input);
        break;
    case 'getattendancetoday':
        getAttendanceToday($pdo);
        break;
    case 'getattendancebysession':
        getAttendanceBySession($pdo, $input);
        break;
    case 'getrekappoin':
        getRekapPoin($pdo);
        break;
    case 'getrekapkehadiran':
        getRekapKehadiran($pdo, $_GET);
        break;
    case 'getkelas':
        getKelas($pdo);
        break;
    case 'updatepresensi':
        updatePresensi($pdo, $input);
        break;
    case 'markalpha':
        markAlpha($pdo, $input);
        break;
    case 'getsesi':
        getSesi($pdo);
        break;
    case 'getexportdata':
        getExportData($pdo, $_GET);
        break;
    case 'getsantripresensidetail':
        getSantriPresensiDetail($pdo, $_GET);
        break;
    case 'updatestatuspresensi':
        updateStatusPresensi($pdo, $input);
        break;
    case 'addmanualpresensi':
        addManualPresensi($pdo, $input);
        break;
    case 'getsessionstoday':
        getSessionsToday($pdo);
        break;
    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
        break;
}

// ==================== FUNGSI LOGIN ====================
function login($pdo, $data) {
    try {
        $username = $data['username'] ?? '';
        $password = $data['password'] ?? '';
        
        if (empty($username) || empty($password)) {
            echo json_encode(['success' => false, 'message' => 'Username dan password harus diisi']);
            return;
        }
        
        // Cari admin
        $stmt = $pdo->prepare("SELECT * FROM admin WHERE username = ? AND status = 'aktif'");
        $stmt->execute([$username]);
        $admin = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$admin) {
            echo json_encode(['success' => false, 'message' => 'Username tidak ditemukan']);
            return;
        }
        
        // Verifikasi password (MD5 - di production gunakan password_verify dengan bcrypt)
        if (md5($password) != $admin['password']) {
            echo json_encode(['success' => false, 'message' => 'Password salah']);
            return;
        }
        
        // Generate token
        $token = bin2hex(random_bytes(32));
        $expired = date('Y-m-d H:i:s', strtotime('+24 hours'));
        
        // Simpan sesi login
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
        
        $stmt = $pdo->prepare("INSERT INTO sesi_login (id_admin, token, ip_address, user_agent, expired_pada) VALUES (?, ?, ?, ?, ?)");
        $stmt->execute([$admin['id_admin'], $token, $ip, $user_agent, $expired]);
        
        // Update terakhir login
        $stmt = $pdo->prepare("UPDATE admin SET terakhir_login = NOW() WHERE id_admin = ?");
        $stmt->execute([$admin['id_admin']]);
        
        // Prepare response data
        $response_data = [
            'id_admin' => $admin['id_admin'],
            'username' => $admin['username'],
            'nama_lengkap' => $admin['nama_lengkap'],
            'level' => $admin['level'],
            'email' => $admin['email']
        ];
        
        // BARU: Jika level santri, ambil data santri
        if ($admin['level'] == 'santri' && $admin['id_santri']) {
            $stmt = $pdo->prepare("SELECT s.*, k.nama_kelas FROM santri s LEFT JOIN kelas k ON s.id_kelas = k.id_kelas WHERE s.id_santri = ?");
            $stmt->execute([$admin['id_santri']]);
            $santri = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($santri) {
                $response_data['id_santri'] = $santri['id_santri'];
                $response_data['nama_kelas'] = $santri['nama_kelas'];
            }
        }
        
        echo json_encode([
            'success' => true,
            'message' => 'Login berhasil',
            'token' => $token,
            'admin' => $response_data
        ]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI LOGOUT ====================
function logout($pdo, $data) {
    try {
        $token = $data['token'] ?? '';
        
        if (empty($token)) {
            echo json_encode(['success' => false, 'message' => 'Token tidak valid']);
            return;
        }
        
        // Update sesi
        $stmt = $pdo->prepare("UPDATE sesi_login SET logout_pada = NOW(), status = 'logout' WHERE token = ? AND status = 'aktif'");
        $stmt->execute([$token]);
        
        echo json_encode(['success' => true, 'message' => 'Logout berhasil']);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI CHECK SESSION ====================
function checkSession($pdo, $data) {
    try {
        $token = $data['token'] ?? '';
        
        if (empty($token)) {
            echo json_encode(['success' => false, 'message' => 'Token tidak valid']);
            return;
        }
        
        // Cek sesi
        $stmt = $pdo->prepare("SELECT sl.*, a.username, a.nama_lengkap, a.level, a.email 
                               FROM sesi_login sl 
                               JOIN admin a ON sl.id_admin = a.id_admin 
                               WHERE sl.token = ? AND sl.status = 'aktif' AND sl.expired_pada > NOW()");
        $stmt->execute([$token]);
        $sesi = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$sesi) {
            echo json_encode(['success' => false, 'message' => 'Sesi tidak valid atau sudah expired']);
            return;
        }
        
        echo json_encode([
            'success' => true,
            'admin' => [
                'username' => $sesi['username'],
                'nama_lengkap' => $sesi['nama_lengkap'],
                'level' => $sesi['level'],
                'email' => $sesi['email']
            ]
        ]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI START SESSION ====================
function startSession($pdo, $data) {
    try {
        $device_id = $data['device_id'] ?? '';
        $nama_sesi = $data['nama_sesi'] ?? '';
        
        // Ambil ID device
        $stmt = $pdo->prepare("SELECT id_device FROM device WHERE kode_device = ?");
        $stmt->execute([$device_id]);
        $device = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$device) {
            echo json_encode(['success' => false, 'message' => 'Device tidak ditemukan']);
            return;
        }
        
        // Ambil ID sesi
        $stmt = $pdo->prepare("SELECT id_sesi FROM sesi WHERE nama_sesi = ?");
        $stmt->execute([$nama_sesi]);
        $sesi = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$sesi) {
            echo json_encode(['success' => false, 'message' => 'Sesi tidak ditemukan']);
            return;
        }
        
        // Insert jadwal sesi
        $stmt = $pdo->prepare("INSERT INTO jadwal_sesi (id_sesi, id_device, tanggal, waktu_mulai_aktual, status_sesi) VALUES (?, ?, CURDATE(), NOW(), 'berlangsung')");
        $stmt->execute([$sesi['id_sesi'], $device['id_device']]);
        
        $id_jadwal = $pdo->lastInsertId();
        
        echo json_encode(['success' => true, 'message' => 'Sesi dimulai', 'id_jadwal' => $id_jadwal]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI MARK SALAM ====================
function markSalam($pdo, $data) {
    try {
        $id_jadwal = $data['id_jadwal'] ?? 0;
        
        $stmt = $pdo->prepare("UPDATE jadwal_sesi SET waktu_salam = NOW() WHERE id_jadwal = ? AND status_sesi = 'berlangsung'");
        $stmt->execute([$id_jadwal]);
        
        echo json_encode(['success' => true, 'message' => 'Salam tercatat']);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI END SESSION ====================
function endSession($pdo, $data) {
    try {
        $id_jadwal = $data['id_jadwal'] ?? 0;
        
        $stmt = $pdo->prepare("UPDATE jadwal_sesi SET waktu_selesai = NOW(), status_sesi = 'selesai' WHERE id_jadwal = ? AND status_sesi = 'berlangsung'");
        $stmt->execute([$id_jadwal]);
        
        // Auto mark alpha untuk santri yang belum presensi
        autoMarkAlpha($pdo, $id_jadwal);
        
        echo json_encode(['success' => true, 'message' => 'Sesi selesai']);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI AUTO MARK ALPHA PER KELAS DEVICE ====================
function autoMarkAlpha($pdo, $id_jadwal) {
    try {
        // Ambil id_kelas dari device yang digunakan di jadwal ini
        $stmt = $pdo->prepare("SELECT d.id_kelas FROM jadwal_sesi js JOIN device d ON js.id_device = d.id_device WHERE js.id_jadwal = ?");
        $stmt->execute([$id_jadwal]);
        $jadwal_info = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$jadwal_info) return 0;
        
        $id_kelas = $jadwal_info['id_kelas'];
        
        // Ambil HANYA santri aktif dari kelas ini
        $stmt = $pdo->prepare("SELECT id_santri FROM santri WHERE status = 'aktif' AND id_kelas = ?");
        $stmt->execute([$id_kelas]);
        $all_santri_kelas = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        // Ambil santri dari kelas ini yang sudah presensi di sesi ini
        $stmt = $pdo->prepare("SELECT p.id_santri FROM presensi p JOIN santri s ON p.id_santri = s.id_santri WHERE p.id_jadwal = ? AND s.id_kelas = ?");
        $stmt->execute([$id_jadwal, $id_kelas]);
        $present_santri = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        // Santri yang belum presensi = Alpha
        $alpha_santri = array_diff($all_santri_kelas, $present_santri);
        
        $count = 0;
        foreach ($alpha_santri as $id_santri) {
            $stmt = $pdo->prepare("INSERT INTO presensi (id_jadwal, id_santri, waktu_scan, status_kehadiran, poin_keterlambatan) VALUES (?, ?, NOW(), 'A', 0)");
            $stmt->execute([$id_jadwal, $id_santri]);
            $count++;
        }
        
        return $count;
        
    } catch (PDOException $e) {
        return 0;
    }
}

// ==================== FUNGSI RECORD ATTENDANCE ====================
function recordAttendance($pdo, $data) {
    try {
        $id_jadwal = $data['id_jadwal'] ?? 0;
        $rfid_uid = $data['rfid_uid'] ?? '';
        
        // Ambil status dan poin yang sudah dihitung di ESP32
        $status_manual = $data['status_manual'] ?? null;
        $poin_manual = $data['poin_manual'] ?? null;
        
        // Ambil data santri
        $stmt = $pdo->prepare("SELECT id_santri, nama_lengkap FROM santri WHERE rfid_uid = ? AND status = 'aktif'");
        $stmt->execute([$rfid_uid]);
        $santri = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$santri) {
            echo json_encode(['success' => false, 'message' => 'Santri tidak ditemukan']);
            return;
        }
        
        // Cek apakah sudah presensi di sesi ini
        $stmt = $pdo->prepare("SELECT id_presensi FROM presensi WHERE id_jadwal = ? AND id_santri = ?");
        $stmt->execute([$id_jadwal, $santri['id_santri']]);
        if ($stmt->fetch()) {
            echo json_encode(['success' => false, 'message' => 'Sudah presensi']);
            return;
        }
        
        // PRIORITAS 1: Pakai status & poin dari ESP32
        if ($status_manual != null && $poin_manual != null) {
            // ESP32 sudah hitung, langsung pakai
            $status = $status_manual;
            $poin = $poin_manual;
            
            echo json_encode([
                'success' => true,
                'message' => 'Presensi tercatat dari ESP32',
                'nama' => $santri['nama_lengkap'],
                'status' => $status,
                'poin' => $poin
            ]);
        } else {
            // PRIORITAS 2: Hitung di server (fallback)
            // Ambil waktu salam
            $stmt = $pdo->prepare("SELECT waktu_salam FROM jadwal_sesi WHERE id_jadwal = ?");
            $stmt->execute([$id_jadwal]);
            $jadwal = $stmt->fetch(PDO::FETCH_ASSOC);
            $waktu_salam = $jadwal['waktu_salam'];
            
            // Hitung status kehadiran
            $status = 'H';
            $poin = 0;
            
            if ($waktu_salam) {
                $waktu_scan = new DateTime();
                $waktu_salam_dt = new DateTime($waktu_salam);
                $diff_menit = ($waktu_scan->getTimestamp() - $waktu_salam_dt->getTimestamp()) / 60;
                
                if ($diff_menit > 0) {
                    if ($diff_menit <= 5) {
                        $status = 'T1';
                        $poin = 1;
                    } elseif ($diff_menit <= 15) {
                        $status = 'T2';
                        $poin = 2;
                    } else {
                        $status = 'T3';
                        $poin = 3;
                    }
                }
            }
            
            echo json_encode([
                'success' => true,
                'message' => 'Presensi tercatat dari server',
                'nama' => $santri['nama_lengkap'],
                'status' => $status,
                'poin' => $poin
            ]);
        }
        
        // Insert presensi ke database
        $stmt = $pdo->prepare("INSERT INTO presensi (id_jadwal, id_santri, waktu_scan, status_kehadiran, poin_keterlambatan) VALUES (?, ?, NOW(), ?, ?)");
        $stmt->execute([$id_jadwal, $santri['id_santri'], $status, $poin]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI GET ATTENDANCE TODAY dengan filter ====================
function getAttendanceToday($pdo) {
    try {
        $kelas = $_GET['kelas'] ?? '';
        $sesi = $_GET['sesi'] ?? '';
        
        $where = ["DATE(p.waktu_scan) = CURDATE()"];
        $params = [];
        
        if (!empty($kelas)) {
            $where[] = "k.id_kelas = ?";
            $params[] = $kelas;
        }
        
        if (!empty($sesi)) {
            $where[] = "ses.id_sesi = ?";
            $params[] = $sesi;
        }
        
        $where_sql = implode(' AND ', $where);
        
        $sql = "SELECT 
                    p.id_presensi,
                    s.nama_lengkap,
                    s.rfid_uid,
                    k.nama_kelas,
                    ses.nama_sesi,
                    js.tanggal,
                    js.waktu_mulai_aktual,
                    js.waktu_salam,
                    p.waktu_scan,
                    p.status_kehadiran,
                    pk.nama_status,
                    d.kode_device,
                    d.lokasi
                FROM presensi p
                JOIN santri s ON p.id_santri = s.id_santri
                JOIN kelas k ON s.id_kelas = k.id_kelas
                JOIN jadwal_sesi js ON p.id_jadwal = js.id_jadwal
                JOIN sesi ses ON js.id_sesi = ses.id_sesi
                JOIN device d ON js.id_device = d.id_device
                JOIN poin_keterlambatan pk ON p.status_kehadiran = pk.kode_status
                WHERE $where_sql
                ORDER BY p.waktu_scan DESC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $data]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI GET ATTENDANCE BY SESSION ====================
function getAttendanceBySession($pdo, $data) {
    try {
        $id_jadwal = $data['id_jadwal'] ?? 0;
        
        $stmt = $pdo->prepare("SELECT p.*, s.nama_lengkap, s.rfid_uid, k.nama_kelas, pk.nama_status 
                               FROM presensi p 
                               JOIN santri s ON p.id_santri = s.id_santri 
                               JOIN kelas k ON s.id_kelas = k.id_kelas 
                               JOIN poin_keterlambatan pk ON p.status_kehadiran = pk.kode_status 
                               WHERE p.id_jadwal = ? 
                               ORDER BY p.waktu_scan DESC");
        $stmt->execute([$id_jadwal]);
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $data]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI GET REKAP KEHADIRAN dengan filter ====================
function getRekapKehadiran($pdo, $params) {
    try {
        $periode = $params['periode'] ?? 'semua';
        $id_kelas = $params['kelas'] ?? '';
        
        // BARU: Filter berdasarkan level user
        $level = $params['level'] ?? '';
        $id_santri = $params['id_santri'] ?? '';
        
        // Build WHERE clause berdasarkan periode
        $where_date = '';
        if ($periode == 'minggu') {
            $where_date = " AND DATE(p.waktu_scan) >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)";
        } elseif ($periode == 'bulan') {
            $where_date = " AND DATE(p.waktu_scan) >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)";
        }
        
        // Build WHERE clause untuk kelas
        $where_kelas = '';
        $params_bind = [];
        
        if (!empty($id_kelas)) {
            $where_kelas = " AND s.id_kelas = ?";
            $params_bind[] = $id_kelas;
        }
        
        // BARU: Filter untuk level santri (hanya tampilkan data sendiri)
        $where_santri = '';
        if ($level == 'santri' && !empty($id_santri)) {
            $where_santri = " AND s.id_santri = ?";
            $params_bind[] = $id_santri;
        }
        
        $sql = "SELECT 
                    s.id_santri,
                    s.nama_lengkap,
                    s.rfid_uid,
                    k.nama_kelas,
                    COUNT(p.id_presensi) as total_kehadiran,
                    SUM(CASE WHEN p.status_kehadiran = 'H' THEN 1 ELSE 0 END) as hadir_tepat,
                    SUM(CASE WHEN p.status_kehadiran = 'T1' THEN 1 ELSE 0 END) as terlambat_t1,
                    SUM(CASE WHEN p.status_kehadiran = 'T2' THEN 1 ELSE 0 END) as terlambat_t2,
                    SUM(CASE WHEN p.status_kehadiran = 'T3' THEN 1 ELSE 0 END) as terlambat_t3,
                    SUM(CASE WHEN p.status_kehadiran = 'A' THEN 1 ELSE 0 END) as alpha,
                    SUM(CASE WHEN p.status_kehadiran = 'I' THEN 1 ELSE 0 END) as izin
                FROM santri s
                LEFT JOIN kelas k ON s.id_kelas = k.id_kelas
                LEFT JOIN presensi p ON s.id_santri = p.id_santri $where_date
                WHERE s.status = 'aktif' $where_kelas $where_santri
                GROUP BY s.id_santri, s.nama_lengkap, s.rfid_uid, k.nama_kelas
                ORDER BY s.nama_lengkap ASC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params_bind);
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $data]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI GET KELAS ====================
function getKelas($pdo) {
    try {
        $stmt = $pdo->query("SELECT id_kelas, nama_kelas, kode_kelas FROM kelas ORDER BY nama_kelas");
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $data]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI UPDATE PRESENSI (Edit Status) ====================
function updatePresensi($pdo, $data) {
    try {
        $id_presensi = $data['id_presensi'] ?? 0;
        $status = $data['status'] ?? '';
        $id_admin = $data['id_admin'] ?? null;
        $level = $data['level'] ?? '';
        
        // BARU: Cek hak akses - hanya superadmin yang bisa edit
        if ($level != 'superadmin') {
            echo json_encode(['success' => false, 'message' => 'Anda tidak memiliki hak akses untuk mengedit presensi']);
            return;
        }
        
        // Validasi status
        $valid_status = ['H', 'T1', 'T2', 'T3', 'A', 'I'];
        if (!in_array($status, $valid_status)) {
            echo json_encode(['success' => false, 'message' => 'Status tidak valid']);
            return;
        }
        
        // Hitung poin berdasarkan status
        $poin = 0;
        if ($status == 'T1') $poin = 1;
        elseif ($status == 'T2') $poin = 2;
        elseif ($status == 'T3') $poin = 3;
        
        // Update presensi
        $stmt = $pdo->prepare("UPDATE presensi SET status_kehadiran = ?, poin_keterlambatan = ? WHERE id_presensi = ?");
        $stmt->execute([$status, $poin, $id_presensi]);
        
        echo json_encode(['success' => true, 'message' => 'Presensi berhasil diupdate']);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI MARK ALPHA Manual - Per Kelas ====================
function markAlpha($pdo, $data) {
    try {
        $id_jadwal = $data['id_jadwal'] ?? 0;
        $id_admin = $data['id_admin'] ?? null;
        
        // Ambil id_kelas dari device
        $stmt = $pdo->prepare("SELECT d.id_kelas FROM jadwal_sesi js JOIN device d ON js.id_device = d.id_device WHERE js.id_jadwal = ?");
        $stmt->execute([$id_jadwal]);
        $jadwal_info = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$jadwal_info) {
            echo json_encode(['success' => false, 'message' => 'Jadwal tidak ditemukan']);
            return;
        }
        
        $id_kelas = $jadwal_info['id_kelas'];
        
        // Ambil HANYA santri aktif dari kelas ini
        $stmt = $pdo->prepare("SELECT id_santri FROM santri WHERE status = 'aktif' AND id_kelas = ?");
        $stmt->execute([$id_kelas]);
        $all_santri_kelas = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        // Ambil santri yang sudah presensi di sesi ini
        $stmt = $pdo->prepare("SELECT id_santri FROM presensi WHERE id_jadwal = ?");
        $stmt->execute([$id_jadwal]);
        $present_santri = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        // Santri yang belum presensi = Alpha
        $alpha_santri = array_diff($all_santri_kelas, $present_santri);
        
        $count = 0;
        foreach ($alpha_santri as $id_santri) {
            $stmt = $pdo->prepare("INSERT INTO presensi (id_jadwal, id_santri, waktu_scan, status_kehadiran, poin_keterlambatan) VALUES (?, ?, NOW(), 'A', 0)");
            $stmt->execute([$id_jadwal, $id_santri]);
            $count++;
        }
        
        echo json_encode(['success' => true, 'message' => "$count santri dari kelas ini ditandai alpha", 'count' => $count]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI GET REKAP POIN ====================
function getRekapPoin($pdo) {
    try {
        $stmt = $pdo->query("SELECT * FROM v_rekap_poin_santri ORDER BY total_poin DESC");
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $data]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI GET SESI ====================
function getSesi($pdo) {
    try {
        $stmt = $pdo->query("SELECT id_sesi, nama_sesi FROM sesi ORDER BY id_sesi");
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $data]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI GET EXPORT DATA ====================
function getExportData($pdo, $params) {
    try {
        $periode = $params['periode'] ?? 'semua';
        $id_kelas = $params['kelas'] ?? '';
        
        // BARU: Filter level akses
        $level = $params['level'] ?? '';
        $id_santri = $params['id_santri'] ?? '';
        
        // Level santri tidak bisa export
        if ($level == 'santri') {
            echo json_encode(['success' => false, 'message' => 'Anda tidak memiliki hak akses untuk export data']);
            return;
        }
        
        // Build WHERE clause
        $where_date = '';
        if ($periode == 'minggu') {
            $where_date = " AND DATE(p.waktu_scan) >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)";
        } elseif ($periode == 'bulan') {
            $where_date = " AND DATE(p.waktu_scan) >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)";
        }
        
        $where_kelas = '';
        $params_bind = [];
        if (!empty($id_kelas)) {
            $where_kelas = " AND s.id_kelas = ?";
            $params_bind[] = $id_kelas;
        }
        
        // Get all santri dengan summary
        $sql = "SELECT 
                    s.id_santri,
                    s.nama_lengkap,
                    k.nama_kelas,
                    COUNT(DISTINCT p.id_jadwal) as total_kehadiran,
                    SUM(CASE WHEN p.status_kehadiran = 'A' THEN 1 ELSE 0 END) as total_alpha,
                    SUM(CASE WHEN p.status_kehadiran = 'I' THEN 1 ELSE 0 END) as total_izin,
                    SUM(CASE WHEN p.status_kehadiran = 'T1' THEN 1 ELSE 0 END) as total_t1,
                    SUM(CASE WHEN p.status_kehadiran = 'T2' THEN 1 ELSE 0 END) as total_t2,
                    SUM(CASE WHEN p.status_kehadiran = 'T3' THEN 1 ELSE 0 END) as total_t3
                FROM santri s
                LEFT JOIN kelas k ON s.id_kelas = k.id_kelas
                LEFT JOIN presensi p ON s.id_santri = p.id_santri $where_date
                WHERE s.status = 'aktif' $where_kelas
                GROUP BY s.id_santri, s.nama_lengkap, k.nama_kelas
                ORDER BY s.nama_lengkap ASC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params_bind);
        $santri_data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Get detail presensi per sesi-tanggal untuk setiap santri
        $detail_sql = "SELECT 
                        p.id_santri,
                        js.id_jadwal,
                        ses.nama_sesi,
                        DATE(js.tanggal) as tanggal,
                        p.status_kehadiran,
                        CONCAT(ses.nama_sesi, ' - ', DATE_FORMAT(js.tanggal, '%d/%m')) as sesi_tanggal
                    FROM presensi p
                    JOIN jadwal_sesi js ON p.id_jadwal = js.id_jadwal
                    JOIN sesi ses ON js.id_sesi = ses.id_sesi
                    WHERE 1=1 $where_date
                    ORDER BY js.tanggal ASC, ses.id_sesi ASC";
        
        $stmt = $pdo->prepare($detail_sql);
        $stmt->execute();
        $detail_data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Get unique sesi-tanggal
        $sesi_tanggal = [];
        foreach ($detail_data as $row) {
            if (!in_array($row['sesi_tanggal'], $sesi_tanggal)) {
                $sesi_tanggal[] = $row['sesi_tanggal'];
            }
        }
        
        // Organize data
        $result = [
            'santri' => $santri_data,
            'detail' => $detail_data,
            'sesi_tanggal' => $sesi_tanggal
        ];
        
        echo json_encode(['success' => true, 'data' => $result]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI GET SANTRI PRESENSI DETAIL ====================
function getSantriPresensiDetail($pdo, $params) {
    try {
        $id_santri = $params['id_santri'] ?? 0;
        $periode = $params['periode'] ?? 'semua';
        
        // Build WHERE clause berdasarkan periode
        $where_date = '';
        $params_bind = [$id_santri];
        
        if ($periode == 'minggu') {
            $where_date = " AND DATE(js.tanggal) >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)";
        } elseif ($periode == 'bulan') {
            $where_date = " AND DATE(js.tanggal) >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)";
        }
        
        // Get all sesi yang sudah berjalan dalam periode
        $sql_sesi = "SELECT 
                        js.id_jadwal,
                        ses.nama_sesi,
                        DATE_FORMAT(js.tanggal, '%d/%m/%Y') as tanggal_format,
                        js.tanggal,
                        js.waktu_mulai_aktual,
                        js.waktu_salam,
                        js.waktu_selesai,
                        js.status_sesi,
                        d.kode_device,
                        k.nama_kelas,
                        p.id_presensi,
                        p.status_kehadiran,
                        p.waktu_scan,
                        pk.nama_status
                    FROM jadwal_sesi js
                    JOIN sesi ses ON js.id_sesi = ses.id_sesi
                    JOIN device d ON js.id_device = d.id_device
                    JOIN kelas k ON d.id_kelas = k.id_kelas
                    LEFT JOIN presensi p ON js.id_jadwal = p.id_jadwal AND p.id_santri = ?
                    LEFT JOIN poin_keterlambatan pk ON p.status_kehadiran = pk.kode_status
                    WHERE 1=1 $where_date
                    ORDER BY js.tanggal DESC, ses.id_sesi DESC";
        
        $stmt = $pdo->prepare($sql_sesi);
        $stmt->execute($params_bind);
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $data]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI UPDATE STATUS PRESENSI ====================
function updateStatusPresensi($pdo, $data) {
    try {
        $id_presensi = $data['id_presensi'] ?? 0;
        $status = $data['status'] ?? '';
        $id_admin = $data['id_admin'] ?? null;
        $level = $data['level'] ?? '';
        
        // BARU: Cek hak akses - hanya superadmin yang bisa edit
        if ($level != 'superadmin') {
            echo json_encode(['success' => false, 'message' => 'Anda tidak memiliki hak akses untuk mengedit presensi']);
            return;
        }
        
        // Validasi status
        $valid_status = ['H', 'T1', 'T2', 'T3', 'A', 'I'];
        if (!in_array($status, $valid_status)) {
            echo json_encode(['success' => false, 'message' => 'Status tidak valid']);
            return;
        }
        
        // Hitung poin berdasarkan status
        $poin = 0;
        if ($status == 'T1') $poin = 1;
        elseif ($status == 'T2') $poin = 2;
        elseif ($status == 'T3') $poin = 3;
        
        // Update presensi
        $stmt = $pdo->prepare("UPDATE presensi SET status_kehadiran = ?, poin_keterlambatan = ? WHERE id_presensi = ?");
        $stmt->execute([$status, $poin, $id_presensi]);
        
        echo json_encode(['success' => true, 'message' => 'Status presensi berhasil diupdate']);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI ADD MANUAL PRESENSI ====================
function addManualPresensi($pdo, $data) {
    try {
        $id_jadwal = $data['id_jadwal'] ?? 0;
        $id_santri = $data['id_santri'] ?? 0;
        $status = $data['status'] ?? 'A';
        $id_admin = $data['id_admin'] ?? null;
        $level = $data['level'] ?? '';
        
        // BARU: Cek hak akses - hanya superadmin yang bisa tambah/edit
        if ($level != 'superadmin') {
            echo json_encode(['success' => false, 'message' => 'Anda tidak memiliki hak akses untuk menambah presensi']);
            return;
        }
        
        $valid_status = ['H','T1','T2','T3','A','I'];
        if (!in_array($status, $valid_status)) {
            echo json_encode(['success' => false, 'message' => 'Status tidak valid']);
            return;
        }
        
        // Cek apakah sudah ada presensi
        $stmt = $pdo->prepare("SELECT id_presensi FROM presensi WHERE id_jadwal = ? AND id_santri = ?");
        $stmt->execute([$id_jadwal, $id_santri]);
        $existing = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Hitung poin
        $poin = 0;
        if ($status == 'T1') $poin = 1;
        elseif ($status == 'T2') $poin = 2;
        elseif ($status == 'T3') $poin = 3;
        
        if ($existing) {
            // SUDAH ADA - UPDATE saja
            $stmt = $pdo->prepare("UPDATE presensi SET status_kehadiran = ?, poin_keterlambatan = ? WHERE id_presensi = ?");
            $stmt->execute([$status, $poin, $existing['id_presensi']]);
            echo json_encode(['success' => true, 'message' => 'Presensi sudah ada, status berhasil diupdate']);
        } else {
            // BELUM ADA - INSERT baru
            $stmt = $pdo->prepare("INSERT INTO presensi (id_jadwal, id_santri, waktu_scan, status_kehadiran, poin_keterlambatan) VALUES (?, ?, NOW(), ?, ?)");
            $stmt->execute([$id_jadwal, $id_santri, $status, $poin]);
            echo json_encode(['success' => true, 'message' => 'Presensi berhasil ditambahkan']);
        }
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

// ==================== FUNGSI GET SESSIONS TODAY ====================
function getSessionsToday($pdo) {
    try {
        $stmt = $pdo->query("SELECT 
                                js.id_jadwal,
                                ses.nama_sesi,
                                d.kode_device,
                                k.nama_kelas,
                                js.waktu_mulai_aktual,
                                js.waktu_salam,
                                js.waktu_selesai,
                                js.status_sesi,
                                COUNT(p.id_presensi) as jumlah_hadir
                            FROM jadwal_sesi js
                            JOIN sesi ses ON js.id_sesi = ses.id_sesi
                            JOIN device d ON js.id_device = d.id_device
                            JOIN kelas k ON d.id_kelas = k.id_kelas
                            LEFT JOIN presensi p ON js.id_jadwal = p.id_jadwal
                            WHERE DATE(js.tanggal) = CURDATE()
                            GROUP BY js.id_jadwal
                            ORDER BY js.waktu_mulai_aktual DESC");
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $data]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

?>


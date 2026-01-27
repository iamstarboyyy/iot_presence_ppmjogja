-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jan 27, 2026 at 04:49 PM
-- Server version: 10.11.15-MariaDB-cll-lve
-- PHP Version: 8.4.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `albf9957_ujicoba`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id_admin` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `level` enum('superadmin','operator','santri') DEFAULT 'operator',
  `id_santri` int(11) DEFAULT NULL,
  `status` enum('aktif','nonaktif') DEFAULT 'aktif',
  `foto` varchar(255) DEFAULT NULL,
  `terakhir_login` datetime DEFAULT NULL,
  `dibuat_pada` datetime DEFAULT current_timestamp(),
  `diupdate_pada` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id_admin`, `username`, `password`, `nama_lengkap`, `email`, `level`, `id_santri`, `status`, `foto`, `terakhir_login`, `dibuat_pada`, `diupdate_pada`) VALUES
(1, 'admin', '0192023a7bbd73250516f069df18b500', 'Administrator', 'admin@presensi.com', 'superadmin', NULL, 'aktif', NULL, '2026-01-27 16:34:20', '2025-12-11 09:35:42', '2026-01-27 16:34:20'),
(2, 'operator1', '2407bd807d6ca01d1bcd766c730cec9a', 'Operator Satu', 'operator1@presensi.com', 'operator', NULL, 'aktif', NULL, '2026-01-27 14:34:52', '2025-12-11 09:35:42', '2026-01-27 14:34:52'),
(3, 'ustadz', '53cd2b194fbd074a44853153d0ec00e9', 'Ustadz Pengajar', 'ustadz@presensi.com', 'operator', NULL, 'aktif', NULL, '2026-01-13 12:19:57', '2025-12-11 09:35:42', '2026-01-27 13:34:11'),
(4, 'satria', '235e8cbdc61f694d398a9e54a1b8e438', 'Muhammad Satria Firdaus', 'satria@ppmjogja.com', 'santri', 2, 'aktif', NULL, '2026-01-27 14:42:41', '2026-01-27 13:35:38', '2026-01-27 14:42:41'),
(5, 'aga', 'f26fa0f469e73b7ebd2f4d29a974c996', 'Aga Maulana', 'aga@ppmjogja.com', 'santri', 7, 'aktif', NULL, '2026-01-27 16:32:35', '2026-01-27 16:32:13', '2026-01-27 16:32:35');

-- --------------------------------------------------------

--
-- Table structure for table `device`
--

CREATE TABLE `device` (
  `id_device` int(11) NOT NULL,
  `kode_device` varchar(10) NOT NULL,
  `id_kelas` int(11) NOT NULL,
  `lokasi` varchar(100) DEFAULT NULL,
  `status` enum('aktif','nonaktif') DEFAULT 'aktif'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `device`
--

INSERT INTO `device` (`id_device`, `kode_device`, `id_kelas`, `lokasi`, `status`) VALUES
(1, 'LB_PA', 3, 'Lambatan Putra', 'aktif'),
(2, 'CP_PA', 6, 'Cepatan Putra', 'aktif');

-- --------------------------------------------------------

--
-- Table structure for table `jadwal_sesi`
--

CREATE TABLE `jadwal_sesi` (
  `id_jadwal` int(11) NOT NULL,
  `id_sesi` int(11) NOT NULL,
  `id_device` int(11) NOT NULL,
  `tanggal` date NOT NULL,
  `waktu_mulai_aktual` datetime NOT NULL,
  `waktu_salam` datetime DEFAULT NULL,
  `waktu_selesai` datetime DEFAULT NULL,
  `status_sesi` enum('berlangsung','selesai') DEFAULT 'berlangsung'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jadwal_sesi`
--

INSERT INTO `jadwal_sesi` (`id_jadwal`, `id_sesi`, `id_device`, `tanggal`, `waktu_mulai_aktual`, `waktu_salam`, `waktu_selesai`, `status_sesi`) VALUES
(45, 2, 2, '2026-01-16', '2026-01-16 06:08:01', NULL, '2026-01-16 06:10:49', 'selesai'),
(48, 5, 2, '2026-01-16', '2026-01-16 20:38:03', '2026-01-16 20:43:37', NULL, 'berlangsung'),
(49, 5, 2, '2026-01-16', '2026-01-16 20:43:11', '2026-01-16 20:48:07', NULL, 'berlangsung'),
(50, 5, 2, '2026-01-16', '2026-01-16 20:50:02', '2026-01-16 20:51:00', NULL, 'berlangsung'),
(51, 5, 2, '2026-01-16', '2026-01-16 21:54:56', NULL, '2026-01-16 21:55:05', 'selesai'),
(52, 1, 2, '2026-01-16', '2026-01-16 21:56:34', NULL, '2026-01-16 21:56:50', 'selesai'),
(53, 1, 2, '2026-01-16', '2026-01-16 22:00:36', NULL, NULL, 'berlangsung'),
(54, 1, 2, '2026-01-16', '2026-01-16 22:00:42', '2026-01-16 22:02:12', '2026-01-16 22:10:58', 'selesai'),
(55, 5, 2, '2026-01-16', '2026-01-16 22:27:43', '2026-01-16 22:29:35', '2026-01-16 22:30:14', 'selesai'),
(56, 1, 2, '2026-01-16', '2026-01-16 22:30:55', NULL, '2026-01-16 22:31:29', 'selesai'),
(57, 1, 2, '2026-01-17', '2026-01-17 07:05:52', '2026-01-17 07:06:11', '2026-01-17 07:06:33', 'selesai'),
(58, 1, 2, '2026-01-18', '2026-01-18 23:33:42', '2026-01-18 23:34:15', '2026-01-18 23:34:58', 'selesai'),
(59, 1, 2, '2026-01-25', '2026-01-25 21:23:47', NULL, '2026-01-25 21:25:07', 'selesai'),
(60, 1, 2, '2026-01-25', '2026-01-25 22:20:31', '2026-01-25 22:21:37', '2026-01-25 22:23:31', 'selesai');

-- --------------------------------------------------------

--
-- Table structure for table `kelas`
--

CREATE TABLE `kelas` (
  `id_kelas` int(11) NOT NULL,
  `nama_kelas` varchar(50) NOT NULL,
  `kode_kelas` varchar(10) NOT NULL,
  `keterangan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kelas`
--

INSERT INTO `kelas` (`id_kelas`, `nama_kelas`, `kode_kelas`, `keterangan`) VALUES
(1, 'Lambatan Putri ', 'LB_PI', 'Kelas Lambatan Putri '),
(2, 'Lambatan Sidobali', 'LB_SB', 'Kelas Lambatan Sidobali'),
(3, 'Lambatan Putra', 'LB_PA', 'Kelas Lambatan Putra'),
(4, 'Cepatan Putri ', 'CP_PI', 'Kelas Cepatan Putri'),
(5, 'Cepatan Sidobali', 'CP_SB', 'Kelas Cepatan Sidobali'),
(6, 'Cepatan Putra', 'CP_PA', 'Kelas Cepatan Putra'),
(7, 'Pra Saringan Putri ', 'PA_PI', 'Kelas Pra Saringan Putri'),
(8, 'Pra Saringan Sidobali', 'PA_SB', 'Kelas Pra Saringan Sidobali'),
(9, 'Pra Saringan Putra', 'PA_PA', 'Kelas Pra Saringan Putra');

-- --------------------------------------------------------

--
-- Table structure for table `log_sistem`
--

CREATE TABLE `log_sistem` (
  `id_log` int(11) NOT NULL,
  `id_device` int(11) DEFAULT NULL,
  `id_admin` int(11) DEFAULT NULL,
  `waktu` datetime DEFAULT current_timestamp(),
  `tipe_log` enum('info','warning','error') DEFAULT 'info',
  `pesan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `poin_keterlambatan`
--

CREATE TABLE `poin_keterlambatan` (
  `id_poin` int(11) NOT NULL,
  `kode_status` varchar(5) NOT NULL,
  `nama_status` varchar(50) NOT NULL,
  `poin` int(11) NOT NULL,
  `menit_min` int(11) DEFAULT NULL,
  `menit_max` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `poin_keterlambatan`
--

INSERT INTO `poin_keterlambatan` (`id_poin`, `kode_status`, `nama_status`, `poin`, `menit_min`, `menit_max`) VALUES
(1, 'H', 'Hadir', 0, NULL, NULL),
(2, 'T1', 'Terlambat 0-5 menit', 1, 0, 5),
(3, 'T2', 'Terlambat 5-15 menit', 2, 5, 15),
(4, 'T3', 'Terlambat >15 menit', 3, 15, NULL),
(5, 'A', 'Alpha', 0, NULL, NULL),
(6, 'I', 'Izin', 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `presensi`
--

CREATE TABLE `presensi` (
  `id_presensi` int(11) NOT NULL,
  `id_jadwal` int(11) NOT NULL,
  `id_santri` int(11) NOT NULL,
  `waktu_scan` datetime NOT NULL,
  `status_kehadiran` enum('H','T1','T2','T3','A','I') NOT NULL,
  `poin_keterlambatan` int(11) DEFAULT 0,
  `keterangan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `presensi`
--

INSERT INTO `presensi` (`id_presensi`, `id_jadwal`, `id_santri`, `waktu_scan`, `status_kehadiran`, `poin_keterlambatan`, `keterangan`) VALUES
(117, 43, 9, '2026-01-16 05:10:20', 'H', 0, NULL),
(118, 43, 7, '2026-01-16 05:11:03', 'H', 0, NULL),
(119, 43, 8, '2026-01-16 05:11:43', 'H', 0, NULL),
(120, 43, 3, '2026-01-16 05:12:05', 'H', 0, NULL),
(121, 43, 4, '2026-01-16 05:12:28', 'H', 0, NULL),
(122, 43, 10, '2026-01-16 05:12:55', 'H', 0, NULL),
(123, 43, 5, '2026-01-16 05:13:27', 'T1', 1, NULL),
(124, 43, 2, '2026-01-16 05:14:15', 'T1', 1, NULL),
(125, 43, 1, '2026-01-16 05:26:23', 'T2', 2, NULL),
(126, 43, 6, '2026-01-16 05:31:28', 'T3', 3, NULL),
(127, 45, 2, '2026-01-16 06:08:20', 'H', 0, NULL),
(128, 45, 5, '2026-01-16 06:08:34', 'H', 0, NULL),
(129, 45, 6, '2026-01-16 06:09:54', 'H', 0, NULL),
(130, 45, 1, '2026-01-16 06:10:49', 'A', 0, NULL),
(131, 45, 3, '2026-01-16 06:10:49', 'A', 0, NULL),
(132, 45, 4, '2026-01-16 06:10:49', 'A', 0, NULL),
(133, 45, 7, '2026-01-16 06:10:49', 'I', 0, NULL),
(134, 45, 8, '2026-01-16 06:10:49', 'A', 0, NULL),
(135, 45, 9, '2026-01-16 06:10:49', 'A', 0, NULL),
(136, 45, 10, '2026-01-16 06:10:49', 'A', 0, NULL),
(147, 48, 1, '2026-01-16 20:39:54', 'H', 0, NULL),
(148, 48, 6, '2026-01-16 20:40:15', 'H', 0, NULL),
(149, 48, 9, '2026-01-16 20:40:52', 'H', 0, NULL),
(150, 49, 6, '2026-01-16 20:44:07', 'H', 0, NULL),
(151, 49, 9, '2026-01-16 20:45:26', 'H', 0, NULL),
(152, 49, 1, '2026-01-16 20:46:04', 'H', 0, NULL),
(153, 49, 7, '2026-01-16 20:46:28', 'H', 0, NULL),
(154, 49, 2, '2026-01-16 20:47:13', 'H', 0, NULL),
(155, 49, 5, '2026-01-16 20:49:04', 'T1', 1, NULL),
(156, 50, 5, '2026-01-16 20:50:54', 'T1', 1, NULL),
(157, 50, 8, '2026-01-16 20:51:15', 'T1', 1, NULL),
(158, 50, 3, '2026-01-16 20:56:43', 'T2', 2, NULL),
(159, 50, 10, '2026-01-16 20:57:20', 'T2', 2, NULL),
(160, 51, 1, '2026-01-16 21:55:05', 'A', 0, NULL),
(161, 51, 2, '2026-01-16 21:55:05', 'A', 0, NULL),
(162, 51, 3, '2026-01-16 21:55:05', 'A', 0, NULL),
(163, 51, 4, '2026-01-16 21:55:05', 'A', 0, NULL),
(164, 51, 5, '2026-01-16 21:55:05', 'A', 0, NULL),
(165, 51, 6, '2026-01-16 21:55:05', 'A', 0, NULL),
(166, 51, 7, '2026-01-16 21:55:05', 'A', 0, NULL),
(167, 51, 8, '2026-01-16 21:55:05', 'A', 0, NULL),
(168, 51, 9, '2026-01-16 21:55:05', 'A', 0, NULL),
(169, 51, 10, '2026-01-16 21:55:05', 'A', 0, NULL),
(170, 52, 1, '2026-01-16 21:56:50', 'A', 0, NULL),
(171, 52, 2, '2026-01-16 21:56:50', 'A', 0, NULL),
(172, 52, 3, '2026-01-16 21:56:50', 'A', 0, NULL),
(173, 52, 4, '2026-01-16 21:56:50', 'A', 0, NULL),
(174, 52, 5, '2026-01-16 21:56:50', 'A', 0, NULL),
(175, 52, 6, '2026-01-16 21:56:50', 'A', 0, NULL),
(176, 52, 7, '2026-01-16 21:56:50', 'A', 0, NULL),
(177, 52, 8, '2026-01-16 21:56:50', 'A', 0, NULL),
(178, 52, 9, '2026-01-16 21:56:50', 'A', 0, NULL),
(179, 52, 10, '2026-01-16 21:56:50', 'A', 0, NULL),
(180, 54, 1, '2026-01-16 22:10:58', 'A', 0, NULL),
(181, 54, 2, '2026-01-16 22:10:58', 'A', 0, NULL),
(182, 54, 3, '2026-01-16 22:10:58', 'A', 0, NULL),
(183, 54, 4, '2026-01-16 22:10:58', 'A', 0, NULL),
(184, 54, 5, '2026-01-16 22:10:58', 'A', 0, NULL),
(185, 54, 6, '2026-01-16 22:10:58', 'A', 0, NULL),
(186, 54, 7, '2026-01-16 22:10:58', 'A', 0, NULL),
(187, 54, 8, '2026-01-16 22:10:58', 'A', 0, NULL),
(188, 54, 9, '2026-01-16 22:10:58', 'A', 0, NULL),
(189, 54, 10, '2026-01-16 22:10:58', 'A', 0, NULL),
(190, 55, 1, '2026-01-16 22:30:14', 'A', 0, NULL),
(191, 55, 2, '2026-01-16 22:30:14', 'A', 0, NULL),
(192, 55, 3, '2026-01-16 22:30:14', 'A', 0, NULL),
(193, 55, 4, '2026-01-16 22:30:14', 'A', 0, NULL),
(194, 55, 5, '2026-01-16 22:30:14', 'A', 0, NULL),
(195, 55, 6, '2026-01-16 22:30:14', 'A', 0, NULL),
(196, 55, 7, '2026-01-16 22:30:14', 'A', 0, NULL),
(197, 55, 8, '2026-01-16 22:30:14', 'A', 0, NULL),
(198, 55, 9, '2026-01-16 22:30:14', 'A', 0, NULL),
(199, 55, 10, '2026-01-16 22:30:14', 'A', 0, NULL),
(200, 56, 3, '2026-01-16 22:31:08', 'H', 0, NULL),
(201, 56, 1, '2026-01-16 22:31:20', 'H', 0, NULL),
(202, 56, 2, '2026-01-16 22:31:29', 'A', 0, NULL),
(203, 56, 4, '2026-01-16 22:31:29', 'A', 0, NULL),
(204, 56, 5, '2026-01-16 22:31:29', 'A', 0, NULL),
(205, 56, 6, '2026-01-16 22:31:29', 'A', 0, NULL),
(206, 56, 7, '2026-01-16 22:31:29', 'A', 0, NULL),
(207, 56, 8, '2026-01-16 22:31:29', 'A', 0, NULL),
(208, 56, 9, '2026-01-16 22:31:29', 'A', 0, NULL),
(209, 56, 10, '2026-01-16 22:31:29', 'A', 0, NULL),
(210, 57, 7, '2026-01-17 07:05:59', 'H', 0, NULL),
(211, 57, 2, '2026-01-17 07:06:23', 'T1', 1, NULL),
(212, 57, 1, '2026-01-17 07:06:33', 'A', 0, NULL),
(213, 57, 3, '2026-01-17 07:06:33', 'A', 0, NULL),
(214, 57, 4, '2026-01-17 07:06:33', 'A', 0, NULL),
(215, 57, 5, '2026-01-17 07:06:33', 'A', 0, NULL),
(216, 57, 6, '2026-01-17 07:06:33', 'A', 0, NULL),
(217, 57, 8, '2026-01-17 07:06:33', 'A', 0, NULL),
(218, 57, 9, '2026-01-17 07:06:33', 'A', 0, NULL),
(219, 57, 10, '2026-01-17 07:06:33', 'A', 0, NULL),
(220, 58, 1, '2026-01-18 23:33:57', 'H', 0, NULL),
(221, 58, 3, '2026-01-18 23:34:27', 'T1', 1, NULL),
(222, 58, 6, '2026-01-18 23:34:44', 'T1', 1, NULL),
(223, 58, 2, '2026-01-18 23:34:58', 'A', 0, NULL),
(224, 58, 4, '2026-01-18 23:34:58', 'A', 0, NULL),
(225, 58, 5, '2026-01-18 23:34:58', 'A', 0, NULL),
(226, 58, 7, '2026-01-18 23:34:58', 'A', 0, NULL),
(227, 58, 8, '2026-01-18 23:34:58', 'A', 0, NULL),
(228, 58, 9, '2026-01-18 23:34:58', 'A', 0, NULL),
(229, 58, 10, '2026-01-18 23:34:58', 'A', 0, NULL),
(230, 59, 7, '2026-01-25 21:24:07', 'H', 0, NULL),
(231, 59, 1, '2026-01-25 21:25:07', 'A', 0, NULL),
(232, 59, 2, '2026-01-25 21:25:07', 'A', 0, NULL),
(233, 59, 3, '2026-01-25 21:25:07', 'A', 0, NULL),
(234, 59, 4, '2026-01-25 21:25:07', 'A', 0, NULL),
(235, 59, 5, '2026-01-25 21:25:07', 'A', 0, NULL),
(236, 59, 6, '2026-01-25 21:25:07', 'A', 0, NULL),
(237, 59, 8, '2026-01-25 21:25:07', 'A', 0, NULL),
(238, 59, 9, '2026-01-25 21:25:07', 'A', 0, NULL),
(239, 59, 10, '2026-01-25 21:25:07', 'A', 0, NULL),
(240, 60, 2, '2026-01-25 22:20:45', 'H', 0, NULL),
(241, 60, 3, '2026-01-25 22:22:04', 'T1', 1, NULL),
(242, 60, 1, '2026-01-25 22:23:31', 'A', 0, NULL),
(243, 60, 4, '2026-01-25 22:23:31', 'A', 0, NULL),
(244, 60, 5, '2026-01-25 22:23:31', 'A', 0, NULL),
(245, 60, 6, '2026-01-25 22:23:31', 'A', 0, NULL),
(246, 60, 7, '2026-01-25 22:23:31', 'A', 0, NULL),
(247, 60, 8, '2026-01-25 22:23:31', 'A', 0, NULL),
(248, 60, 9, '2026-01-25 22:23:31', 'A', 0, NULL),
(249, 60, 10, '2026-01-25 22:23:31', 'A', 0, NULL),
(250, 53, 7, '2026-01-27 15:35:49', 'T2', 2, NULL),
(251, 50, 7, '2026-01-27 15:36:00', 'T1', 1, NULL),
(252, 48, 7, '2026-01-27 15:36:12', 'T2', 2, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `santri`
--

CREATE TABLE `santri` (
  `id_santri` int(11) NOT NULL,
  `rfid_uid` varchar(20) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `id_kelas` int(11) NOT NULL,
  `status` enum('aktif','nonaktif') DEFAULT 'aktif',
  `tanggal_daftar` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `santri`
--

INSERT INTO `santri` (`id_santri`, `rfid_uid`, `nama_lengkap`, `id_kelas`, `status`, `tanggal_daftar`) VALUES
(1, '15 73 01 41', 'Farid Cahyadi', 6, 'aktif', '2024-01-15'),
(2, '75 62 C4 40', 'Muhammad Satria Firdaus', 6, 'aktif', '2024-01-15'),
(3, '45 8A C3 40', 'Finan Muflih Ismail', 6, 'aktif', '2024-01-15'),
(4, 'C5 76 C5 40', 'Juha Mikail Aksan', 6, 'aktif', '2024-01-15'),
(5, '95 96 C2 40', 'Muhamad Affan Arramadhan', 6, 'aktif', '2024-01-15'),
(6, '95 76 FE 40', 'Halim Wibisono', 6, 'aktif', '2024-01-15'),
(7, '85 64 03 41', 'Aga Maulana', 6, 'aktif', '2024-01-15'),
(8, 'D5 E1 DA 40', 'Aldy Ferdiansyah', 6, 'aktif', '2024-01-15'),
(9, 'F5 DD C1 40', 'Aris Panca Irawan', 6, 'aktif', '2024-01-15'),
(10, '15 86 C0 40', 'Winas Hardi Hafidin', 6, 'aktif', '2024-01-15');

-- --------------------------------------------------------

--
-- Table structure for table `sesi`
--

CREATE TABLE `sesi` (
  `id_sesi` int(11) NOT NULL,
  `nama_sesi` enum('Subuh','Pagi','Sore','Maghrib','Malam') NOT NULL,
  `waktu_mulai` time NOT NULL,
  `waktu_selesai` time NOT NULL,
  `durasi_toleransi` int(11) DEFAULT 0 COMMENT 'dalam menit'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sesi`
--

INSERT INTO `sesi` (`id_sesi`, `nama_sesi`, `waktu_mulai`, `waktu_selesai`, `durasi_toleransi`) VALUES
(1, 'Subuh', '04:30:00', '05:30:00', 5),
(2, 'Pagi', '08:30:00', '09:30:00', 5),
(3, 'Sore', '15:00:00', '16:00:00', 5),
(4, 'Maghrib', '17:45:00', '18:30:00', 5),
(5, 'Malam', '19:00:00', '19:45:00', 5);

-- --------------------------------------------------------

--
-- Table structure for table `sesi_login`
--

CREATE TABLE `sesi_login` (
  `id_session` int(11) NOT NULL COMMENT 'Primary key unik untuk setiap session',
  `id_sesi` int(11) DEFAULT NULL COMMENT 'Reference ke tabel sesi (opsional)',
  `id_admin` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `login_pada` datetime DEFAULT current_timestamp(),
  `logout_pada` datetime DEFAULT NULL,
  `expired_pada` datetime DEFAULT NULL,
  `status` enum('aktif','expired','logout') DEFAULT 'aktif'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sesi_login`
--

INSERT INTO `sesi_login` (`id_session`, `id_sesi`, `id_admin`, `token`, `ip_address`, `user_agent`, `login_pada`, `logout_pada`, `expired_pada`, `status`) VALUES
(1, NULL, 1, '76e6954ef97573bf587244d09878d02b6b614602c2ac7034ebbb79968840b182', '182.8.227.45', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-11 18:10:16', NULL, '2026-01-12 18:10:16', 'aktif'),
(2, NULL, 1, 'be7e9af5dfbc54915de76fec053fb9b0fbdcb2469e9500ba66c326e8b2052928', '158.140.166.64', 'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/143.0.7499.92 Mobile/15E148 Safari/604.1', '2026-01-12 14:51:56', NULL, '2026-01-13 14:51:56', 'aktif'),
(3, NULL, 1, '6d5115dc1a9f43641f05768cd7f3d3d9743cb1c0734614caa125ad97b27b57ad', '2405:5fc0:7:2:70f2:e717:6553:c2d3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-13 11:15:16', '2026-01-13 11:17:02', '2026-01-14 11:15:16', 'logout'),
(4, NULL, 1, '257a41ad41e00eac686987f87aa78f92869e761c5d98d05eac70615b7bc8b327', '2405:5fc0:7:2:70f2:e717:6553:c2d3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-13 11:17:10', '2026-01-13 12:11:03', '2026-01-14 11:17:10', 'logout'),
(5, NULL, 1, 'cf86280272cf5d081cde2cceaf1872579de540b7c0482b59648b0d25f5652643', '2405:5fc0:7:2:70f2:e717:6553:c2d3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-13 12:11:11', '2026-01-13 12:17:07', '2026-01-14 12:11:11', 'logout'),
(6, NULL, 3, 'fe76542d023b7d90ac2c2ed207ba2f2bc63f4e4a4b47c2ffe2402f2fe42d6d48', '2405:5fc0:7:2:70f2:e717:6553:c2d3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-13 12:19:57', '2026-01-13 12:20:46', '2026-01-14 12:19:57', 'logout'),
(7, NULL, 1, 'b0dd69661332542c0bbe8d54ae8ee0a08c95461ce9cfae1fc1835682bce2ef71', '2405:5fc0:7:2:70f2:e717:6553:c2d3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-13 12:20:48', '2026-01-13 13:11:07', '2026-01-14 12:20:48', 'logout'),
(8, NULL, 1, '60c78c22b5949a12712e1af6216f314a1c001ce829af8b0418631defb35dd70d', '2405:5fc0:7:2:70f2:e717:6553:c2d3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-13 13:13:45', '2026-01-13 13:19:34', '2026-01-14 13:13:45', 'logout'),
(9, NULL, 2, '0a2c0c0b495b6ad8bc23a6f0d3b271de610ba9e89e10d80618b5fdf26a413fe8', '2405:5fc0:7:2:70f2:e717:6553:c2d3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-13 13:19:47', '2026-01-13 13:20:02', '2026-01-14 13:19:47', 'logout'),
(10, NULL, 1, 'afaace499b6bac3a2a054bdfce4bcd0aa6994daff744b7d5fe63bf6c48e8bd25', '2405:5fc0:7:2:70f2:e717:6553:c2d3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-13 13:20:04', NULL, '2026-01-14 13:20:04', 'aktif'),
(11, NULL, 1, '7e142705b66babac8af15202b4f0cd37ffad61e6f8e15e660899849fadae3a86', '158.140.166.64', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 19:05:02', NULL, '2026-01-14 19:05:02', 'aktif'),
(12, NULL, 1, '87d2086b6ebfb86184ee709d09e1e1d9c6d7d52a9652049233dd7b6f43b19c08', '2405:5fc0:7:2:41f2:b904:2:d712', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-14 14:20:16', NULL, '2026-01-15 14:20:16', 'aktif'),
(13, NULL, 1, '475057b7b42297f8d58d5fb923a9cba15da0527cd5859c16d6c6f5e16a4f5126', '158.140.166.64', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-14 19:04:58', NULL, '2026-01-15 19:04:58', 'aktif'),
(14, NULL, 1, '92632a4e15b32e9ed8ae2e78b7231a01ffdc4f841f24d69308f0c2743ad58e5b', '158.140.166.64', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-14 19:21:02', NULL, '2026-01-15 19:21:02', 'aktif'),
(15, NULL, 1, 'd8642e107b4950e312cd3917f57c23eea3caa1abb0de89810add882d3874048e', '158.140.166.64', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 21:18:59', NULL, '2026-01-15 21:18:59', 'aktif'),
(16, NULL, 1, 'f93ab16f9301658a31ed7ac1453fcb6658af60d7ca0aa813795b4e4118b10ae0', '158.140.166.88', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-15 15:24:02', NULL, '2026-01-16 15:24:02', 'aktif'),
(17, NULL, 1, '8ca798d30e8f758efee3debd87157795cd950b243d39359f3ab6308b6fd7b155', '158.140.166.88', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-15 15:45:38', NULL, '2026-01-16 15:45:38', 'aktif'),
(18, NULL, 1, '8991de695a611d4f3e3a675e5bff76858428ac3b5a490910d6ec07002643b87b', '158.140.166.64', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-16 18:46:06', NULL, '2026-01-17 18:46:06', 'aktif'),
(19, NULL, 1, 'f41be12066c84c3c44ede750974768351309fd735cd21014023ee657628f9cb5', '158.140.166.119', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2026-01-18 23:30:11', NULL, '2026-01-19 23:30:11', 'aktif'),
(20, NULL, 1, '22cf9e1fd96978abb76de3308e155a9a95e97d9a2b9b8a5f6549a2e234cc92ff', '158.140.166.119', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-22 18:58:25', NULL, '2026-01-23 18:58:25', 'aktif'),
(21, NULL, 1, 'd0109eee85a415b0c831b07ddf60de840d7c459e04a4358ad4b48160e342fd00', '158.140.166.119', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', '2026-01-22 19:12:38', NULL, '2026-01-23 19:12:38', 'aktif'),
(22, NULL, 1, '380954ef1e4215ec4bd4994c13841127d551765d5b6b6b648e7e98d9961040a2', '2404:8000:101d:4d24:f41c:d54f:c4f2:fd4f', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', '2026-01-25 21:22:04', NULL, '2026-01-26 21:22:04', 'aktif'),
(23, NULL, 1, '0b386a9a5003d3591e1d408dfca3fb2cbd266ca81e956e3041eed1d599bf0153', '2404:8000:101d:4d24:ab40:d26d:d77c:5963', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36', '2026-01-25 21:22:41', NULL, '2026-01-26 21:22:41', 'aktif'),
(24, NULL, 1, '2733ca5dabeb3b68f9022ed52ae231ba919325266312f151736d77a4ddd2b33c', '2404:8000:101d:4d24:f41c:d54f:c4f2:fd4f', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', '2026-01-25 23:22:15', NULL, '2026-01-26 23:22:15', 'aktif'),
(25, NULL, 1, '616a6ac0841f48e8ce5997dea5dce12e6c862d6e0b080d20db0e06c81d1020a2', '103.251.183.2', 'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/143.0.7499.92 Mobile/15E148 Safari/604.1', '2026-01-26 12:25:06', NULL, '2026-01-27 12:25:06', 'aktif'),
(26, NULL, 1, '66692d166ccdacd20f0d4589c26fcba82ea0f5fd086c576d3e2de4493a229617', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 14:00:29', '2026-01-27 14:01:02', '2026-01-28 14:00:29', 'logout'),
(27, NULL, 4, 'a8ffb8b5c773dac74666e915aa8c09a0e0bca4c700a1ff709ff4176317021bfb', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 14:01:11', '2026-01-27 14:01:57', '2026-01-28 14:01:11', 'logout'),
(28, NULL, 1, '1f48d134f5e999522932ba3068fcbf55d6ae89d70d6bd44ce586d1a99baf29bf', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 14:01:59', '2026-01-27 14:02:31', '2026-01-28 14:01:59', 'logout'),
(29, NULL, 1, 'a668fa7d419f29c9a9617513fba28681a1da64700abfef724fd026e566b0d1d8', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 14:02:37', '2026-01-27 14:02:43', '2026-01-28 14:02:37', 'logout'),
(30, NULL, 1, 'e6b8ba0700c139af11e9dc4d48557fc4a434f4522cbf1dd64c5890e7e56e4d07', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 14:29:23', '2026-01-27 14:30:01', '2026-01-28 14:29:23', 'logout'),
(31, NULL, 4, '2f12c228257d607ee94bd67d4a94fcb960e7a4e0dac43eb6d667bbed969ba4ce', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 14:30:14', '2026-01-27 14:34:25', '2026-01-28 14:30:14', 'logout'),
(32, NULL, 2, 'f2a366cce515499f6e7fab6cac364b2b4de6dd0d07b40f30281d8c6da1e3aef7', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 14:34:52', '2026-01-27 14:41:09', '2026-01-28 14:34:52', 'logout'),
(33, NULL, 1, '67ffc0f43994f9f2d3d1f828c79bfc0c07e7aaaa7bcedbf19dbfe0ea5d1e47c5', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 14:41:16', '2026-01-27 14:41:21', '2026-01-28 14:41:16', 'logout'),
(34, NULL, 1, 'ea743da23aa5c1b2cac47cb2edfa8abb8c448d9e4d4353a78b8ceed6769cbc6a', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 14:41:24', '2026-01-27 14:42:36', '2026-01-28 14:41:24', 'logout'),
(35, NULL, 4, 'e376a98281f5899ab106ff9a67d06bfad2947e1f755785d5205c899e5b62805c', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 14:42:41', '2026-01-27 14:55:24', '2026-01-28 14:42:41', 'logout'),
(36, NULL, 1, 'bce70d3f70adb2cd605d46f30e1065b6a04767eb900230863a82117b568b54e9', '114.10.152.205', 'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/143.0.7499.92 Mobile/15E148 Safari/604.1', '2026-01-27 14:45:49', NULL, '2026-01-28 14:45:49', 'aktif'),
(37, NULL, 1, 'f184279149cab594ffe79bc2502cce24e4ee8123a349aba097529ff14ada13d3', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 14:55:29', '2026-01-27 16:18:17', '2026-01-28 14:55:29', 'logout'),
(38, NULL, 1, 'ac6699447e98b6c2e6b49d5b2f6ecf18481398cfcf2d7dd696b784b0683766e6', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 16:21:06', '2026-01-27 16:32:27', '2026-01-28 16:21:06', 'logout'),
(39, NULL, 5, '480de674f942916268ead31e208ecd38e3b1ae178f0770e43e838c6df871d1cd', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 16:32:35', '2026-01-27 16:33:26', '2026-01-28 16:32:35', 'logout'),
(40, NULL, 1, '50613f9fdaf87eb6d50440d387b618cde91f1d11aff26ebc90021ab6a6f1c307', '158.140.166.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 16:34:20', NULL, '2026-01-28 16:34:20', 'aktif');

-- --------------------------------------------------------

--
-- Table structure for table `v_presensi_lengkap`
--

CREATE TABLE `v_presensi_lengkap` (
  `id_presensi` int(11) DEFAULT NULL,
  `nama_lengkap` varchar(100) DEFAULT NULL,
  `rfid_uid` varchar(20) DEFAULT NULL,
  `nama_kelas` varchar(50) DEFAULT NULL,
  `nama_sesi` enum('Subuh','Pagi','Sore','Maghrib','Malam') DEFAULT NULL,
  `tanggal` date DEFAULT NULL,
  `waktu_mulai_aktual` datetime DEFAULT NULL,
  `waktu_salam` datetime DEFAULT NULL,
  `waktu_scan` datetime DEFAULT NULL,
  `status_kehadiran` enum('H','T1','T2','T3','A','I') DEFAULT NULL,
  `nama_status` varchar(50) DEFAULT NULL,
  `poin_keterlambatan` int(11) DEFAULT NULL,
  `kode_device` varchar(10) DEFAULT NULL,
  `lokasi` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `v_rekap_poin_santri`
--

CREATE TABLE `v_rekap_poin_santri` (
  `id_santri` int(11) DEFAULT NULL,
  `nama_lengkap` varchar(100) DEFAULT NULL,
  `rfid_uid` varchar(20) DEFAULT NULL,
  `nama_kelas` varchar(50) DEFAULT NULL,
  `total_kehadiran` bigint(21) DEFAULT NULL,
  `hadir_tepat` decimal(22,0) DEFAULT NULL,
  `terlambat_t1` decimal(22,0) DEFAULT NULL,
  `terlambat_t2` decimal(22,0) DEFAULT NULL,
  `terlambat_t3` decimal(22,0) DEFAULT NULL,
  `total_poin` decimal(32,0) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id_admin`),
  ADD KEY `id_santri` (`id_santri`);

--
-- Indexes for table `device`
--
ALTER TABLE `device`
  ADD PRIMARY KEY (`id_device`);

--
-- Indexes for table `jadwal_sesi`
--
ALTER TABLE `jadwal_sesi`
  ADD PRIMARY KEY (`id_jadwal`);

--
-- Indexes for table `kelas`
--
ALTER TABLE `kelas`
  ADD PRIMARY KEY (`id_kelas`);

--
-- Indexes for table `log_sistem`
--
ALTER TABLE `log_sistem`
  ADD PRIMARY KEY (`id_log`);

--
-- Indexes for table `poin_keterlambatan`
--
ALTER TABLE `poin_keterlambatan`
  ADD PRIMARY KEY (`id_poin`);

--
-- Indexes for table `presensi`
--
ALTER TABLE `presensi`
  ADD PRIMARY KEY (`id_presensi`);

--
-- Indexes for table `santri`
--
ALTER TABLE `santri`
  ADD PRIMARY KEY (`id_santri`);

--
-- Indexes for table `sesi`
--
ALTER TABLE `sesi`
  ADD PRIMARY KEY (`id_sesi`);

--
-- Indexes for table `sesi_login`
--
ALTER TABLE `sesi_login`
  ADD PRIMARY KEY (`id_session`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `id_admin` (`id_admin`),
  ADD KEY `id_sesi` (`id_sesi`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id_admin` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `device`
--
ALTER TABLE `device`
  MODIFY `id_device` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `jadwal_sesi`
--
ALTER TABLE `jadwal_sesi`
  MODIFY `id_jadwal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT for table `kelas`
--
ALTER TABLE `kelas`
  MODIFY `id_kelas` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `log_sistem`
--
ALTER TABLE `log_sistem`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `poin_keterlambatan`
--
ALTER TABLE `poin_keterlambatan`
  MODIFY `id_poin` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `presensi`
--
ALTER TABLE `presensi`
  MODIFY `id_presensi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=253;

--
-- AUTO_INCREMENT for table `santri`
--
ALTER TABLE `santri`
  MODIFY `id_santri` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `sesi`
--
ALTER TABLE `sesi`
  MODIFY `id_sesi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `sesi_login`
--
ALTER TABLE `sesi_login`
  MODIFY `id_session` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key unik untuk setiap session', AUTO_INCREMENT=41;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

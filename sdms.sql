-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Waktu pembuatan: 21 Sep 2026 pada 07.43
-- Versi server: 8.0.45
-- Versi PHP: 8.3.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Basis data: `sdms`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `alembic_version`
--

CREATE TABLE `alembic_version` (
  `version_num` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `alembic_version`
--

INSERT INTO `alembic_version` (`version_num`) VALUES
('411e5211381c');

-- --------------------------------------------------------

--
-- Struktur dari tabel `audit_log`
--

CREATE TABLE `audit_log` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `object` varchar(100) DEFAULT NULL,
  `status` varchar(20) NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `audit_log`
--

INSERT INTO `audit_log` (`id`, `user_id`, `action`, `object`, `status`, `timestamp`) VALUES
(1, 1, 'SEED_DEMO', 'database', 'SUCCESS', '2026-09-16 07:10:11'),
(2, 4, 'LOGIN', 'user:4', 'SUCCESS', '2026-09-16 07:10:26'),
(3, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:10:26'),
(4, NULL, 'LOGIN', '', 'FAILED', '2026-09-16 07:21:50'),
(5, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-16 07:22:26'),
(6, NULL, 'LOGIN', '', 'FAILED', '2026-09-16 07:22:26'),
(7, NULL, 'LOGIN', '', 'FAILED', '2026-09-16 07:23:09'),
(8, NULL, 'LOGIN', '', 'FAILED', '2026-09-16 07:23:14'),
(9, NULL, 'LOGIN', '', 'FAILED', '2026-09-16 07:23:15'),
(10, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-16 07:23:25'),
(11, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-16 07:24:36'),
(12, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:24:37'),
(13, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:24:37'),
(14, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:24:48'),
(15, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:24:48'),
(16, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:24:56'),
(17, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:24:56'),
(18, NULL, 'LOGIN', 'dosen', 'FAILED', '2026-09-16 07:25:05'),
(19, 2, 'LOGIN', 'user:2', 'SUCCESS', '2026-09-16 07:25:09'),
(20, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:25:09'),
(21, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:25:09'),
(22, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:25:23'),
(23, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:25:23'),
(24, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:25:25'),
(25, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:25:25'),
(26, NULL, 'LOGIN', 'andi', 'FAILED', '2026-09-16 07:27:44'),
(27, NULL, 'LOGIN', 'andi', 'FAILED', '2026-09-16 07:27:51'),
(28, NULL, 'LOGIN', 'andi', 'FAILED', '2026-09-16 07:27:58'),
(29, 4, 'LOGIN', 'user:4', 'SUCCESS', '2026-09-16 07:28:06'),
(30, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:28:06'),
(31, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:28:06'),
(32, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:28:13'),
(33, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:28:13'),
(34, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:28:19'),
(35, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:28:19'),
(36, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:29:16'),
(37, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:29:16'),
(38, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:29:24'),
(39, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:29:24'),
(40, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-16 07:30:12'),
(41, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:30:28'),
(42, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:30:29'),
(43, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:31:10'),
(44, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:31:10'),
(45, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:31:17'),
(46, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:31:18'),
(47, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-16 07:32:00'),
(48, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:32:00'),
(49, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:32:00'),
(50, 1, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:32:09'),
(51, 1, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:32:09'),
(52, 1, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:32:14'),
(53, 1, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:32:15'),
(54, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:32:19'),
(55, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:32:19'),
(56, 1, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:32:24'),
(57, 1, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:32:24'),
(58, NULL, 'LOGIN', 'mahasiwa', 'FAILED', '2026-09-16 07:33:18'),
(59, NULL, 'LOGIN', 'mahasiwa', 'FAILED', '2026-09-16 07:33:24'),
(60, 3, 'LOGIN', 'user:3', 'SUCCESS', '2026-09-16 07:33:32'),
(61, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:33:32'),
(62, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:33:33'),
(63, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:33:36'),
(64, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:33:36'),
(65, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:33:44'),
(66, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:33:44'),
(67, 2, 'LOGIN', 'user:2', 'SUCCESS', '2026-09-16 07:33:54'),
(68, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:33:54'),
(69, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:33:54'),
(70, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:34:05'),
(71, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:34:05'),
(72, 2, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:34:10'),
(73, 2, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:34:10'),
(74, 2, 'CREATE_NILAI', 'nilai:3', 'SUCCESS', '2026-09-16 07:34:26'),
(75, 2, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:34:26'),
(76, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-16 07:34:33'),
(77, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:34:34'),
(78, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:34:34'),
(79, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:35:26'),
(80, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:35:26'),
(81, 3, 'LOGIN', 'user:3', 'SUCCESS', '2026-09-16 07:35:43'),
(82, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:35:43'),
(83, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:35:44'),
(84, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:35:46'),
(85, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:35:46'),
(86, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:35:51'),
(87, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:35:51'),
(88, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:35:54'),
(89, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:35:54'),
(90, 2, 'LOGIN', 'user:2', 'SUCCESS', '2026-09-16 07:36:03'),
(91, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:36:04'),
(92, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:36:04'),
(93, 2, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:36:08'),
(94, 2, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:36:09'),
(95, 2, 'CREATE_NILAI', 'nilai:4', 'SUCCESS', '2026-09-16 07:36:23'),
(96, 2, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:36:24'),
(97, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:36:39'),
(98, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:36:40'),
(99, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-16 07:36:44'),
(100, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:36:45'),
(101, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:36:45'),
(102, 2, 'LOGIN', 'user:2', 'SUCCESS', '2026-09-16 07:39:39'),
(103, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:39:39'),
(104, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:39:39'),
(105, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:39:45'),
(106, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:39:45'),
(107, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:39:50'),
(108, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:39:50'),
(109, 2, 'READ_NILAI', 'mahasiswa:5', 'SUCCESS', '2026-09-16 07:40:11'),
(110, 2, 'READ_NILAI', 'mahasiswa:5', 'SUCCESS', '2026-09-16 07:40:11'),
(111, 2, 'CREATE_NILAI', 'nilai:5', 'SUCCESS', '2026-09-16 07:40:19'),
(112, 2, 'READ_NILAI', 'mahasiswa:5', 'SUCCESS', '2026-09-16 07:40:19'),
(113, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-16 07:41:05'),
(114, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:41:05'),
(115, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:41:05'),
(116, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:42:09'),
(117, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:42:10'),
(118, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-16 07:45:06'),
(119, 2, 'LOGIN', 'user:2', 'SUCCESS', '2026-09-16 07:45:06'),
(120, 3, 'LOGIN', 'user:3', 'SUCCESS', '2026-09-16 07:45:06'),
(121, 2, 'CREATE_NILAI', 'nilai:6', 'SUCCESS', '2026-09-16 07:45:06'),
(122, 1, 'UPLOAD_DENIED', 'mahasiswa:1', 'FAILED', '2026-09-16 07:45:06'),
(123, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-16 07:46:13'),
(124, 2, 'LOGIN', 'user:2', 'SUCCESS', '2026-09-16 07:46:14'),
(125, 3, 'LOGIN', 'user:3', 'SUCCESS', '2026-09-16 07:46:14'),
(126, 2, 'CREATE_NILAI', 'nilai:7', 'SUCCESS', '2026-09-16 07:46:14'),
(127, 3, 'UPLOAD_FILE', 'file:3', 'SUCCESS', '2026-09-16 07:46:14'),
(128, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-16 07:46:41'),
(129, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:46:42'),
(130, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:46:42'),
(131, 2, 'LOGIN', 'user:2', 'SUCCESS', '2026-09-16 07:47:07'),
(132, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:47:07'),
(133, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:47:07'),
(134, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:47:36'),
(135, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:47:36'),
(136, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:48:52'),
(137, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:48:52'),
(138, 4, 'LOGIN', 'user:4', 'SUCCESS', '2026-09-16 07:49:02'),
(139, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:49:03'),
(140, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:49:03'),
(141, 2, 'LOGIN', 'user:2', 'SUCCESS', '2026-09-16 07:50:25'),
(142, 2, 'CREATE_NILAI', 'nilai:8', 'SUCCESS', '2026-09-16 07:50:25'),
(143, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:53:28'),
(144, 4, 'READ_NILAI', 'mahasiswa:4', 'SUCCESS', '2026-09-16 07:53:29'),
(145, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-16 07:53:33'),
(146, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:53:34'),
(147, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-16 07:53:34'),
(148, 2, 'LOGIN', 'user:2', 'SUCCESS', '2026-09-16 07:53:49'),
(149, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:53:49'),
(150, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:53:49'),
(151, 3, 'LOGIN', 'user:3', 'SUCCESS', '2026-09-16 07:54:44'),
(152, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:54:44'),
(153, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:54:44'),
(154, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:55:18'),
(155, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:55:18'),
(156, 3, 'UPLOAD_FILE', 'file:4', 'SUCCESS', '2026-09-16 07:55:29'),
(157, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:55:55'),
(158, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:55:55'),
(159, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:56:18'),
(160, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:56:18'),
(161, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:58:51'),
(162, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:58:51'),
(163, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:58:53'),
(164, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-16 07:58:53'),
(165, NULL, 'LOGIN', 'dosen', 'FAILED', '2026-09-16 07:59:12'),
(166, 2, 'LOGIN', 'user:2', 'SUCCESS', '2026-09-16 07:59:21'),
(167, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:59:21'),
(168, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:59:21'),
(169, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:59:26'),
(170, 2, 'READ_NILAI', 'mahasiswa:2', 'SUCCESS', '2026-09-16 07:59:26'),
(171, NULL, 'LOGIN', 'sari', 'FAILED', '2026-09-19 17:24:34'),
(172, NULL, 'LOGIN', 'sari', 'FAILED', '2026-09-19 17:24:39'),
(173, 5, 'LOGIN', 'user:5', 'SUCCESS', '2026-09-19 17:24:49'),
(174, 5, 'READ_NILAI', 'mahasiswa:5', 'SUCCESS', '2026-09-19 17:24:49'),
(175, 5, 'READ_NILAI', 'mahasiswa:5', 'SUCCESS', '2026-09-19 17:24:49'),
(176, 5, 'UPLOAD_FILE', 'file:5', 'SUCCESS', '2026-09-19 17:25:16'),
(177, 3, 'LOGIN', 'user:3', 'SUCCESS', '2026-09-19 17:34:09'),
(178, 3, 'DOWNLOAD_FILE', 'file:4', 'SUCCESS', '2026-09-19 17:34:13'),
(179, 3, 'LOGIN', 'user:3', 'SUCCESS', '2026-09-19 17:36:50'),
(180, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-19 17:36:50'),
(181, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-19 17:36:50'),
(182, 3, 'DOWNLOAD_FILE', 'file:4', 'SUCCESS', '2026-09-19 17:37:18'),
(183, 3, 'DOWNLOAD_FILE', 'file:4', 'SUCCESS', '2026-09-19 17:37:33'),
(184, 5, 'DOWNLOAD_FILE', 'file:5', 'SUCCESS', '2026-09-19 17:37:53'),
(185, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-19 17:39:30'),
(186, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-19 17:39:30'),
(187, 1, 'LOGIN', 'user:1', 'SUCCESS', '2026-09-21 07:38:35'),
(188, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-21 07:38:35'),
(189, 1, 'READ_NILAI', 'mahasiswa:1', 'SUCCESS', '2026-09-21 07:38:35'),
(190, 3, 'LOGIN', 'user:3', 'SUCCESS', '2026-09-21 07:38:48'),
(191, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-21 07:38:48'),
(192, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-21 07:38:48'),
(193, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-21 07:38:56'),
(194, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-21 07:38:56'),
(195, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-21 07:39:03'),
(196, 3, 'READ_NILAI', 'mahasiswa:3', 'SUCCESS', '2026-09-21 07:39:03');

-- --------------------------------------------------------

--
-- Struktur dari tabel `files`
--

CREATE TABLE `files` (
  `id` int NOT NULL,
  `mahasiswa_id` int NOT NULL,
  `original_name` varchar(255) NOT NULL,
  `filepath` varchar(500) NOT NULL,
  `encrypted_aes_key` blob NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `files`
--

INSERT INTO `files` (`id`, `mahasiswa_id`, `original_name`, `filepath`, `encrypted_aes_key`, `created_at`) VALUES
(1, 4, 'dokumen-andi.txt', 'F:\\3SI2\\SEM 6\\KSI\\PROJECTS\\WEB_PROJECT\\backend\\storage\\dummy-andi.txt.enc', 0xb36e287dbfc49ad5396be574eeb6c93c227f5396421db1a7bdf2a86e186fa24033f7e3af37ca6a16319783412ab6834e763c30ed6f26cfa5afa5e8edad79afba6f36fb713a7e6b71820fec5576e556668e8ca15155cc0b30ac36dfe98323212ac61f6d8bcf584cd30028e14e42692c940ccb6768d3bedbb3874d083c4491f03d7ef12170b5e3652dcc4a6e4ecb9dcef79805ecb1e6ec0b4eeb548dbc9aef02bc7eee9926abc136588cfdb637b6d4ddc4dfdc6cf6ab6201666add95961d53e738f814260609993efbf5805857e13f5146cc68593f62300e1c2f7e21809944739e7c7777eb8833bf4afda2bfba4b29c8f5b7ba34f423564dadcf261e4ea4a2e45e, '2026-09-16 07:10:11'),
(2, 5, 'dokumen-sari.txt', 'F:\\3SI2\\SEM 6\\KSI\\PROJECTS\\WEB_PROJECT\\backend\\storage\\dummy-sari.txt.enc', 0x3b2aa7bfb7d65c1f6397581af8c1c699a5d31d42324d22550a797587523ad7ddb2eedfe183ad87ad45a2c6e28cdc6ae0574090f1659369212cc356217acc3512f9af38fbc8d62cfcdf1f72a77afe6b89531dd2bc2f7ee6b69d4c4511faeb95f9ebac416cf54df880033115a1d3832aec1080a29ff05151c6667a8d43ef7d13d43e3ef6a00b20e9877e29e1f0f73e952bed0b12403d71f10e14a0bb49fcb571f705227f4b61a14c0a9c397fcfc1d619ff3d7c05647bce10c2298d1fea3dfd5171a5ba06bd3ee40e5c18862b7cf23d2431be99330a9e6dd1e0bafe56f3a6c75d56e69b6577f62393d2fbf6574afa48a283b45d8136400d32a227f5191b5702fa18, '2026-09-16 07:10:11'),
(3, 3, 'test.txt', 'F:\\3SI2\\SEM 6\\KSI\\PROJECTS\\WEB_PROJECT\\backend\\storage\\46d182d394ac4a1db749cbcb8bf49d4b.enc', 0x1d0363b103f81cacee968baa8a99c99136672c3ab275d79a5ec06ccdd7dd40e09704f089e319499888bd5898ac2c5c846a12e60f2ac5679bbf7ca64e1e8097d852248f671647424953dc83c54d42483b779c29292e3bf79955f484ba2f759ae8e462fa9beb0cdef49584b820fe571a1d607910f1bcb90ba2008b50128818685acbfb68d1fe8fcb4bbb298d7cf3f002b8ab10e643d69fcda993e07e0abc044c439932744b1bc1acc8fa65b36c378932ef5a12d2ff41421d868c9b830f7bd1c92050fac69e0bc01ae86da81f426dd3ab004930325d58e1ac054ce4b3f0c5583d7337fb6efa936d043a1cd257c8dcd33a7d8f012d239131e8848220ae181a6906a1, '2026-09-16 07:46:14'),
(4, 3, 'Kelompok_2_3SI2_Proposal_Proyek_Akhir_KSI.pdf', 'F:\\3SI2\\SEM 6\\KSI\\PROJECTS\\WEB_PROJECT\\backend\\storage\\a5db22c4464a42e981a65fc54661f5e2.enc', 0x703c53e362c2d88d4110822785be8db913edeb529f5f650c98b42dd2982dc90d09a9f439f35c47688c97e04736112984c6b323ccf00caeeb575b7683591a7e15ed2ad93f3a44bd0f3b9b549186e8455c697d640fa7349bbfcf1af22a9066a18ebe4a0cede87c4d6e712628620da72f703184f1b9402d841ebdd1071adf77823f782ab97735d2fd824118e3c5e02e1f48b53b5e3ce659fdd677d01fcdd6ff4b470e95cd02ccca752de15eafb7a05bf331a18a138ff1f951752698b4c24179d22bb5be669accb957899f2fbc8e4c7e5d072278ae424580be58de15e3ce4aadd361f758117666d31bc79a158922e6108bb0ebff821b699181af685b07bd3acfb2ae, '2026-09-16 07:55:29'),
(5, 5, 'Kelompok_2_3SI2_Proposal_Proyek_Akhir_KSI.pdf', 'F:\\3SI2\\SEM 6\\KSI\\PROJECTS\\WEB_PROJECT\\backend\\storage\\76ca2789aab444a39fb38772a461e4d2.enc', 0xa713c70cfe7e127f4ef37d7466176c3b4936d7614bc46d1d66a9d86b4f08bd7ce947da2a985371060cd5161b8af2bf18e0b3c1fd8aa1779ca348bb6e8d7b4a224b826967771e6edc042e5bc92c3f1469678cccb04484753d77c5d66d7277ff1a7f9b85f42014330fefbbc6449ab38670d25929b365e8a2342208020da64c0824fd9c2c215ab104d3e1948c8fafcf50412d1da145ada464fbf053768a8869c5b681269bf6a9798db221ca20decee7e9678b44a93678d72df87e28da54658aa2ac6557a336d2519c36ffbc9a02ad7cc7eea0150d8b982c7458210987433d255a32b9caf701559ab0b1105b460d1e7911deb4a30fa2b0784961a90f08908913a66d, '2026-09-19 17:25:16');

-- --------------------------------------------------------

--
-- Struktur dari tabel `nilai`
--

CREATE TABLE `nilai` (
  `id` int NOT NULL,
  `mahasiswa_id` int NOT NULL,
  `uts_enc` blob NOT NULL,
  `uas_enc` blob NOT NULL,
  `tugas_enc` blob NOT NULL,
  `praktikum_enc` blob NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `nilai`
--

INSERT INTO `nilai` (`id`, `mahasiswa_id`, `uts_enc`, `uas_enc`, `tugas_enc`, `praktikum_enc`, `created_at`) VALUES
(1, 4, 0x92f88f32eae4efee37cb89d2c9b3229c2a490c3fa59ddf8bcf431c95a8c2, 0x2cf2569fd0ad34b82fee0813a3d858eb4b9aab5b1144b0b1bad8f6bbd404, 0xdf9a1cc20a9658b8fd5ea655ac4ee8c6221d6de1d3b8d180463aa9405315, 0x7c5743adb125d4e0eec4a23373b90421565d84cc3e4dbadc48d69ceaf150, '2026-09-16 07:10:11'),
(2, 5, 0xfc54ae32356dcfd25f358e2a5076327778956bc5ecfde9994b6782c73e80, 0x3f0f56f9d7ff84b289a438657e1c76541cc662243a7674f157e6097385ac, 0xff0f12684f42e90adce117954ee9af0b2e9202b7f20c6d29824065448127, 0x1daaedb3959b62450a574d9e104b3340f67a2df88c5d14fc6be2a3772e2e, '2026-09-16 07:10:11'),
(3, 4, 0x98892346909e1787189bbf789a6dec8aec261e3ad8297b7438ee44e5cd00, 0x2b15f759c399027af9013f909a7be4dccff0f14fd75893a6e0abd80c4861, 0xe73bd5a7038167095242e2d886f9ab53c1dfda20e192dcf1eb15b4d3834c, 0xe75c5485333c8cec2fe16d18890ae9a8fc9ba97ff47bf24a3509a3c77f87, '2026-09-16 07:34:26'),
(4, 4, 0xf86ef000f152fda74e2e87a80616f315430f21d311399d233f4d34c5230e, 0xbd59355cc0a038ea85c02572903ecc699b9da1daa28a7db2bb11450b8dcc, 0xa1c4b337a4924cbcf969b97ac3f7524b09649b3f837ee9ec4609cf12a03c, 0x178a6f52df233897cce6245a09c739494f94161880839d87455806cddf41, '2026-09-16 07:36:23'),
(5, 5, 0x184eeda1e9e98adf403a935dbf3bd184142e62df8788c9de3357ca86e795, 0x4c425822b4a97e403774ca365627ff80db0fb5a1d5177d62c50e73176ad9, 0xcd921430dace0515b8baddc791017d54ea94f2a8cd4f56fe6fdf3a3d8c01, 0x188098dcce4a37874435bef42ae144424aac49cf97fb547a3d6c2dfecaa1, '2026-09-16 07:40:19'),
(6, 3, 0x3d5652627d612f2fe392411c3784c5f73723ac2d5fde2b40e67f13e6c724, 0xd68e82261e9f3aacbe8092c38c4f94ed54ad8e490cd50c030a1c35b63236, 0xaa0565f4ce3c14ec17f046d5397435a357aafb1066dbe37db9d5279aa361, 0x01ba522a8ff4925acfa2e7f3cc61a490fc52d954e879d55ac76bc65a6853, '2026-09-16 07:45:06'),
(7, 3, 0xe51a9b2adbd377edb3e484b8d922458a5aaecea34ee5c04fd0985e96a7af, 0x295a2b31ad7c9877bc85bf838f37c8cbaf46fbe77fdb6f0627f2290f2ad6, 0x7020cd8c1670383f8b3a556de854a464b9d3ae17a3e1915a0ef091b075dd, 0x5dc05c7f9b17358d44b155e97d4dbb4a617274b3c3adb347b41cf850cc5a, '2026-09-16 07:46:14'),
(8, 3, 0x0dc4a8f4ced4ce692b0afe3640f321ba258bcd05eef342ffee13f8a70ac1, 0x883240c326eb461c0d5502e342a8eed7269212d97e1ff7cbbacf7ae95f16, 0x001fa0cb1342188c55ceee273f9a171d10e7682e96abf1a45d035ae1fbd7, 0xe9a316f3fdf06831c86fdccef3425a7876f5a64920c9ad38f70919db7b0f, '2026-09-16 07:50:25');

--
-- Trigger `nilai`
--
DELIMITER $$
CREATE TRIGGER `trg_nilai_update` AFTER UPDATE ON `nilai` FOR EACH ROW BEGIN
    INSERT INTO audit_log (user_id, action, object, status)
    VALUES (@current_user_id, 'UPDATE', CONCAT('nilai:', NEW.id), 'SUCCESS');
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'mahasiswa',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `username`, `password_hash`, `role`, `created_at`) VALUES
(1, 'admin', '$2b$12$pMd8AUiIL8x1cNjxVyxE7eaWozm48qAiqCHomuJeXmHzmetAhmuH6', 'admin', '2026-09-16 07:06:17'),
(2, 'dosen', '$2b$12$hIat.nhfRqzYq.k6ODfdFeTX65ibnsSknb.PK24rJM1l9vmYqfUEW', 'dosen', '2026-09-16 07:06:17'),
(3, 'mahasiswa', '$2b$12$BJR2sqdAFa6pQHavMw6KXenRw.kY0XjBqUD8PNpbiStpycYg.7GtG', 'mahasiswa', '2026-09-16 07:06:18'),
(4, 'andi', '$2b$12$svuSAVYUfvAt5guGwKX5.ORwEtfRU1T8D/l02Q4vNjd0Ggnp92YpK', 'mahasiswa', '2026-09-16 07:10:11'),
(5, 'sari', '$2b$12$MRt5dXwul./WTlM1lc0Hj.aFIRu5pveCVRhhDSUuPXXkRuN6BYGIi', 'mahasiswa', '2026-09-16 07:10:11');

--
-- Indeks untuk tabel yang dibuang
--

--
-- Indeks untuk tabel `alembic_version`
--
ALTER TABLE `alembic_version`
  ADD PRIMARY KEY (`version_num`);

--
-- Indeks untuk tabel `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `files`
--
ALTER TABLE `files`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ix_files_mahasiswa_id` (`mahasiswa_id`);

--
-- Indeks untuk tabel `nilai`
--
ALTER TABLE `nilai`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ix_nilai_mahasiswa_id` (`mahasiswa_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=197;

--
-- AUTO_INCREMENT untuk tabel `files`
--
ALTER TABLE `files`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `nilai`
--
ALTER TABLE `nilai`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

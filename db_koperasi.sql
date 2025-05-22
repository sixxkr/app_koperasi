-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 16, 2025 at 03:32 AM
-- Server version: 10.4.25-MariaDB
-- PHP Version: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_koperasi`
--

-- --------------------------------------------------------

--
-- Table structure for table `checkout`
--

CREATE TABLE `checkout` (
  `id_checkout` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `id_transaksi` int(11) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `subtotal` int(11) NOT NULL,
  `status` varchar(255) NOT NULL,
  `tanggal` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `checkout`
--

INSERT INTO `checkout` (`id_checkout`, `id_user`, `id_produk`, `id_transaksi`, `jumlah`, `subtotal`, `status`, `tanggal`) VALUES
(27, 5, 1, 0, 2, 30000, 'selesai', '2025-05-05 09:05:06'),
(28, 5, 1, 0, 1, 15000, 'selesai', '2025-05-05 09:23:49'),
(29, 5, 1, 0, 3, 45000, 'selesai', '2025-05-05 09:49:57'),
(30, 5, 2, 0, 6, 54000, 'selesai', '2025-05-05 09:50:04'),
(31, 3, 1, 0, 2, 30000, 'selesai', '2025-05-05 14:46:45'),
(32, 3, 2, 0, 5, 45000, 'selesai', '2025-05-05 14:46:54'),
(33, 3, 2, 0, 3, 27000, 'selesai', '2025-05-05 14:55:52'),
(34, 3, 1, 0, 3, 45000, 'selesai', '2025-05-05 14:55:56'),
(35, 5, 2, 0, 1, 9000, 'selesai', '2025-05-06 08:39:36'),
(37, 5, 1, 0, 3, 45000, 'selesai', '2025-05-06 13:18:18'),
(38, 5, 1, 0, 2, 30000, 'selesai', '2025-05-06 13:20:29'),
(39, 5, 2, 0, 2, 18000, 'selesai', '2025-05-06 13:20:33'),
(41, 3, 1, 0, 3, 45000, 'selesai', '2025-05-06 14:40:36'),
(42, 3, 2, 0, 5, 45000, 'selesai', '2025-05-06 14:40:41'),
(43, 5, 1, 0, 1, 15000, 'selesai', '2025-05-06 14:43:04'),
(44, 5, 2, 0, 10, 90000, 'selesai', '2025-05-06 14:43:10'),
(45, 5, 1, 0, 9, 135000, 'selesai', '2025-05-06 14:43:16'),
(46, 5, 1, 0, 2, 30000, 'selesai', '2025-05-06 14:52:25'),
(47, 5, 2, 0, 3, 27000, 'selesai', '2025-05-06 14:52:31'),
(48, 5, 1, 0, 5, 75000, 'selesai', '2025-05-06 14:56:40'),
(49, 5, 2, 0, 5, 45000, 'selesai', '2025-05-06 14:56:45'),
(50, 5, 1, 0, 10, 150000, 'selesai', '2025-05-07 07:51:54'),
(51, 5, 2, 0, 10, 90000, 'selesai', '2025-05-07 07:52:04'),
(54, 5, 1, 0, 10, 150000, 'selesai', '2025-05-07 08:32:02'),
(59, 5, 1, 0, 3, 45000, 'selesai', '2025-05-07 14:35:30'),
(60, 5, 2, 0, 10, 90000, 'selesai', '2025-05-07 14:35:40'),
(61, 5, 1, 0, 2, 30000, 'selesai', '2025-05-09 09:32:35'),
(62, 5, 1, 0, 45, 675000, 'selesai', '2025-05-13 09:23:22'),
(63, 5, 4, 0, 100, 1000000, 'selesai', '2025-05-13 09:23:59');

-- --------------------------------------------------------

--
-- Table structure for table `kategori`
--

CREATE TABLE `kategori` (
  `id_kategori` int(11) NOT NULL,
  `nama` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `kategori`
--

INSERT INTO `kategori` (`id_kategori`, `nama`) VALUES
(1, 'Produk Dua Kelinci'),
(2, 'Peralatan Rumah Tangga'),
(3, 'Lainnya');

-- --------------------------------------------------------

--
-- Table structure for table `produk`
--

CREATE TABLE `produk` (
  `id_produk` int(11) NOT NULL,
  `nama` varchar(255) NOT NULL,
  `stock` int(11) NOT NULL,
  `harga` int(11) NOT NULL,
  `gambar` varchar(255) NOT NULL,
  `id_kategori` int(11) NOT NULL,
  `terjual` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `produk`
--

INSERT INTO `produk` (`id_produk`, `nama`, `stock`, `harga`, `gambar`, `id_kategori`, `terjual`) VALUES
(1, 'Kacang Dua Kelinci', 0, 15000, 'Kacang_Dua_Kelinci.jpg', 1, 60),
(2, 'Kacang Dua Kelinci versi baru', 40, 9000, 'OIP_1.jpeg', 1, 10),
(3, 'Toss', 10, 10000, '1.jpg', 1, 0),
(4, 'Kacang Bar ', 0, 10000, '1.jpg', 1, 100),
(5, 'kacang garing ', 100, 11000, '1.jpg', 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id_roles` int(11) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id_roles`, `name`) VALUES
(1, 'Admin'),
(2, 'User');

-- --------------------------------------------------------

--
-- Table structure for table `transaksi`
--

CREATE TABLE `transaksi` (
  `id_transaksi` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `metode_pembayaran` varchar(50) NOT NULL,
  `total` int(11) NOT NULL,
  `status_pembayaran` varchar(50) NOT NULL DEFAULT 'menunggu_konfirmasi',
  `tanggal` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `transaksi`
--

INSERT INTO `transaksi` (`id_transaksi`, `id_user`, `metode_pembayaran`, `total`, `status_pembayaran`, `tanggal`) VALUES
(4, 5, 'Cash', 0, 'Selesai', '2025-05-03 10:29:10'),
(5, 5, 'Cash', 0, 'Selesai', '2025-05-05 08:40:48'),
(6, 5, 'Cash', 0, 'Dibatalkan', '2025-05-05 08:42:39'),
(7, 5, 'Cash', 0, 'Selesai', '2025-05-05 08:54:44'),
(10, 5, 'Cash', 144000, 'Selesai', '2025-05-05 09:50:17'),
(11, 3, 'Cash', 105000, 'Selesai', '2025-05-05 14:47:06'),
(12, 3, 'Cash', 99000, 'Selesai', '2025-05-05 14:56:10'),
(13, 5, 'Cash', 9000, 'Selesai', '2025-05-06 08:41:40'),
(14, 5, 'Cash', 45000, 'Selesai', '2025-05-06 13:18:29'),
(15, 5, 'Cash', 78000, 'Dibatalkan', '2025-05-06 13:20:48'),
(16, 3, 'Cash', 135000, 'Selesai', '2025-05-06 14:40:52'),
(17, 5, 'Cash', 375000, 'Selesai', '2025-05-06 14:43:30'),
(18, 5, 'Cash', 87000, 'Dibatalkan', '2025-05-06 14:52:38'),
(19, 5, 'Cash', 195000, 'Dibatalkan', '2025-05-06 14:56:57'),
(20, 5, 'Cash', 390000, 'Selesai', '2025-05-07 07:53:05'),
(21, 5, 'Cash', 150000, 'Selesai', '2025-05-07 08:32:12'),
(22, 5, 'Cash', 180000, 'Selesai', '2025-05-07 14:35:51'),
(23, 5, 'Cash', 30000, 'Selesai', '2025-05-09 09:32:50'),
(24, 5, 'Cash', 1675000, 'Selesai', '2025-05-13 09:24:07');

-- --------------------------------------------------------

--
-- Table structure for table `transaksi_detail`
--

CREATE TABLE `transaksi_detail` (
  `id` int(11) NOT NULL,
  `id_transaksi` int(11) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `subtotal` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `transaksi_detail`
--

INSERT INTO `transaksi_detail` (`id`, `id_transaksi`, `id_produk`, `jumlah`, `subtotal`) VALUES
(1, 4, 1, 10, 150000),
(2, 4, 2, 5, 45000),
(3, 5, 1, 3, 45000),
(4, 6, 1, 2, 30000),
(5, 7, 2, 3, 27000),
(8, 10, 1, 3, 45000),
(9, 10, 2, 6, 54000),
(10, 11, 1, 2, 30000),
(11, 11, 2, 5, 45000),
(12, 12, 2, 3, 27000),
(13, 12, 1, 3, 45000),
(14, 13, 2, 1, 9000),
(15, 14, 1, 3, 45000),
(16, 15, 1, 2, 30000),
(17, 15, 2, 2, 18000),
(18, 16, 1, 3, 45000),
(19, 16, 2, 5, 45000),
(20, 17, 1, 1, 15000),
(21, 17, 2, 10, 90000),
(22, 17, 1, 9, 135000),
(23, 18, 1, 2, 30000),
(24, 18, 2, 3, 27000),
(25, 19, 1, 5, 75000),
(26, 19, 2, 5, 45000),
(27, 20, 1, 10, 150000),
(28, 20, 2, 10, 90000),
(29, 21, 1, 10, 150000),
(30, 22, 1, 3, 45000),
(31, 22, 2, 10, 90000),
(32, 23, 1, 2, 30000),
(33, 24, 1, 45, 675000),
(34, 24, 4, 100, 1000000);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id_users` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` int(11) NOT NULL,
  `gambar_users` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id_users`, `name`, `username`, `password`, `role`, `gambar_users`) VALUES
(1, 'Natasha', 'natasha123', '123456', 2, ''),
(2, 'Karsten', 'Admin', '123', 1, ''),
(3, 'Justin', 'Justin', '123', 2, ''),
(5, 'Karsten Errando Winoto', 'karsten', '12345', 2, 'http://10.0.2.2:5000/static/images/7f161cfd2add4e27a90ee62d06af4acb_ac006cc0-ea17-4d00-b3f4-c6c635f93f1e.jpg'),
(6, 'Err', 'kasir', '123', 3, 'http://10.0.2.2:5000/static/images/d9d11a2ba5924e50a53e4ac506fb44b7_1.jpg'),
(7, 'Alex', 'alex', '123', 2, ''),
(8, 'Alex', 'Kasir12', '123', 3, '');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `checkout`
--
ALTER TABLE `checkout`
  ADD PRIMARY KEY (`id_checkout`);

--
-- Indexes for table `produk`
--
ALTER TABLE `produk`
  ADD PRIMARY KEY (`id_produk`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id_roles`);

--
-- Indexes for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`id_transaksi`),
  ADD KEY `id_user` (`id_user`);

--
-- Indexes for table `transaksi_detail`
--
ALTER TABLE `transaksi_detail`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_transaksi` (`id_transaksi`),
  ADD KEY `id_produk` (`id_produk`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_users`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `checkout`
--
ALTER TABLE `checkout`
  MODIFY `id_checkout` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `produk`
--
ALTER TABLE `produk`
  MODIFY `id_produk` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id_roles` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `id_transaksi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `transaksi_detail`
--
ALTER TABLE `transaksi_detail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id_users` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `transaksi_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_users`);

--
-- Constraints for table `transaksi_detail`
--
ALTER TABLE `transaksi_detail`
  ADD CONSTRAINT `transaksi_detail_ibfk_1` FOREIGN KEY (`id_transaksi`) REFERENCES `transaksi` (`id_transaksi`),
  ADD CONSTRAINT `transaksi_detail_ibfk_2` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

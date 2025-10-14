-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Oct 14, 2025 at 08:50 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `adet_rentease`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int(11) NOT NULL,
  `tenant_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('pending','approved','rejected','cancelled','completed') DEFAULT 'pending',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `sent_at` datetime DEFAULT current_timestamp(),
  `is_read` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `payment_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `tenant_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `amount_paid` decimal(10,2) NOT NULL,
  `payment_date` datetime DEFAULT current_timestamp(),
  `payment_method` enum('cash','gcash','bank_transfer','online') NOT NULL,
  `status` enum('pending','confirmed','failed') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `properties`
--

CREATE TABLE `properties` (
  `property_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `property_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `location` varchar(255) NOT NULL,
  `available_rooms` int(11) DEFAULT 0,
  `date_posted` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `properties`
--

INSERT INTO `properties` (`property_id`, `owner_id`, `property_name`, `description`, `location`, `available_rooms`, `date_posted`) VALUES
(1, 2, 'Santos Boarding House', 'A quiet and secure boarding house near university belt. Ideal for students looking for a comfortable place to stay.', 'Manila, Metro Manila', 5, '2025-03-15 10:00:00'),
(2, 3, 'Dela Cruz Dormitory', 'Affordable dormitory with free Wi-Fi, laundry area, and 24/7 security. Perfect for college students.', 'Quezon City, Metro Manila', 8, '2025-03-20 14:30:00'),
(3, 4, 'Reyes Girls Dorm', 'Exclusive for female students. Clean, safe, and with strict house rules. Near major schools and transportation.', 'Makati, Metro Manila', 6, '2025-04-01 09:15:00'),
(4, 4, 'Reyes Co-Living Space', 'Modern co-living space for working professionals and students. Includes study lounge and kitchen access.', 'Taguig, Metro Manila', 10, '2025-04-05 16:45:00');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `review_id` int(11) NOT NULL,
  `tenant_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `date_posted` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rooms`
--

CREATE TABLE `rooms` (
  `room_id` int(11) NOT NULL,
  `property_id` int(11) NOT NULL,
  `room_type` enum('Single','Shared') NOT NULL,
  `monthly_rate` decimal(10,2) NOT NULL,
  `total_tenants` int(11) NOT NULL,
  `current_tenants` int(11) DEFAULT 0,
  `house_rules` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rooms`
--

INSERT INTO `rooms` (`room_id`, `property_id`, `room_type`, `monthly_rate`, `total_tenants`, `current_tenants`, `house_rules`) VALUES
(1, 1, 'Single', 4500.00, 1, 0, 'No smoking, No pets, Quiet hours from 10PM to 6AM'),
(2, 1, 'Shared', 3000.00, 4, 0, 'No overnight guests, Keep common areas clean, Curfew at 11PM'),
(3, 1, 'Single', 4800.00, 1, 0, 'No cooking in room, Separate trash disposal, Monthly cleaning required'),
(4, 2, 'Shared', 2500.00, 3, 0, 'Wi-Fi fair usage policy, Laundry schedule must be followed'),
(5, 2, 'Shared', 2800.00, 2, 0, 'No loud music, Study-friendly environment'),
(6, 2, 'Single', 4200.00, 1, 0, 'Security deposit required, Monthly payment in advance'),
(7, 3, 'Single', 5200.00, 1, 0, 'Female tenants only, No male visitors in rooms'),
(8, 3, 'Shared', 3500.00, 3, 0, 'Strict curfew at 10PM, Weekly room inspection'),
(9, 3, 'Single', 5000.00, 1, 0, 'No cooking, Use common kitchen only'),
(10, 4, 'Shared', 4000.00, 4, 0, 'Professional/students only, Community chores rotation'),
(11, 4, 'Single', 6000.00, 1, 0, 'Access to study lounge and kitchen, Monthly community meeting'),
(12, 4, 'Shared', 3800.00, 2, 0, 'Respect quiet hours, Keep shared spaces tidy');

-- --------------------------------------------------------

--
-- Table structure for table `room_images`
--

CREATE TABLE `room_images` (
  `image_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `uploaded_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `phone_number` varchar(15) DEFAULT NULL,
  `role` enum('tenant','owner','admin') NOT NULL,
  `date_registered` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `full_name`, `email`, `password`, `phone_number`, `role`, `date_registered`) VALUES
(1, 'Admin User', 'admin@rentease.com', 'admin123', '09170000000', 'admin', '2025-01-01 09:00:00'),
(2, 'Maria Santos', 'maria.santos@rentease.com', 'owner123', '09171234567', 'owner', '2025-02-10 14:32:00'),
(3, 'John Dela Cruz', 'john.delacruz@rentease.com', 'owner123', '09179876543', 'owner', '2025-02-15 10:18:00'),
(4, 'Angela Reyes', 'angela.reyes@rentease.com', 'owner123', '09173451234', 'owner', '2025-03-01 16:45:00'),
(5, 'Kevin Mendoza', 'kevin.mendoza@student.com', 'tenant123', '09181234567', 'tenant', '2025-03-12 09:00:00'),
(6, 'Jessica Tan', 'jessica.tan@student.com', 'tenant123', '09182345678', 'tenant', '2025-03-13 11:25:00'),
(7, 'Patrick Gomez', 'patrick.gomez@student.com', 'tenant123', '09183456789', 'tenant', '2025-03-14 08:40:00'),
(8, 'Hannah Lim', 'hannah.lim@student.com', 'tenant123', '09184567890', 'tenant', '2025-03-15 15:12:00'),
(9, 'Ryan Cruz', 'ryan.cruz@student.com', 'tenant123', '09185678901', 'tenant', '2025-03-18 12:50:00'),
(10, 'Samantha Uy', 'samantha.uy@student.com', 'tenant123', '09186789012', 'tenant', '2025-03-19 17:33:00'),
(11, 'Nathan Torres', 'nathan.torres@student.com', 'tenant123', '09187890123', 'tenant', '2025-03-20 19:05:00'),
(12, 'Ella Rivera', 'ella.rivera@student.com', 'tenant123', '09188901234', 'tenant', '2025-03-22 08:15:00'),
(13, 'Miguel Lopez', 'miguel.lopez@student.com', 'tenant123', '09189012345', 'tenant', '2025-04-01 10:20:00'),
(14, 'Sophia Garcia', 'sophia.garcia@student.com', 'tenant123', '09190123456', 'tenant', '2025-04-02 11:35:00'),
(15, 'Daniel Chen', 'daniel.chen@student.com', 'tenant123', '09191234567', 'tenant', '2025-04-03 13:45:00'),
(16, 'Isabella Wong', 'isabella.wong@student.com', 'tenant123', '09192345678', 'tenant', '2025-04-04 15:50:00'),
(17, 'James Sy', 'james.sy@student.com', 'tenant123', '09193456789', 'tenant', '2025-04-05 08:30:00'),
(18, 'Chloe Lim', 'chloe.lim@student.com', 'tenant123', '09194567890', 'tenant', '2025-04-06 14:15:00'),
(19, 'Ethan Tan', 'ethan.tan@student.com', 'tenant123', '09195678901', 'tenant', '2025-04-07 16:40:00'),
(20, 'Mia Reyes', 'mia.reyes@student.com', 'tenant123', '09196789012', 'tenant', '2025-04-08 09:55:00'),
(21, 'Lucas Ong', 'lucas.ong@student.com', 'tenant123', '09197890123', 'tenant', '2025-04-09 12:25:00'),
(22, 'Zoe Ramirez', 'zoe.ramirez@student.com', 'tenant123', '09198901234', 'tenant', '2025-04-10 17:10:00'),
(23, 'Tuvween Earl', 'tuvween@tenant.com', 'tenant123', '09074008108', 'tenant', '2025-10-15 02:49:44');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `tenant_id` (`tenant_id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `receiver_id` (`receiver_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `tenant_id` (`tenant_id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `properties`
--
ALTER TABLE `properties`
  ADD PRIMARY KEY (`property_id`),
  ADD KEY `owner_id` (`owner_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `tenant_id` (`tenant_id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`room_id`),
  ADD KEY `property_id` (`property_id`);

--
-- Indexes for table `room_images`
--
ALTER TABLE `room_images`
  ADD PRIMARY KEY (`image_id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `property_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rooms`
--
ALTER TABLE `rooms`
  MODIFY `room_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `room_images`
--
ALTER TABLE `room_images`
  MODIFY `image_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`tenant_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE;

--
-- Constraints for table `properties`
--
ALTER TABLE `properties`
  ADD CONSTRAINT `properties_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE;

--
-- Constraints for table `rooms`
--
ALTER TABLE `rooms`
  ADD CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`) ON DELETE CASCADE;

--
-- Constraints for table `room_images`
--
ALTER TABLE `room_images`
  ADD CONSTRAINT `room_images_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

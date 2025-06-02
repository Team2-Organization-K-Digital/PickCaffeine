CREATE DATABASE  IF NOT EXISTS `pick_caffeine` /*!40100 DEFAULT CHARACTER SET utf8mb3 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `pick_caffeine`;
-- MySQL dump 10.13  Distrib 8.0.42, for macos15 (arm64)
--
-- Host: localhost    Database: pick_caffeine
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `admin_id` varchar(45) NOT NULL,
  `admin_password` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `admin_id_UNIQUE` (`admin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `declaration`
--

DROP TABLE IF EXISTS `declaration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `declaration` (
  `user_id` varchar(15) NOT NULL,
  `review_num` int NOT NULL,
  `declaration_date` datetime DEFAULT NULL,
  `declaration_content` varchar(150) DEFAULT NULL,
  `declaration_state` varchar(45) DEFAULT NULL,
  `sanction_content` varchar(150) DEFAULT NULL,
  `sanction_date` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`,`review_num`),
  KEY `fk_users_has_review_review1_idx` (`review_num`),
  KEY `fk_users_has_review_users1_idx` (`user_id`),
  CONSTRAINT `fk_users_has_review_review1` FOREIGN KEY (`review_num`) REFERENCES `review` (`review_num`),
  CONSTRAINT `fk_users_has_review_users1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `declaration`
--

LOCK TABLES `declaration` WRITE;
/*!40000 ALTER TABLE `declaration` DISABLE KEYS */;
/*!40000 ALTER TABLE `declaration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inquiry`
--

DROP TABLE IF EXISTS `inquiry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inquiry` (
  `inquiry_num` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(15) NOT NULL,
  `inquiry_date` datetime DEFAULT NULL,
  `inquiry_content` varchar(150) DEFAULT NULL,
  `inquiry_state` varchar(45) DEFAULT NULL,
  `response` varchar(150) DEFAULT NULL,
  `response_date` datetime DEFAULT NULL,
  PRIMARY KEY (`inquiry_num`,`user_id`),
  UNIQUE KEY `inquiry_num_UNIQUE` (`inquiry_num`),
  KEY `fk_inquiry_users1_idx` (`user_id`),
  CONSTRAINT `fk_inquiry_users1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inquiry`
--

LOCK TABLES `inquiry` WRITE;
/*!40000 ALTER TABLE `inquiry` DISABLE KEYS */;
/*!40000 ALTER TABLE `inquiry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu` (
  `menu_num` int NOT NULL AUTO_INCREMENT,
  `category_num` int NOT NULL,
  `menu_name` varchar(45) DEFAULT NULL,
  `menu_content` varchar(45) DEFAULT NULL,
  `menu_price` int DEFAULT NULL,
  `menu_image` blob,
  `menu_state` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`menu_num`,`category_num`),
  UNIQUE KEY `menu_num_UNIQUE` (`menu_num`),
  KEY `fk_menu_menu_category1_idx` (`category_num`),
  CONSTRAINT `fk_menu_menu_category1` FOREIGN KEY (`category_num`) REFERENCES `menu_category` (`category_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu`
--

LOCK TABLES `menu` WRITE;
/*!40000 ALTER TABLE `menu` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_category`
--

DROP TABLE IF EXISTS `menu_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_category` (
  `category_num` int NOT NULL AUTO_INCREMENT,
  `store_id` varchar(45) NOT NULL,
  `category_name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`category_num`,`store_id`),
  UNIQUE KEY `category_num_UNIQUE` (`category_num`),
  KEY `fk_menu_category_store1_idx` (`store_id`),
  CONSTRAINT `fk_menu_category_store1` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_category`
--

LOCK TABLES `menu_category` WRITE;
/*!40000 ALTER TABLE `menu_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_option`
--

DROP TABLE IF EXISTS `menu_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_option` (
  `option_num` int NOT NULL AUTO_INCREMENT,
  `menu_num` int NOT NULL,
  `option_title` varchar(45) DEFAULT NULL,
  `option_name` varchar(45) DEFAULT NULL,
  `option_price` int DEFAULT NULL,
  `option_division` int DEFAULT NULL,
  PRIMARY KEY (`option_num`,`menu_num`),
  UNIQUE KEY `option_num_UNIQUE` (`option_num`),
  KEY `fk_menu_option_menu1_idx` (`menu_num`),
  CONSTRAINT `fk_menu_option_menu1` FOREIGN KEY (`menu_num`) REFERENCES `menu` (`menu_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_option`
--

LOCK TABLES `menu_option` WRITE;
/*!40000 ALTER TABLE `menu_option` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu_option` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `my_store`
--

DROP TABLE IF EXISTS `my_store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `my_store` (
  `user_id` varchar(15) NOT NULL,
  `store_id` varchar(45) NOT NULL,
  `selected_date` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`,`store_id`),
  KEY `fk_users_has_store_store1_idx` (`store_id`),
  KEY `fk_users_has_store_users_idx` (`user_id`),
  CONSTRAINT `fk_users_has_store_store1` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`),
  CONSTRAINT `fk_users_has_store_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `my_store`
--

LOCK TABLES `my_store` WRITE;
/*!40000 ALTER TABLE `my_store` DISABLE KEYS */;
/*!40000 ALTER TABLE `my_store` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_list`
--

DROP TABLE IF EXISTS `purchase_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_list` (
  `purchase_num` int NOT NULL,
  `user_id` varchar(15) NOT NULL,
  `store_id` varchar(45) NOT NULL,
  `purchase_date` datetime DEFAULT NULL,
  `purchase_request` varchar(80) DEFAULT NULL,
  `purchase_state` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`purchase_num`,`user_id`,`store_id`),
  KEY `fk_users_has_store_store2_idx` (`store_id`),
  KEY `fk_users_has_store_users1_idx` (`user_id`),
  CONSTRAINT `fk_users_has_store_store2` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`),
  CONSTRAINT `fk_users_has_store_users1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_list`
--

LOCK TABLES `purchase_list` WRITE;
/*!40000 ALTER TABLE `purchase_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `purchase_list` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review`
--

DROP TABLE IF EXISTS `review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `review` (
  `review_num` int NOT NULL AUTO_INCREMENT,
  `purchase_num` int NOT NULL,
  `review_content` varchar(80) DEFAULT NULL,
  `review_image` blob,
  `review_date` datetime DEFAULT NULL,
  `review_state` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`review_num`,`purchase_num`),
  UNIQUE KEY `review_num_UNIQUE` (`review_num`),
  KEY `fk_review_purchase_list1_idx` (`purchase_num`),
  CONSTRAINT `fk_review_purchase_list1` FOREIGN KEY (`purchase_num`) REFERENCES `purchase_list` (`purchase_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review`
--

LOCK TABLES `review` WRITE;
/*!40000 ALTER TABLE `review` DISABLE KEYS */;
/*!40000 ALTER TABLE `review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `selected_menu`
--

DROP TABLE IF EXISTS `selected_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `selected_menu` (
  `selected_num` int NOT NULL AUTO_INCREMENT,
  `menu_num` int NOT NULL,
  `selected_options` json DEFAULT NULL,
  `total_price` int DEFAULT NULL,
  `purchase_num` varchar(45) DEFAULT NULL,
  `selected_quantity` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`selected_num`,`menu_num`),
  UNIQUE KEY `selected_num_UNIQUE` (`selected_num`),
  KEY `fk_menu_has_menu_option_menu1_idx` (`menu_num`),
  CONSTRAINT `fk_menu_has_menu_option_menu1` FOREIGN KEY (`menu_num`) REFERENCES `menu` (`menu_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `selected_menu`
--

LOCK TABLES `selected_menu` WRITE;
/*!40000 ALTER TABLE `selected_menu` DISABLE KEYS */;
/*!40000 ALTER TABLE `selected_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store`
--

DROP TABLE IF EXISTS `store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `store` (
  `store_id` varchar(45) NOT NULL,
  `store_password` varchar(45) DEFAULT NULL,
  `store_name` varchar(45) DEFAULT NULL,
  `store_phone` varchar(45) DEFAULT NULL,
  `store_address` varchar(45) DEFAULT NULL,
  `store_address_detail` varchar(45) DEFAULT NULL,
  `store_latitude` double DEFAULT NULL,
  `store_longitude` double DEFAULT NULL,
  `store_content` varchar(150) DEFAULT NULL,
  `store_state` varchar(45) DEFAULT NULL,
  `store_business_num` int DEFAULT NULL,
  `store_regular_holiday` varchar(100) DEFAULT NULL,
  `store_temporary_holiday` varchar(100) DEFAULT NULL,
  `store_business_hour` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`store_id`),
  UNIQUE KEY `store_id_UNIQUE` (`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store`
--

LOCK TABLES `store` WRITE;
/*!40000 ALTER TABLE `store` DISABLE KEYS */;
/*!40000 ALTER TABLE `store` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_image`
--

DROP TABLE IF EXISTS `store_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_image` (
  `store_id` varchar(45) NOT NULL,
  `image_1` blob,
  `image_2` blob,
  `image_3` blob,
  `image_4` blob,
  `image_5` blob,
  PRIMARY KEY (`store_id`),
  KEY `fk_store_image_store1_idx` (`store_id`),
  CONSTRAINT `fk_store_image_store1` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_image`
--

LOCK TABLES `store_image` WRITE;
/*!40000 ALTER TABLE `store_image` DISABLE KEYS */;
/*!40000 ALTER TABLE `store_image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` varchar(15) NOT NULL,
  `user_nickname` varchar(15) DEFAULT NULL,
  `user_password` varchar(15) DEFAULT NULL,
  `user_phone` varchar(45) DEFAULT NULL,
  `user_email` varchar(45) DEFAULT NULL,
  `user_state` varchar(45) DEFAULT NULL,
  `user_create_date` datetime DEFAULT NULL,
  `user_image` blob,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `user_id_UNIQUE` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-02 17:40:19

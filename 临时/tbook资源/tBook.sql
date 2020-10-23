-- MySQL dump 10.13  Distrib 8.0.20, for macos10.15 (x86_64)
--
-- Host: localhost    Database: tBook
-- ------------------------------------------------------
-- Server version	8.0.20

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `t_current`
--

DROP TABLE IF EXISTS `t_current`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_current` (
  `id` int NOT NULL AUTO_INCREMENT,
  `typeId` int unsigned NOT NULL,
  `userId` int unsigned NOT NULL,
  `createTime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique` (`userId`),
  KEY `t_current_idx1` (`typeId`) USING BTREE,
  KEY `t_current_idx2` (`userId`) USING BTREE,
  CONSTRAINT `t_current_ibfk_1` FOREIGN KEY (`typeId`) REFERENCES `t_type` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `t_current_ibfk_2` FOREIGN KEY (`userId`) REFERENCES `t_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_current`
--

LOCK TABLES `t_current` WRITE;
/*!40000 ALTER TABLE `t_current` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_current` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_history`
--

DROP TABLE IF EXISTS `t_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `typeId` int unsigned NOT NULL,
  `userId` int unsigned NOT NULL,
  `createTime` datetime NOT NULL,
  `endTime` datetime DEFAULT NULL,
  `duration` bigint DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `t_history_idx1` (`typeId`) USING BTREE,
  KEY `t_history_idx2` (`userId`) USING BTREE,
  CONSTRAINT `t_history_fk1` FOREIGN KEY (`typeId`) REFERENCES `t_type` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `t_history_fk2` FOREIGN KEY (`userId`) REFERENCES `t_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_history`
--

LOCK TABLES `t_history` WRITE;
/*!40000 ALTER TABLE `t_history` DISABLE KEYS */;
INSERT INTO `t_history` VALUES (11,22,3,'2020-07-03 11:24:38','2020-07-03 11:24:45',7),(12,20,3,'2020-07-03 11:24:47','2020-07-03 11:24:57',10),(13,27,3,'2020-07-03 11:25:12','2020-07-03 11:25:28',400),(14,22,3,'2020-07-03 15:02:13','2020-07-03 15:02:16',3),(15,21,3,'2020-07-03 15:02:17','2020-07-03 15:02:20',2),(16,23,3,'2020-07-03 15:02:21','2020-07-03 15:02:25',4),(17,20,3,'2020-07-03 15:15:10','2020-07-03 15:15:17',7),(18,20,3,'2020-07-03 17:28:44','2020-07-03 17:40:31',706),(19,20,3,'2020-07-03 17:40:33','2020-07-03 17:40:37',4),(20,19,3,'2020-07-06 15:18:55','2020-07-06 15:58:00',2344),(21,22,3,'2020-07-06 15:58:03','2020-07-06 15:58:21',1500),(22,32,3,'2020-07-06 15:58:24','2020-07-06 15:58:36',600),(23,19,3,'2020-07-07 18:12:25','2020-07-07 18:12:28',2),(24,20,3,'2020-07-07 18:13:00','2020-07-07 18:13:03',3);
/*!40000 ALTER TABLE `t_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_type`
--

DROP TABLE IF EXISTS `t_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_type` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `fatherId` int unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `t_type_index1` (`fatherId`) USING BTREE,
  CONSTRAINT `t_type_fk1` FOREIGN KEY (`fatherId`) REFERENCES `t_type_father` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_type`
--

LOCK TABLES `t_type` WRITE;
/*!40000 ALTER TABLE `t_type` DISABLE KEYS */;
INSERT INTO `t_type` VALUES (14,1,'Java'),(15,1,'iOS'),(18,1,'陪爸妈'),(19,3,'iOS'),(20,4,'LOL'),(21,2,'跑步'),(22,2,'波比跳'),(23,2,'骑行'),(24,2,'拉伸'),(25,5,'摸鱼'),(26,5,'姐姐'),(27,5,'放飞自我'),(32,1,'陪奶奶');
/*!40000 ALTER TABLE `t_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_type_father`
--

DROP TABLE IF EXISTS `t_type_father`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_type_father` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_type_father`
--

LOCK TABLES `t_type_father` WRITE;
/*!40000 ALTER TABLE `t_type_father` DISABLE KEYS */;
INSERT INTO `t_type_father` VALUES (1,'家庭'),(2,'健康'),(3,'工作'),(4,'娱乐'),(5,'其他');
/*!40000 ALTER TABLE `t_type_father` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_user`
--

DROP TABLE IF EXISTS `t_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `pwd` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '123456',
  `createTime` datetime DEFAULT NULL,
  `updateTime` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unique_1` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_user`
--

LOCK TABLES `t_user` WRITE;
/*!40000 ALTER TABLE `t_user` DISABLE KEYS */;
INSERT INTO `t_user` VALUES (3,'18702781315','53bcb7da6f6d465d809e337544e70f63','2020-06-28 15:15:03','2020-07-07 18:13:23');
/*!40000 ALTER TABLE `t_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_user_code`
--

DROP TABLE IF EXISTS `t_user_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user_code` (
  `id` int NOT NULL AUTO_INCREMENT,
  `phone` varchar(255) NOT NULL,
  `createTime` datetime NOT NULL,
  `code` varchar(255) NOT NULL,
  `type` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_user_code`
--

LOCK TABLES `t_user_code` WRITE;
/*!40000 ALTER TABLE `t_user_code` DISABLE KEYS */;
INSERT INTO `t_user_code` VALUES (1,'18702781315','2020-06-28 15:14:32','123456',10),(2,'18702781315','2020-07-07 18:10:47','123456',20),(3,'18702781315','2020-07-07 15:26:42','123456',30);
/*!40000 ALTER TABLE `t_user_code` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_user_type`
--

DROP TABLE IF EXISTS `t_user_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user_type` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `userId` int unsigned NOT NULL,
  `typeId` int unsigned NOT NULL,
  `weight` int unsigned NOT NULL DEFAULT '0',
  `isDel` int unsigned NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_1` (`userId`,`typeId`),
  KEY `t_user_type_idx1` (`userId`) USING BTREE,
  KEY `t_user_type_idx2` (`typeId`) USING BTREE,
  CONSTRAINT `t_user_type_fk1` FOREIGN KEY (`userId`) REFERENCES `t_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `t_user_type_fk2` FOREIGN KEY (`typeId`) REFERENCES `t_type` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_user_type`
--

LOCK TABLES `t_user_type` WRITE;
/*!40000 ALTER TABLE `t_user_type` DISABLE KEYS */;
INSERT INTO `t_user_type` VALUES (9,3,18,0,0),(10,3,19,0,0),(11,3,20,0,0),(12,3,21,2,0),(13,3,22,1,0),(14,3,23,5,0),(15,3,24,1,0),(18,3,27,0,0),(19,3,32,0,0);
/*!40000 ALTER TABLE `t_user_type` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-07-08 11:38:02

/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Null for system actions',
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Action performed: viewed_case, exported_data, etc.',
  `resource_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Model type: Report, User, etc.',
  `resource_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ID of the affected resource',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `changes` json DEFAULT NULL COMMENT 'old_values and new_values',
  `severity` enum('info','warning','critical') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'info',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `audit_logs_user_id_index` (`user_id`),
  KEY `audit_logs_action_index` (`action`),
  KEY `audit_logs_created_at_index` (`created_at`),
  KEY `idx_resource` (`resource_type`,`resource_id`),
  KEY `audit_logs_severity_index` (`severity`),
  KEY `audit_logs_user_id_created_at_index` (`user_id`,`created_at`),
  KEY `audit_logs_action_created_at_index` (`action`,`created_at`),
  KEY `audit_logs_resource_type_created_at_index` (`resource_type`,`created_at`),
  KEY `audit_logs_severity_created_at_index` (`severity`,`created_at`),
  CONSTRAINT `audit_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `content_articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_articles` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('prevention','rights_awareness','support_services','legal_information','health_safety','empowerment','child_protection','emergency_procedures') COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` json NOT NULL COMMENT 'Multilingual title object',
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` json NOT NULL COMMENT 'Multilingual content object',
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `author_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `views_count` int unsigned NOT NULL DEFAULT '0',
  `is_published` tinyint(1) NOT NULL DEFAULT '0',
  `published_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `content_articles_slug_unique` (`slug`),
  KEY `content_articles_category_index` (`category`),
  KEY `content_articles_is_published_index` (`is_published`),
  KEY `content_articles_slug_index` (`slug`),
  KEY `content_articles_author_id_index` (`author_id`),
  KEY `content_articles_published_at_index` (`published_at`),
  KEY `content_articles_views_count_index` (`views_count`),
  KEY `content_articles_category_is_published_index` (`category`,`is_published`),
  KEY `content_articles_is_published_published_at_index` (`is_published`,`published_at`),
  CONSTRAINT `content_articles_author_id_foreign` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `content_videos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_videos` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` json NOT NULL COMMENT 'Multilingual title object',
  `description` json DEFAULT NULL COMMENT 'Multilingual description object',
  `video_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `thumbnail_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration` int unsigned DEFAULT NULL COMMENT 'Duration in seconds',
  `category` enum('prevention','rights_awareness','support_services','legal_information','health_safety','empowerment','child_protection','emergency_procedures') COLLATE utf8mb4_unicode_ci NOT NULL,
  `views_count` int unsigned NOT NULL DEFAULT '0',
  `is_published` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `content_videos_category_index` (`category`),
  KEY `content_videos_is_published_index` (`is_published`),
  KEY `content_videos_views_count_index` (`views_count`),
  KEY `content_videos_duration_index` (`duration`),
  KEY `content_videos_category_is_published_index` (`category`,`is_published`),
  KEY `content_videos_is_published_views_count_index` (`is_published`,`views_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conversations` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `aps_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Agent de Protection Sociale',
  `survivor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Survivante',
  `is_encrypted` tinyint(1) NOT NULL DEFAULT '1',
  `encryption_key_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Reference to encryption key',
  `last_message_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_conversation` (`report_id`,`aps_id`,`survivor_id`),
  KEY `conversations_report_id_index` (`report_id`),
  KEY `conversations_aps_id_index` (`aps_id`),
  KEY `conversations_survivor_id_index` (`survivor_id`),
  KEY `conversations_last_message_at_index` (`last_message_at`),
  KEY `conversations_aps_id_last_message_at_index` (`aps_id`,`last_message_at`),
  KEY `conversations_survivor_id_last_message_at_index` (`survivor_id`,`last_message_at`),
  CONSTRAINT `conversations_aps_id_foreign` FOREIGN KEY (`aps_id`) REFERENCES `users` (`id`),
  CONSTRAINT `conversations_report_id_foreign` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE CASCADE,
  CONSTRAINT `conversations_survivor_id_foreign` FOREIGN KEY (`survivor_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `faqs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `faqs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `question` json NOT NULL COMMENT 'Multilingual question object',
  `answer` json NOT NULL COMMENT 'Multilingual answer object',
  `category` enum('general','reporting','safety','legal','services','privacy','emergency','children','support') COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_index` int unsigned NOT NULL DEFAULT '0',
  `is_published` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `faqs_category_index` (`category`),
  KEY `faqs_order_index_index` (`order_index`),
  KEY `faqs_is_published_index` (`is_published`),
  KEY `faqs_category_order_index_index` (`category`,`order_index`),
  KEY `faqs_is_published_order_index_index` (`is_published`,`order_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedbacks` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `feedback_type` enum('first_contact','referral','closure','follow_up') COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` tinyint unsigned DEFAULT NULL COMMENT 'Rating from 1 to 5',
  `questions_answers` json DEFAULT NULL COMMENT 'Structured Q&A responses',
  `comment` text COLLATE utf8mb4_unicode_ci,
  `submitted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `feedbacks_report_id_index` (`report_id`),
  KEY `feedbacks_feedback_type_index` (`feedback_type`),
  KEY `feedbacks_rating_index` (`rating`),
  KEY `feedbacks_submitted_at_index` (`submitted_at`),
  KEY `feedbacks_report_id_feedback_type_index` (`report_id`,`feedback_type`),
  CONSTRAINT `feedbacks_report_id_foreign` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `conversation_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_type` enum('text','audio','image','location','document') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'text',
  `content` longtext COLLATE utf8mb4_unicode_ci COMMENT 'Encrypted message content',
  `file_path` text COLLATE utf8mb4_unicode_ci COMMENT 'Path to file attachment if applicable',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `read_at` timestamp NULL DEFAULT NULL,
  `is_deleted_by_sender` tinyint(1) NOT NULL DEFAULT '0',
  `is_deleted_by_receiver` tinyint(1) NOT NULL DEFAULT '0',
  `auto_delete_at` timestamp NULL DEFAULT NULL COMMENT 'Automatic deletion timestamp',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `messages_conversation_id_index` (`conversation_id`),
  KEY `messages_sender_id_index` (`sender_id`),
  KEY `messages_created_at_index` (`created_at`),
  KEY `messages_is_read_index` (`is_read`),
  KEY `messages_auto_delete_at_index` (`auto_delete_at`),
  KEY `messages_message_type_index` (`message_type`),
  KEY `messages_conversation_id_created_at_index` (`conversation_id`,`created_at`),
  KEY `messages_conversation_id_is_read_index` (`conversation_id`,`is_read`),
  KEY `messages_auto_delete_at_created_at_index` (`auto_delete_at`,`created_at`),
  CONSTRAINT `messages_conversation_id_foreign` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('new_case','assignment','update','reminder','alert','referral_response') COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` json DEFAULT NULL COMMENT 'Additional contextual data',
  `channels_sent` json DEFAULT NULL COMMENT 'Array of channels: sms, email, push, whatsapp',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notifications_user_id_index` (`user_id`),
  KEY `notifications_is_read_index` (`is_read`),
  KEY `notifications_created_at_index` (`created_at`),
  KEY `notifications_type_index` (`type`),
  KEY `notifications_user_id_is_read_index` (`user_id`,`is_read`),
  KEY `notifications_user_id_created_at_index` (`user_id`,`created_at`),
  KEY `notifications_type_created_at_index` (`type`,`created_at`),
  CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `organizations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `specialties` json DEFAULT NULL,
  `contact_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `province` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `commune` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `max_capacity` int unsigned DEFAULT NULL,
  `current_load` int unsigned DEFAULT NULL,
  `languages_spoken` json DEFAULT NULL,
  `performance_score` decimal(3,1) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permissions_name_unique` (`name`),
  KEY `permissions_name_index` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `referral_updates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `referral_updates` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `referral_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `updated_by` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','accepted','declined','completed') COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci,
  `documents` json DEFAULT NULL COMMENT 'Array of document references',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `referral_updates_referral_id_index` (`referral_id`),
  KEY `referral_updates_updated_by_index` (`updated_by`),
  KEY `referral_updates_created_at_index` (`created_at`),
  KEY `referral_updates_referral_id_created_at_index` (`referral_id`,`created_at`),
  CONSTRAINT `referral_updates_referral_id_foreign` FOREIGN KEY (`referral_id`) REFERENCES `referrals` (`id`) ON DELETE CASCADE,
  CONSTRAINT `referral_updates_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `referrals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `referrals` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `organization_id` bigint unsigned DEFAULT NULL,
  `referred_by` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `service_type` enum('psychological_support','medical_care','legal_aid','shelter','economic_empowerment','police_protection','child_protection','emergency_transport') COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` enum('low','medium','high','urgent') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','accepted','declined','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `response_deadline` timestamp NOT NULL,
  `accepted_at` timestamp NULL DEFAULT NULL,
  `accepted_by` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `declined_at` timestamp NULL DEFAULT NULL,
  `decline_reason` text COLLATE utf8mb4_unicode_ci,
  `completed_at` timestamp NULL DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `referrals_referred_by_foreign` (`referred_by`),
  KEY `referrals_accepted_by_foreign` (`accepted_by`),
  KEY `referrals_report_id_index` (`report_id`),
  KEY `referrals_organization_id_index` (`organization_id`),
  KEY `referrals_status_index` (`status`),
  KEY `referrals_priority_index` (`priority`),
  KEY `referrals_response_deadline_index` (`response_deadline`),
  KEY `referrals_service_type_index` (`service_type`),
  KEY `referrals_status_priority_index` (`status`,`priority`),
  KEY `referrals_organization_id_status_index` (`organization_id`,`status`),
  KEY `referrals_report_id_status_index` (`report_id`,`status`),
  KEY `referrals_response_deadline_status_index` (`response_deadline`,`status`),
  CONSTRAINT `referrals_accepted_by_foreign` FOREIGN KEY (`accepted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `referrals_organization_id_foreign` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `referrals_referred_by_foreign` FOREIGN KEY (`referred_by`) REFERENCES `users` (`id`),
  CONSTRAINT `referrals_report_id_foreign` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `report_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_files` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_type` enum('photo','audio','document','video') COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Encrypted file path for secure storage',
  `file_name` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Encrypted original filename',
  `file_size` bigint unsigned NOT NULL COMMENT 'File size in bytes',
  `mime_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_by` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `report_files_report_id_index` (`report_id`),
  KEY `report_files_file_type_index` (`file_type`),
  KEY `report_files_uploaded_by_index` (`uploaded_by`),
  KEY `report_files_created_at_index` (`created_at`),
  KEY `report_files_report_id_file_type_index` (`report_id`,`file_type`),
  CONSTRAINT `report_files_report_id_foreign` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE CASCADE,
  CONSTRAINT `report_files_uploaded_by_foreign` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `report_needs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_needs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `report_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `need_type` enum('psychological','medical','legal','shelter','economic','police') COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '1-5 priority level',
  `is_fulfilled` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `report_needs_report_id_need_type_unique` (`report_id`,`need_type`),
  KEY `report_needs_report_id_index` (`report_id`),
  KEY `report_needs_need_type_index` (`need_type`),
  KEY `report_needs_priority_index` (`priority`),
  KEY `report_needs_report_id_need_type_index` (`report_id`,`need_type`),
  KEY `report_needs_is_fulfilled_priority_index` (`is_fulfilled`,`priority`),
  CONSTRAINT `report_needs_report_id_foreign` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reports` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Format: VBG-YYYY-XXXXX',
  `reporter_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Null if anonymous',
  `reporter_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `victim_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_anonymous` tinyint(1) NOT NULL DEFAULT '0',
  `violence_type` enum('physical','sexual','psychological','economic','stalking','forced_marriage','honor_violence','female_genital_mutilation','trafficking','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `violence_types` json DEFAULT NULL,
  `urgency_level` enum('low','moderate','high','critical') COLLATE utf8mb4_unicode_ci NOT NULL,
  `urgency_score` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '0-100 score',
  `victim_age_range` enum('minor_0_5','minor_6_12','minor_13_17','adult_18_25','adult_26_35','adult_36_50','adult_51_plus','unknown') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `victim_gender` enum('female','male','non_binary','prefer_not_say','unknown') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `victim_status` enum('single','married','divorced','widow','separated','unknown') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `incident_date` date DEFAULT NULL,
  `incident_location` text COLLATE utf8mb4_unicode_ci,
  `address_line` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `incident_location_json` json DEFAULT NULL,
  `incident_frequency` enum('first_time','repeated','chronic') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `narrative` longtext COLLATE utf8mb4_unicode_ci COMMENT 'Encrypted narrative',
  `perpetrator_relationship` enum('intimate_partner','ex_partner','family_member','acquaintance','stranger','authority_figure','employer','other','unknown') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `perpetrator_has_home_access` tinyint(1) DEFAULT NULL,
  `is_safe_now` tinyint(1) DEFAULT NULL,
  `needs_urgent_medical` tinyint(1) NOT NULL DEFAULT '0',
  `children_at_risk` tinyint(1) NOT NULL DEFAULT '0',
  `death_threats` tinyint(1) NOT NULL DEFAULT '0',
  `location_province` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location_commune` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location_quartier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `preferred_contact_method` enum('sms','call','whatsapp','in_app','none') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `preferred_contact_methods` json DEFAULT NULL,
  `preferred_contact_hours` json DEFAULT NULL COMMENT 'Array of preferred hours',
  `safety_code_word` text COLLATE utf8mb4_unicode_ci COMMENT 'Encrypted safety word',
  `status` enum('new','triaged','aps_assigned','referred','in_progress','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'new',
  `created_by` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'public_api',
  `assigned_aps_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `closure_reason` text COLLATE utf8mb4_unicode_ci,
  `payload` json DEFAULT NULL,
  `attachments` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reports_report_number_unique` (`report_number`),
  KEY `reports_status_index` (`status`),
  KEY `reports_urgency_level_index` (`urgency_level`),
  KEY `reports_violence_type_index` (`violence_type`),
  KEY `reports_reporter_id_index` (`reporter_id`),
  KEY `reports_assigned_aps_id_index` (`assigned_aps_id`),
  KEY `reports_created_at_index` (`created_at`),
  KEY `reports_urgency_score_index` (`urgency_score`),
  KEY `reports_location_province_index` (`location_province`),
  KEY `reports_status_urgency_level_index` (`status`,`urgency_level`),
  KEY `reports_assigned_aps_id_status_index` (`assigned_aps_id`,`status`),
  KEY `reports_violence_type_created_at_index` (`violence_type`,`created_at`),
  CONSTRAINT `reports_assigned_aps_id_foreign` FOREIGN KEY (`assigned_aps_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `reports_reporter_id_foreign` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `role_id` bigint unsigned NOT NULL,
  `permission_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `role_permissions_role_id_index` (`role_id`),
  KEY `role_permissions_permission_id_index` (`permission_id`),
  CONSTRAINT `role_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` enum('survivante','aps','operateur','organisation','superviseur','admin') COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `permissions` json DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_unique` (`name`),
  KEY `roles_name_index` (`name`),
  KEY `roles_is_active_index` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `telescope_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `telescope_entries` (
  `sequence` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `family_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `should_display_on_index` tinyint(1) NOT NULL DEFAULT '1',
  `type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`sequence`),
  UNIQUE KEY `telescope_entries_uuid_unique` (`uuid`),
  KEY `telescope_entries_batch_id_index` (`batch_id`),
  KEY `telescope_entries_family_hash_index` (`family_hash`),
  KEY `telescope_entries_created_at_index` (`created_at`),
  KEY `telescope_entries_type_should_display_on_index_index` (`type`,`should_display_on_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `telescope_entries_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `telescope_entries_tags` (
  `entry_uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tag` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`entry_uuid`,`tag`),
  KEY `telescope_entries_tags_tag_index` (`tag`),
  CONSTRAINT `telescope_entries_tags_entry_uuid_foreign` FOREIGN KEY (`entry_uuid`) REFERENCES `telescope_entries` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `telescope_monitoring`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `telescope_monitoring` (
  `tag` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Encrypted email',
  `phone` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Encrypted phone',
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` bigint unsigned NOT NULL,
  `organization_id` bigint unsigned DEFAULT NULL,
  `two_factor_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `two_factor_secret` text COLLATE utf8mb4_unicode_ci COMMENT 'Encrypted 2FA secret',
  `last_login_at` timestamp NULL DEFAULT NULL,
  `last_login_ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `users_role_id_index` (`role_id`),
  KEY `users_organization_id_index` (`organization_id`),
  KEY `users_is_active_index` (`is_active`),
  KEY `users_last_login_at_index` (`last_login_at`),
  KEY `users_role_id_is_active_index` (`role_id`,`is_active`),
  KEY `users_organization_id_is_active_index` (`organization_id`,`is_active`),
  CONSTRAINT `users_organization_id_foreign` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `users_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (1,'2018_08_08_100000_create_telescope_entries_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (2,'2019_12_14_000001_create_personal_access_tokens_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (3,'2025_01_01_000001_create_roles_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (4,'2025_01_01_000002_create_permissions_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (5,'2025_01_01_000003_create_role_permissions_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (6,'2025_01_01_000004_create_organizations_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (7,'2025_01_01_000005_create_users_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (8,'2025_01_01_000006_create_reports_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (9,'2025_01_01_000007_create_report_needs_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (10,'2025_01_01_000008_create_report_files_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (11,'2025_01_01_000009_create_referrals_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (12,'2025_01_01_000010_create_referral_updates_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (13,'2025_01_01_000011_create_conversations_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (14,'2025_01_01_000012_create_messages_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (15,'2025_01_01_000013_create_notifications_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (16,'2025_01_01_000014_create_feedbacks_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (17,'2025_01_01_000015_create_audit_logs_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (18,'2025_01_01_000016_create_content_articles_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (19,'2025_01_01_000017_create_content_videos_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (20,'2025_01_01_000018_create_faqs_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (21,'2025_10_29_000001_alter_reports_for_public_submission',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (22,'2025_11_01_211900_update_sanctum_tokens_uuid',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (23,'2025_11_02_134112_add_name_fields_to_users_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (24,'2025_11_03_212301_update_reports_table_add_new_fields',2);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (25,'2025_11_03_213638_add_missing_columns_to_organizations_table',3);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (26,'2025_11_03_214402_modify_type_column_in_organizations_table',4);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (28,'2025_11_03_220937_update_foreign_keys_to_bigint',5);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (29,'2025_11_03_221136_rebuild_organizations_id_to_auto_increment',6);

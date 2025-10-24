-- ============================================
-- PLATEFORME ASSISTANCE MSAADA 2.0
-- Schéma complet de base de données MySQL
-- Violence Basée sur le Genre (VBG)
-- ============================================

SET foreign_key_checks = 0;
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO';

-- ============================================
-- TABLES SYSTÈME UTILISATEURS
-- ============================================

-- Table des rôles
CREATE TABLE roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name ENUM('survivante', 'aps', 'operateur', 'organisation', 'superviseur', 'admin') NOT NULL UNIQUE,
    display_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des permissions
CREATE TABLE permissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table de liaison rôles-permissions
CREATE TABLE role_permissions (
    role_id BIGINT UNSIGNED NOT NULL,
    permission_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des organisations
CREATE TABLE organizations (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type ENUM('ngo', 'hospital', 'police', 'legal', 'shelter', 'economic') NOT NULL,
    specialties JSON DEFAULT NULL,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(255),
    address TEXT,
    province VARCHAR(255),
    commune VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    max_capacity INT UNSIGNED DEFAULT NULL,
    current_load INT UNSIGNED DEFAULT 0,
    languages_spoken JSON DEFAULT NULL,
    performance_score DECIMAL(3,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    
    INDEX idx_type (type),
    INDEX idx_province (province),
    INDEX idx_is_active (is_active),
    INDEX idx_performance (performance_score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des utilisateurs
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,
    email TEXT NOT NULL, -- Chiffré
    phone TEXT NOT NULL, -- Chiffré
    password VARCHAR(255) NOT NULL, -- Hashé
    role_id BIGINT UNSIGNED NOT NULL,
    organization_id CHAR(36) DEFAULT NULL,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret TEXT DEFAULT NULL, -- Chiffré
    last_login_at TIMESTAMP NULL DEFAULT NULL,
    last_login_ip VARCHAR(45) DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    
    INDEX idx_role_id (role_id),
    INDEX idx_organization_id (organization_id),
    INDEX idx_is_active (is_active),
    INDEX idx_last_login (last_login_at),
    
    FOREIGN KEY (role_id) REFERENCES roles(id),
    FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLES SIGNALEMENTS
-- ============================================

-- Table principale des signalements
CREATE TABLE reports (
    id CHAR(36) PRIMARY KEY,
    report_number VARCHAR(50) NOT NULL UNIQUE,
    reporter_id CHAR(36) DEFAULT NULL, -- Nullable si anonyme
    is_anonymous BOOLEAN DEFAULT FALSE,
    violence_type ENUM(
        'physical', 'sexual', 'psychological', 'economic', 
        'stalking', 'forced_marriage', 'honor_violence', 
        'female_genital_mutilation', 'trafficking', 'other'
    ) NOT NULL,
    urgency_level ENUM('low', 'moderate', 'high', 'critical') NOT NULL,
    urgency_score INT UNSIGNED DEFAULT 0 CHECK (urgency_score BETWEEN 0 AND 100),
    victim_age_range ENUM(
        'minor_0_5', 'minor_6_12', 'minor_13_17', 
        'adult_18_25', 'adult_26_35', 'adult_36_50', 
        'adult_51_plus', 'unknown'
    ),
    victim_gender ENUM('female', 'male', 'non_binary', 'prefer_not_say', 'unknown'),
    victim_status ENUM('single', 'married', 'divorced', 'widow', 'separated', 'unknown'),
    incident_date DATE,
    incident_location TEXT,
    incident_frequency ENUM('first_time', 'repeated', 'chronic'),
    narrative LONGTEXT, -- Chiffré
    perpetrator_relationship ENUM(
        'intimate_partner', 'ex_partner', 'family_member', 
        'acquaintance', 'stranger', 'authority_figure', 
        'employer', 'other', 'unknown'
    ),
    is_safe_now BOOLEAN DEFAULT NULL,
    needs_urgent_medical BOOLEAN DEFAULT FALSE,
    children_at_risk BOOLEAN DEFAULT FALSE,
    death_threats BOOLEAN DEFAULT FALSE,
    location_province VARCHAR(255),
    location_commune VARCHAR(255),
    location_quartier VARCHAR(255),
    preferred_contact_method ENUM('sms', 'call', 'whatsapp', 'in_app', 'none'),
    preferred_contact_hours JSON DEFAULT NULL,
    safety_code_word TEXT DEFAULT NULL, -- Chiffré
    status ENUM('new', 'triaged', 'aps_assigned', 'referred', 'in_progress', 'closed') DEFAULT 'new',
    assigned_aps_id CHAR(36) DEFAULT NULL,
    assigned_at TIMESTAMP NULL DEFAULT NULL,
    closed_at TIMESTAMP NULL DEFAULT NULL,
    closure_reason TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    
    INDEX idx_status (status),
    INDEX idx_urgency_level (urgency_level),
    INDEX idx_violence_type (violence_type),
    INDEX idx_reporter_id (reporter_id),
    INDEX idx_assigned_aps_id (assigned_aps_id),
    INDEX idx_created_at (created_at),
    INDEX idx_urgency_score (urgency_score),
    INDEX idx_location_province (location_province),
    
    FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (assigned_aps_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des besoins par signalement
CREATE TABLE report_needs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    report_id CHAR(36) NOT NULL,
    need_type ENUM('psychological', 'medical', 'legal', 'shelter', 'economic', 'police') NOT NULL,
    priority INT UNSIGNED DEFAULT 1 CHECK (priority BETWEEN 1 AND 5),
    is_fulfilled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_report_id (report_id),
    INDEX idx_need_type (need_type),
    INDEX idx_priority (priority),
    
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
    UNIQUE KEY unique_report_need (report_id, need_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des fichiers joints aux signalements
CREATE TABLE report_files (
    id CHAR(36) PRIMARY KEY,
    report_id CHAR(36) NOT NULL,
    file_type ENUM('photo', 'audio', 'document', 'video') NOT NULL,
    file_path TEXT NOT NULL, -- Stockage chiffré S3/MinIO
    file_name TEXT NOT NULL, -- Chiffré
    file_size BIGINT UNSIGNED NOT NULL,
    mime_type VARCHAR(255) NOT NULL,
    uploaded_by CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_report_id (report_id),
    INDEX idx_file_type (file_type),
    INDEX idx_uploaded_by (uploaded_by),
    
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLES RÉFÉRENCEMENT
-- ============================================

-- Table des référencements
CREATE TABLE referrals (
    id CHAR(36) PRIMARY KEY,
    report_id CHAR(36) NOT NULL,
    organization_id CHAR(36) NOT NULL,
    referred_by CHAR(36) NOT NULL,
    service_type ENUM(
        'psychological_support', 'medical_care', 'legal_aid', 
        'shelter', 'economic_empowerment', 'police_protection',
        'child_protection', 'emergency_transport'
    ) NOT NULL,
    priority ENUM('low', 'medium', 'high', 'urgent') NOT NULL,
    status ENUM('pending', 'accepted', 'declined', 'completed') DEFAULT 'pending',
    response_deadline TIMESTAMP NOT NULL,
    accepted_at TIMESTAMP NULL DEFAULT NULL,
    accepted_by CHAR(36) DEFAULT NULL,
    declined_at TIMESTAMP NULL DEFAULT NULL,
    decline_reason TEXT DEFAULT NULL,
    completed_at TIMESTAMP NULL DEFAULT NULL,
    notes TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_report_id (report_id),
    INDEX idx_organization_id (organization_id),
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_response_deadline (response_deadline),
    
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
    FOREIGN KEY (organization_id) REFERENCES organizations(id),
    FOREIGN KEY (referred_by) REFERENCES users(id),
    FOREIGN KEY (accepted_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des mises à jour de référencement
CREATE TABLE referral_updates (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    referral_id CHAR(36) NOT NULL,
    updated_by CHAR(36) NOT NULL,
    status ENUM('pending', 'accepted', 'declined', 'completed') NOT NULL,
    comment TEXT DEFAULT NULL,
    documents JSON DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_referral_id (referral_id),
    INDEX idx_updated_by (updated_by),
    INDEX idx_created_at (created_at),
    
    FOREIGN KEY (referral_id) REFERENCES referrals(id) ON DELETE CASCADE,
    FOREIGN KEY (updated_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLES COMMUNICATIONS
-- ============================================

-- Table des conversations
CREATE TABLE conversations (
    id CHAR(36) PRIMARY KEY,
    report_id CHAR(36) NOT NULL,
    aps_id CHAR(36) NOT NULL,
    survivor_id CHAR(36) NOT NULL,
    is_encrypted BOOLEAN DEFAULT TRUE,
    encryption_key_id VARCHAR(255) DEFAULT NULL,
    last_message_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_report_id (report_id),
    INDEX idx_aps_id (aps_id),
    INDEX idx_survivor_id (survivor_id),
    INDEX idx_last_message_at (last_message_at),
    
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
    FOREIGN KEY (aps_id) REFERENCES users(id),
    FOREIGN KEY (survivor_id) REFERENCES users(id),
    UNIQUE KEY unique_conversation (report_id, aps_id, survivor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des messages
CREATE TABLE messages (
    id CHAR(36) PRIMARY KEY,
    conversation_id CHAR(36) NOT NULL,
    sender_id CHAR(36) NOT NULL,
    message_type ENUM('text', 'audio', 'image', 'location', 'document') DEFAULT 'text',
    content LONGTEXT, -- Chiffré
    file_path TEXT DEFAULT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL DEFAULT NULL,
    is_deleted_by_sender BOOLEAN DEFAULT FALSE,
    is_deleted_by_receiver BOOLEAN DEFAULT FALSE,
    auto_delete_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_conversation_id (conversation_id),
    INDEX idx_sender_id (sender_id),
    INDEX idx_created_at (created_at),
    INDEX idx_is_read (is_read),
    INDEX idx_auto_delete_at (auto_delete_at),
    
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLES NOTIFICATIONS & FEEDBACK
-- ============================================

-- Table des notifications
CREATE TABLE notifications (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    type ENUM('new_case', 'assignment', 'update', 'reminder', 'alert', 'referral_response') NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSON DEFAULT NULL,
    channels_sent JSON DEFAULT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at),
    INDEX idx_type (type),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des feedbacks
CREATE TABLE feedbacks (
    id CHAR(36) PRIMARY KEY,
    report_id CHAR(36) NOT NULL,
    feedback_type ENUM('first_contact', 'referral', 'closure', 'follow_up') NOT NULL,
    rating INT UNSIGNED DEFAULT NULL CHECK (rating BETWEEN 1 AND 5),
    questions_answers JSON DEFAULT NULL,
    comment TEXT DEFAULT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_report_id (report_id),
    INDEX idx_feedback_type (feedback_type),
    INDEX idx_rating (rating),
    INDEX idx_submitted_at (submitted_at),
    
    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLES AUDIT & LOGS
-- ============================================

-- Table des logs d'audit
CREATE TABLE audit_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id CHAR(36) DEFAULT NULL,
    action VARCHAR(255) NOT NULL,
    resource_type VARCHAR(100) NOT NULL,
    resource_id CHAR(36) NOT NULL,
    ip_address VARCHAR(45) DEFAULT NULL,
    user_agent TEXT DEFAULT NULL,
    changes JSON DEFAULT NULL,
    severity ENUM('info', 'warning', 'critical') DEFAULT 'info',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at),
    INDEX idx_resource (resource_type, resource_id),
    INDEX idx_severity (severity),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLES CONTENUS SENSIBILISATION
-- ============================================

-- Table des articles de contenu
CREATE TABLE content_articles (
    id CHAR(36) PRIMARY KEY,
    category ENUM(
        'prevention', 'rights_awareness', 'support_services', 
        'legal_information', 'health_safety', 'empowerment',
        'child_protection', 'emergency_procedures'
    ) NOT NULL,
    title JSON NOT NULL, -- Multilingue
    slug VARCHAR(255) NOT NULL UNIQUE,
    content JSON NOT NULL, -- Multilingue
    image_url VARCHAR(500) DEFAULT NULL,
    author_id CHAR(36) NOT NULL,
    views_count INT UNSIGNED DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    published_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_is_published (is_published),
    INDEX idx_slug (slug),
    INDEX idx_author_id (author_id),
    INDEX idx_published_at (published_at),
    
    FOREIGN KEY (author_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des vidéos de contenu
CREATE TABLE content_videos (
    id CHAR(36) PRIMARY KEY,
    title JSON NOT NULL,
    description JSON DEFAULT NULL,
    video_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500) DEFAULT NULL,
    duration INT UNSIGNED DEFAULT NULL, -- en secondes
    category ENUM(
        'prevention', 'rights_awareness', 'support_services', 
        'legal_information', 'health_safety', 'empowerment',
        'child_protection', 'emergency_procedures'
    ) NOT NULL,
    views_count INT UNSIGNED DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_is_published (is_published),
    INDEX idx_views_count (views_count)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des FAQ
CREATE TABLE faqs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    question JSON NOT NULL, -- Multilingue
    answer JSON NOT NULL, -- Multilingue
    category ENUM(
        'general', 'reporting', 'safety', 'legal', 'services',
        'privacy', 'emergency', 'children', 'support'
    ) NOT NULL,
    order_index INT UNSIGNED DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_order_index (order_index),
    INDEX idx_is_published (is_published)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TRIGGERS POUR AUTO-GÉNÉRATION
-- ============================================

-- Trigger pour générer automatiquement le numéro de signalement
DELIMITER $$
CREATE TRIGGER generate_report_number 
BEFORE INSERT ON reports
FOR EACH ROW
BEGIN
    DECLARE next_number INT;
    DECLARE year_str VARCHAR(4);
    
    SET year_str = YEAR(CURRENT_DATE);
    
    SELECT COALESCE(MAX(CAST(SUBSTRING(report_number, -5) AS UNSIGNED)), 0) + 1 
    INTO next_number 
    FROM reports 
    WHERE report_number LIKE CONCAT('VBG-', year_str, '-%');
    
    SET NEW.report_number = CONCAT('VBG-', year_str, '-', LPAD(next_number, 5, '0'));
END$$
DELIMITER ;

-- ============================================
-- DONNÉES D'INITIALISATION
-- ============================================

-- Insertion des rôles par défaut
INSERT INTO roles (name, display_name) VALUES
('admin', 'Administrateur Système'),
('superviseur', 'Superviseur'),
('aps', 'Agent de Protection Sociale'),
('operateur', 'Opérateur de Saisie'),
('organisation', 'Représentant Organisation'),
('survivante', 'Survivante');

-- Insertion des permissions de base
INSERT INTO permissions (name, description) VALUES
('view_dashboard', 'Voir le tableau de bord'),
('manage_users', 'Gérer les utilisateurs'),
('view_reports', 'Voir les signalements'),
('create_reports', 'Créer des signalements'),
('assign_cases', 'Assigner des cas'),
('manage_organizations', 'Gérer les organisations'),
('view_analytics', 'Voir les analyses'),
('manage_content', 'Gérer le contenu'),
('export_data', 'Exporter les données'),
('system_config', 'Configuration système');

SET foreign_key_checks = 1;

-- ============================================
-- FIN DU SCHÉMA ASSISTANCE MSAADA 2.0
-- ============================================
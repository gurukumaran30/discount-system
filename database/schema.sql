-- ============================================================================
-- Personalized Discount Recommendation System - Database Schema
-- MySQL Database Setup for: discount_system
-- ============================================================================

-- Create the main database
CREATE DATABASE IF NOT EXISTS discount_system;
USE discount_system;

-- ============================================================================
-- TABLE 1: USERS
-- Stores user information and metadata
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    account_type ENUM('standard', 'premium', 'vip') DEFAULT 'standard',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_country (country),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE 2: PRODUCTS
-- Stores product catalog and metadata
-- ============================================================================
CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100),
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    cost DECIMAL(10, 2),
    stock_quantity INT DEFAULT 0,
    rating DECIMAL(3, 2),
    views INT DEFAULT 0,
    clicks INT DEFAULT 0,
    searches INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_price (price),
    INDEX idx_rating (rating),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE 3: DISCOUNTS
-- Stores discount policies and campaigns
-- ============================================================================
CREATE TABLE IF NOT EXISTS discounts (
    discount_id INT PRIMARY KEY AUTO_INCREMENT,
    discount_name VARCHAR(255) NOT NULL,
    discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    min_purchase_amount DECIMAL(10, 2),
    max_discount_amount DECIMAL(10, 2),
    applicable_category VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    usage_count INT DEFAULT 0,
    max_usage INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (applicable_category),
    INDEX idx_active (is_active),
    INDEX idx_date_range (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE 4: PURCHASES
-- Stores purchase history and transaction details
-- ============================================================================
CREATE TABLE IF NOT EXISTS purchases (
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    discount_id INT,
    purchase_amount DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    original_price DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    final_amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50),
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status ENUM('pending', 'completed', 'cancelled', 'refunded') DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (discount_id) REFERENCES discounts(discount_id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_product_id (product_id),
    INDEX idx_discount_id (discount_id),
    INDEX idx_purchase_date (purchase_date),
    INDEX idx_order_status (order_status),
    INDEX idx_user_date (user_id, purchase_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- VIEWS for ML Data Preparation
-- ============================================================================

-- View: user_product_engagement - User-product interaction metrics
CREATE OR REPLACE VIEW user_product_engagement AS
SELECT 
    u.user_id,
    u.username,
    u.email,
    u.account_type,
    u.country,
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.rating,
    COUNT(DISTINCT pu.purchase_id) AS purchase_count,
    SUM(pu.quantity) AS total_quantity,
    AVG(pu.final_amount) AS avg_purchase_amount,
    MAX(pu.purchase_date) AS last_purchase_date,
    SUM(CASE WHEN pu.discount_id IS NOT NULL THEN 1 ELSE 0 END) AS discount_used_count
FROM users u
LEFT JOIN purchases pu ON u.user_id = pu.user_id
LEFT JOIN products p ON pu.product_id = p.product_id
GROUP BY u.user_id, p.product_id;

-- View: discount_performance - Discount effectiveness metrics
CREATE OR REPLACE VIEW discount_performance AS
SELECT 
    d.discount_id,
    d.discount_name,
    d.discount_type,
    d.discount_value,
    d.applicable_category,
    COUNT(DISTINCT pu.purchase_id) AS total_purchases,
    COUNT(DISTINCT pu.user_id) AS unique_users,
    SUM(pu.discount_amount) AS total_discount_given,
    AVG(pu.final_amount) AS avg_transaction_value,
    d.usage_count
FROM discounts d
LEFT JOIN purchases pu ON d.discount_id = pu.discount_id
GROUP BY d.discount_id;

-- View: category_performance - Category-level analytics
CREATE OR REPLACE VIEW category_performance AS
SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) AS product_count,
    COUNT(DISTINCT pu.purchase_id) AS total_purchases,
    COUNT(DISTINCT pu.user_id) AS unique_customers,
    SUM(p.views) AS total_views,
    SUM(p.clicks) AS total_clicks,
    SUM(p.searches) AS total_searches,
    AVG(p.price) AS avg_price,
    AVG(p.rating) AS avg_rating
FROM products p
LEFT JOIN purchases pu ON p.product_id = pu.product_id
GROUP BY p.category;

-- ============================================================================
-- STORED PROCEDURES for Basic Operations
-- ============================================================================

-- Procedure: Get overall discount percentage
DELIMITER //
CREATE PROCEDURE GetOverallDiscountPercentage()
BEGIN
    SELECT
        ROUND(
            (SUM(p.discount_amount) / SUM(p.original_price)) * 100,
            2
        ) AS overall_discount_percentage,
        COUNT(DISTINCT p.purchase_id) AS total_discounted_purchases,
        COUNT(DISTINCT p.user_id) AS users_with_discounts
    FROM purchases p
    WHERE p.discount_id IS NOT NULL;
END //
DELIMITER ;

-- Procedure: Calculate user purchase history
DELIMITER //
CREATE PROCEDURE GetUserPurchaseHistory(IN p_user_id INT)
BEGIN
    SELECT 
        pu.purchase_id,
        pu.product_id,
        p.product_name,
        p.category,
        pu.quantity,
        pu.original_price,
        pu.final_amount,
        pu.discount_amount,
        d.discount_name,
        pu.purchase_date,
        pu.order_status
    FROM purchases pu
    LEFT JOIN products p ON pu.product_id = p.product_id
    LEFT JOIN discounts d ON pu.discount_id = d.discount_id
    WHERE pu.user_id = p_user_id
    ORDER BY pu.purchase_date DESC;
END //
DELIMITER ;

-- ============================================================================
-- INDEXES for Performance Optimization
-- ============================================================================
-- Composite indexes for common query patterns
ALTER TABLE purchases 
ADD INDEX idx_user_product (user_id, product_id),
ADD INDEX idx_user_discount (user_id, discount_id),
ADD INDEX idx_product_category (product_id, category);

COMMIT;

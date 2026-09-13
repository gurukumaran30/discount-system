-- ============================================================================
-- Basic SQL Operations - CRUD and Query Examples
-- Personalized Discount Recommendation System
-- ============================================================================

USE discount_system;

-- ============================================================================
-- 1. INSERT OPERATIONS
-- ============================================================================

-- 1.1 Insert a new user
INSERT INTO users (username, email, first_name, last_name, phone, country, city, account_type) 
VALUES ('new_user', 'new.user@example.com', 'New', 'User', '+1-555-9999', 'USA', 'Boston', 'standard');

-- 1.2 Insert a new product
INSERT INTO products (product_name, category, subcategory, description, price, cost, stock_quantity, rating) 
VALUES ('Smart Watch', 'Electronics', 'Wearables', 'Advanced fitness tracking smartwatch', 199.99, 80.00, 75, 4.6);

-- 1.3 Insert a new discount
INSERT INTO discounts (discount_name, discount_type, discount_value, min_purchase_amount, applicable_category, start_date, end_date, is_active, max_usage) 
VALUES ('Tech Gadgets Special', 'percentage', 22.00, 100.00, 'Electronics', '2024-08-01', '2024-10-31', TRUE, 350);

-- 1.4 Insert a new purchase
INSERT INTO purchases (user_id, product_id, discount_id, purchase_amount, quantity, original_price, discount_amount, final_amount, payment_method, order_status) 
VALUES (1, 21, 9, 199.99, 1, 199.99, 44.00, 155.99, 'credit_card', 'completed');

-- ============================================================================
-- 2. SELECT OPERATIONS
-- ============================================================================

-- 2.1 Select all users
SELECT user_id, username, email, account_type, registration_date 
FROM users 
ORDER BY user_id;

-- 2.2 Select all active products with pricing
SELECT product_id, product_name, category, price, stock_quantity, rating 
FROM products 
WHERE is_active = TRUE 
ORDER BY rating DESC;

-- 2.3 Select all active discounts
SELECT discount_id, discount_name, discount_type, discount_value, applicable_category, start_date, end_date 
FROM discounts 
WHERE is_active = TRUE AND end_date >= CURDATE() 
ORDER BY start_date;

-- 2.4 Select all completed purchases
SELECT purchase_id, user_id, product_id, discount_id, final_amount, purchase_date 
FROM purchases 
WHERE order_status = 'completed' 
ORDER BY purchase_date DESC;

-- 2.5 Select purchase details with joins (users, products, discounts)
SELECT 
    pu.purchase_id,
    u.username,
    p.product_name,
    p.category,
    pu.quantity,
    pu.original_price,
    pu.discount_amount,
    pu.final_amount,
    d.discount_name,
    pu.purchase_date
FROM purchases pu
LEFT JOIN users u ON pu.user_id = u.user_id
LEFT JOIN products p ON pu.product_id = p.product_id
LEFT JOIN discounts d ON pu.discount_id = d.discount_id
ORDER BY pu.purchase_date DESC;

-- 2.6 Count purchases by category
SELECT 
    p.category,
    COUNT(DISTINCT pu.purchase_id) AS purchase_count,
    SUM(pu.final_amount) AS total_revenue
FROM purchases pu
LEFT JOIN products p ON pu.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 2.7 User purchase statistics
SELECT 
    u.user_id,
    u.username,
    u.account_type,
    COUNT(DISTINCT pu.purchase_id) AS total_purchases,
    SUM(pu.final_amount) AS total_spent,
    AVG(pu.final_amount) AS avg_purchase_amount,
    MAX(pu.purchase_date) AS last_purchase_date
FROM users u
LEFT JOIN purchases pu ON u.user_id = pu.user_id
GROUP BY u.user_id
ORDER BY total_spent DESC;

-- 2.8 Discount effectiveness
SELECT 
    d.discount_id,
    d.discount_name,
    COUNT(DISTINCT pu.purchase_id) AS times_used,
    SUM(pu.discount_amount) AS total_discount_value,
    AVG(pu.final_amount) AS avg_transaction_value,
    ROUND((d.usage_count / d.max_usage) * 100, 2) AS usage_percentage
FROM discounts d
LEFT JOIN purchases pu ON d.discount_id = pu.discount_id
WHERE d.is_active = TRUE
GROUP BY d.discount_id
ORDER BY times_used DESC;

-- ============================================================================
-- 3. UPDATE OPERATIONS
-- ============================================================================

-- 3.1 Update user account type
UPDATE users 
SET account_type = 'premium' 
WHERE user_id = 1;

-- 3.2 Update product stock quantity
UPDATE products 
SET stock_quantity = stock_quantity - 1 
WHERE product_id = 1 AND stock_quantity > 0;

-- 3.3 Update product rating
UPDATE products 
SET rating = 4.7 
WHERE product_id = 5;

-- 3.4 Deactivate an expired discount
UPDATE discounts 
SET is_active = FALSE 
WHERE end_date < CURDATE();

-- 3.5 Update purchase order status
UPDATE purchases 
SET order_status = 'shipped' 
WHERE purchase_id = 1;

-- 3.6 Increment product views
UPDATE products 
SET views = views + 1 
WHERE product_id = 1;

-- 3.7 Increment discount usage counter
UPDATE discounts 
SET usage_count = usage_count + 1 
WHERE discount_id = 1;

-- ============================================================================
-- 4. DELETE OPERATIONS
-- ============================================================================

-- 4.1 Delete a specific purchase (with foreign key constraints)
DELETE FROM purchases 
WHERE purchase_id = 100 AND order_status = 'cancelled';

-- 4.2 Delete inactive products
DELETE FROM products 
WHERE is_active = FALSE AND stock_quantity = 0;

-- 4.3 Delete expired discounts (optional - set to inactive instead)
-- DELETE FROM discounts WHERE end_date < DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- 4.4 Delete user (cascade will remove associated purchases)
-- DELETE FROM users WHERE user_id = 999;

-- ============================================================================
-- 5. VERIFICATION QUERIES - Validate IDs and Relationships
-- ============================================================================

-- 5.1 Verify all users exist in database
SELECT COUNT(*) AS total_users FROM users;

-- 5.2 Verify all products exist
SELECT COUNT(*) AS total_products FROM products;

-- 5.3 Verify all discounts
SELECT COUNT(*) AS total_discounts FROM discounts;

-- 5.4 Verify all purchases
SELECT COUNT(*) AS total_purchases FROM purchases;

-- 5.5 Check for orphaned purchases (user_id references)
SELECT pu.purchase_id, pu.user_id 
FROM purchases pu
LEFT JOIN users u ON pu.user_id = u.user_id
WHERE u.user_id IS NULL;

-- 5.6 Check for orphaned purchases (product_id references)
SELECT pu.purchase_id, pu.product_id 
FROM purchases pu
LEFT JOIN products p ON pu.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 5.7 Check for invalid discount references
SELECT pu.purchase_id, pu.discount_id 
FROM purchases pu
LEFT JOIN discounts d ON pu.discount_id = d.discount_id
WHERE pu.discount_id IS NOT NULL AND d.discount_id IS NULL;

-- 5.8 Verify foreign key constraints are working
SELECT CONSTRAINT_NAME, TABLE_NAME, REFERENCED_TABLE_NAME 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_NAME IN ('purchases') AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 5.9 Check table record counts and storage
SELECT 
    table_name,
    table_rows,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS size_mb
FROM information_schema.tables
WHERE table_schema = 'discount_system'
ORDER BY table_rows DESC;

-- 5.10 Verify data integrity - check for negative amounts
SELECT purchase_id, user_id, product_id, final_amount, discount_amount 
FROM purchases 
WHERE final_amount < 0 OR discount_amount < 0;

-- ============================================================================
-- 6. COMPLEX ANALYTICAL QUERIES
-- ============================================================================

-- 6.1 Top 5 products by revenue
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    COUNT(DISTINCT pu.purchase_id) AS sales_count,
    SUM(pu.final_amount) AS total_revenue,
    AVG(p.rating) AS avg_rating
FROM products p
LEFT JOIN purchases pu ON p.product_id = pu.product_id
WHERE pu.order_status = 'completed'
GROUP BY p.product_id
ORDER BY total_revenue DESC
LIMIT 5;

-- 6.2 VIP customer analysis
SELECT 
    u.user_id,
    u.username,
    u.account_type,
    COUNT(DISTINCT pu.purchase_id) AS purchase_count,
    SUM(pu.final_amount) AS lifetime_value,
    SUM(pu.discount_amount) AS total_discounts_received,
    AVG(pu.final_amount) AS avg_transaction
FROM users u
LEFT JOIN purchases pu ON u.user_id = pu.user_id
WHERE u.account_type = 'vip'
GROUP BY u.user_id
ORDER BY lifetime_value DESC;

-- 6.3 Discount ROI analysis
SELECT 
    d.discount_id,
    d.discount_name,
    d.discount_type,
    d.discount_value,
    COUNT(DISTINCT pu.purchase_id) AS triggered_purchases,
    SUM(pu.final_amount) AS revenue_from_discount,
    SUM(pu.discount_amount) AS cost_of_discount,
    ROUND((SUM(pu.final_amount) - SUM(pu.discount_amount)) / NULLIF(SUM(pu.discount_amount), 0), 2) AS roi_ratio
FROM discounts d
LEFT JOIN purchases pu ON d.discount_id = pu.discount_id
WHERE pu.order_status = 'completed'
GROUP BY d.discount_id
ORDER BY roi_ratio DESC;

-- 6.4 Category performance over time
SELECT 
    DATE_FORMAT(pu.purchase_date, '%Y-%m') AS month,
    p.category,
    COUNT(DISTINCT pu.purchase_id) AS transactions,
    SUM(pu.final_amount) AS revenue,
    AVG(pu.final_amount) AS avg_transaction
FROM purchases pu
LEFT JOIN products p ON pu.product_id = p.product_id
WHERE pu.order_status = 'completed'
GROUP BY DATE_FORMAT(pu.purchase_date, '%Y-%m'), p.category
ORDER BY month DESC, revenue DESC;

-- ============================================================================
-- END OF SQL OPERATIONS FILE
-- ============================================================================

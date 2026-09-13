-- ============================================================================
-- Personalized Discount Recommendation System - Sample Data
-- Development and Testing Data for: discount_system
-- ============================================================================

USE discount_system;

-- ============================================================================
-- SAMPLE DATA: USERS (10 users)
-- ============================================================================
INSERT INTO users (username, email, first_name, last_name, phone, country, city, account_type) VALUES
('john_doe', 'john.doe@example.com', 'John', 'Doe', '+1-555-0101', 'USA', 'New York', 'premium'),
('jane_smith', 'jane.smith@example.com', 'Jane', 'Smith', '+1-555-0102', 'USA', 'Los Angeles', 'standard'),
('michael_johnson', 'michael.j@example.com', 'Michael', 'Johnson', '+1-555-0103', 'USA', 'Chicago', 'vip'),
('sarah_williams', 'sarah.w@example.com', 'Sarah', 'Williams', '+1-555-0104', 'Canada', 'Toronto', 'premium'),
('david_brown', 'david.brown@example.com', 'David', 'Brown', '+1-555-0105', 'USA', 'Houston', 'standard'),
('emily_davis', 'emily.davis@example.com', 'Emily', 'Davis', '+44-555-0106', 'UK', 'London', 'premium'),
('robert_miller', 'robert.m@example.com', 'Robert', 'Miller', '+1-555-0107', 'USA', 'Phoenix', 'standard'),
('lisa_anderson', 'lisa.anderson@example.com', 'Lisa', 'Anderson', '+61-555-0108', 'Australia', 'Sydney', 'vip'),
('james_taylor', 'james.taylor@example.com', 'James', 'Taylor', '+1-555-0109', 'USA', 'Philadelphia', 'standard'),
('patricia_clark', 'patricia.clark@example.com', 'Patricia', 'Clark', '+1-555-0110', 'USA', 'San Antonio', 'premium');

-- ============================================================================
-- SAMPLE DATA: PRODUCTS (20 products across 5 categories)
-- ============================================================================
INSERT INTO products (product_name, category, subcategory, description, price, cost, stock_quantity, rating, views, clicks, searches) VALUES

-- Electronics (5 products)
('Wireless Headphones Pro', 'Electronics', 'Audio', 'High-quality wireless headphones with noise cancellation', 129.99, 65.00, 50, 4.7, 1250, 450, 320),
('USB-C Fast Charger', 'Electronics', 'Chargers', 'Quick charging 65W USB-C power adapter', 39.99, 15.00, 120, 4.5, 890, 280, 210),
('4K Webcam', 'Electronics', 'Cameras', 'Professional 4K webcam for streaming and recording', 199.99, 90.00, 30, 4.8, 2100, 680, 450),
('Portable SSD 1TB', 'Electronics', 'Storage', 'High-speed portable solid-state drive', 89.99, 35.00, 80, 4.6, 1500, 520, 380),
('Bluetooth Speaker', 'Electronics', 'Audio', 'Waterproof portable Bluetooth speaker', 59.99, 25.00, 100, 4.4, 1100, 350, 240),

-- Clothing (4 products)
('Cotton T-Shirt Premium', 'Clothing', 'Tops', '100% organic cotton comfortable t-shirt', 24.99, 8.00, 200, 4.3, 650, 180, 120),
('Denim Jeans Blue', 'Clothing', 'Bottoms', 'Classic blue denim jeans with comfortable fit', 59.99, 20.00, 150, 4.4, 920, 290, 180),
('Winter Jacket', 'Clothing', 'Outerwear', 'Warm winter jacket with waterproof coating', 129.99, 50.00, 60, 4.6, 1800, 540, 360),
('Running Shoes', 'Clothing', 'Footwear', 'Lightweight running shoes with cushioned sole', 79.99, 30.00, 90, 4.5, 1400, 420, 300),

-- Home & Kitchen (4 products)
('Stainless Steel Cookware Set', 'Home & Kitchen', 'Cookware', '10-piece cookware set with non-stick coating', 149.99, 60.00, 40, 4.7, 1100, 380, 250),
('Coffee Maker', 'Home & Kitchen', 'Appliances', 'Programmable coffee maker with thermal carafe', 69.99, 28.00, 70, 4.5, 890, 310, 200),
('Knife Set Professional', 'Home & Kitchen', 'Cutlery', '5-piece professional chef knife set', 89.99, 35.00, 50, 4.8, 950, 340, 220),
('Blender High Speed', 'Home & Kitchen', 'Appliances', 'Powerful blender for smoothies and soups', 99.99, 40.00, 60, 4.6, 1050, 360, 240),

-- Books (4 products)
('Programming Fundamentals', 'Books', 'Technology', 'Comprehensive guide to programming basics', 34.99, 12.00, 100, 4.6, 450, 120, 180),
('Data Science Handbook', 'Books', 'Technology', 'Advanced data science techniques and applications', 44.99, 15.00, 80, 4.7, 520, 140, 210),
('The Lean Startup', 'Books', 'Business', 'Build products customers want', 16.99, 6.00, 150, 4.8, 680, 200, 290),
('Python Mastery', 'Books', 'Technology', 'Advanced Python programming techniques', 39.99, 14.00, 90, 4.5, 480, 130, 170),

-- Sports & Outdoors (3 products)
('Yoga Mat Premium', 'Sports & Outdoors', 'Fitness', 'Non-slip yoga mat with carrying strap', 29.99, 10.00, 120, 4.4, 580, 160, 100),
('Camping Tent', 'Sports & Outdoors', 'Camping', '4-person waterproof camping tent', 149.99, 60.00, 35, 4.7, 1200, 400, 280),
('Hiking Backpack', 'Sports & Outdoors', 'Outdoor', '60L capacity hiking backpack with rain cover', 99.99, 40.00, 50, 4.6, 950, 320, 210);

-- ============================================================================
-- SAMPLE DATA: DISCOUNTS (8 active discount campaigns)
-- ============================================================================
INSERT INTO discounts (discount_name, discount_type, discount_value, min_purchase_amount, max_discount_amount, applicable_category, start_date, end_date, is_active, max_usage) VALUES

('Electronics Summer Sale', 'percentage', 20.00, 50.00, 100.00, 'Electronics', '2024-06-01', '2024-08-31', TRUE, 500),
('Clothing Flash Deal', 'percentage', 15.00, 40.00, 75.00, 'Clothing', '2024-06-15', '2024-07-15', TRUE, 300),
('Home Kitchen Promotion', 'fixed_amount', 10.00, 75.00, NULL, 'Home & Kitchen', '2024-07-01', '2024-09-30', TRUE, 400),
('Books Knowledge Deal', 'percentage', 25.00, 30.00, 50.00, 'Books', '2024-07-01', '2024-12-31', TRUE, 600),
('Sports & Outdoors Weekend', 'percentage', 18.00, 60.00, 80.00, 'Sports & Outdoors', '2024-07-05', '2024-09-05', TRUE, 250),
('New Customer Welcome', 'percentage', 30.00, 0.00, 100.00, NULL, '2024-01-01', '2024-12-31', TRUE, 1000),
('VIP Exclusive Offer', 'percentage', 35.00, 100.00, 150.00, NULL, '2024-06-01', '2024-12-31', TRUE, 200),
('Clearance Special', 'fixed_amount', 5.00, 20.00, NULL, NULL, '2024-07-10', '2024-08-31', TRUE, 800);

-- ============================================================================
-- SAMPLE DATA: PURCHASES (30 purchase records)
-- ============================================================================
INSERT INTO purchases (user_id, product_id, discount_id, purchase_amount, quantity, original_price, discount_amount, final_amount, payment_method, purchase_date, order_status) VALUES

-- User 1 (John Doe - 4 purchases)
(1, 1, 1, 129.99, 1, 129.99, 26.00, 103.99, 'credit_card', '2024-07-05', 'completed'),
(1, 5, 1, 59.99, 1, 59.99, 12.00, 47.99, 'credit_card', '2024-07-10', 'completed'),
(1, 12, 3, 149.99, 1, 149.99, 10.00, 139.99, 'credit_card', '2024-07-15', 'completed'),
(1, 14, 4, 34.99, 2, 34.99, 8.75, 61.24, 'paypal', '2024-07-20', 'completed'),

-- User 2 (Jane Smith - 3 purchases)
(2, 7, 2, 59.99, 1, 59.99, 9.00, 50.99, 'credit_card', '2024-06-25', 'completed'),
(2, 3, NULL, 199.99, 1, 199.99, 0.00, 199.99, 'debit_card', '2024-07-02', 'completed'),
(2, 18, 5, 99.99, 1, 99.99, 18.00, 81.99, 'credit_card', '2024-07-18', 'completed'),

-- User 3 (Michael Johnson - 5 purchases - VIP)
(3, 2, 1, 39.99, 2, 39.99, 16.00, 63.98, 'credit_card', '2024-07-01', 'completed'),
(3, 11, 3, 149.99, 1, 149.99, 10.00, 139.99, 'amex', '2024-07-08', 'completed'),
(3, 15, 4, 44.99, 1, 44.99, 11.25, 33.74, 'credit_card', '2024-07-12', 'completed'),
(3, 8, 2, 79.99, 1, 79.99, 12.00, 67.99, 'paypal', '2024-07-16', 'completed'),
(3, 17, 5, 29.99, 2, 29.99, 10.80, 49.18, 'credit_card', '2024-07-22', 'completed'),

-- User 4 (Sarah Williams - 3 purchases)
(4, 9, 2, 79.99, 1, 79.99, 12.00, 67.99, 'credit_card', '2024-06-28', 'completed'),
(4, 13, 4, 89.99, 1, 89.99, 22.50, 67.49, 'debit_card', '2024-07-11', 'completed'),
(4, 4, 1, 89.99, 1, 89.99, 18.00, 71.99, 'credit_card', '2024-07-19', 'completed'),

-- User 5 (David Brown - 2 purchases)
(5, 6, 2, 24.99, 2, 24.99, 7.50, 42.48, 'credit_card', '2024-07-03', 'completed'),
(5, 16, 4, 39.99, 1, 39.99, 10.00, 29.99, 'paypal', '2024-07-21', 'completed'),

-- User 6 (Emily Davis - 4 purchases)
(6, 1, 1, 129.99, 1, 129.99, 26.00, 103.99, 'credit_card', '2024-07-04', 'completed'),
(6, 10, 3, 69.99, 1, 69.99, 10.00, 59.99, 'credit_card', '2024-07-09', 'completed'),
(6, 20, 5, 99.99, 1, 99.99, 18.00, 81.99, 'amex', '2024-07-17', 'completed'),
(6, 14, 4, 34.99, 1, 34.99, 8.75, 26.24, 'credit_card', '2024-07-23', 'completed'),

-- User 7 (Robert Miller - 2 purchases)
(7, 5, 1, 59.99, 1, 59.99, 12.00, 47.99, 'debit_card', '2024-07-06', 'completed'),
(7, 19, 5, 29.99, 1, 29.99, 5.40, 24.59, 'credit_card', '2024-07-24', 'completed'),

-- User 8 (Lisa Anderson - 5 purchases - VIP)
(8, 3, 7, 199.99, 1, 199.99, 70.00, 129.99, 'amex', '2024-07-07', 'completed'),
(8, 12, 3, 149.99, 1, 149.99, 10.00, 139.99, 'credit_card', '2024-07-13', 'completed'),
(8, 4, 1, 89.99, 1, 89.99, 18.00, 71.99, 'credit_card', '2024-07-14', 'completed'),
(8, 15, 4, 44.99, 2, 44.99, 22.50, 67.48, 'paypal', '2024-07-25', 'completed'),

-- User 9 (James Taylor - 2 purchases)
(9, 8, 2, 79.99, 1, 79.99, 12.00, 67.99, 'credit_card', '2024-07-27', 'completed'),
(9, 13, 4, 89.99, 1, 89.99, 22.50, 67.49, 'debit_card', '2024-07-29', 'completed'),

-- User 10 (Patricia Clark - 4 purchases)
(10, 2, 1, 39.99, 1, 39.99, 8.00, 31.99, 'credit_card', '2024-06-30', 'completed'),
(10, 11, 3, 149.99, 1, 149.99, 10.00, 139.99, 'amex', '2024-07-08', 'completed'),
(10, 18, 5, 99.99, 1, 99.99, 18.00, 81.99, 'credit_card', '2024-07-28', 'completed');

-- ============================================================================
-- COMMIT CHANGES
-- ============================================================================
COMMIT;

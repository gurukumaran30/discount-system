h# Data Handoff Guide for ML Team

This document provides Divya with clean datasets, schema documentation, and connection details to begin ML work on the discount system.

---

## Quick Start for Divya

### 1. Get the Exported ML Dataset

**Location**: `/data/ml_user_product_engagement.csv`

**Generated from view**: `user_product_engagement` in MySQL

**Contains**: User-product interaction metrics ready for ML analysis

**Size**: See `/data/README.md` for record counts

### 2. Access the Live Database

**Connection Details**:
```
Host: 127.0.0.1 (from your machine)
Port: 3306
Database: discount_system
User: root
Password: secret  ⚠️ (Change in production)
```

**Connection String** (for Python):
```
mysql+pymysql://root:5@127.0.0.1:3306/discount_system```

**Via MySQL CLI**:
```bash
mysql -h 127.0.0.1 -u root -psecret -D discount_system
```

### 3. Start the Services

```bash
cd discount-system
docker-compose up --build

# Services available at:
# - Flask API: http://localhost:5000
# - MySQL: localhost:3306
```

---

## Schema Documentation for Divya

### Core Tables

#### Table: `users`
Stores user profiles and account information.

| Column | Type | Notes |
|--------|------|-------|
| `user_id` | INT (PK) | Auto-incremented |
| `username` | VARCHAR(100) | Unique identifier |
| `email` | VARCHAR(150) | Unique email |
| `first_name` | VARCHAR(100) | First name |
| `last_name` | VARCHAR(100) | Last name |
| `phone` | VARCHAR(20) | Phone number |
| `country` | VARCHAR(50) | Country of residence |
| `city` | VARCHAR(50) | City |
| `account_type` | ENUM('standard', 'premium', 'vip') | User tier |
| `registration_date` | TIMESTAMP | Signup date |
| `last_login` | TIMESTAMP | Most recent login |
| `is_active` | BOOLEAN | Account status |

**Key Insights for ML**:
- Account type can segment users (VIP vs standard)
- Registration date enables cohort analysis
- Country/city data enables geo-clustering

---

#### Table: `products`
Product catalog with engagement metrics.

| Column | Type | Notes |
|--------|------|-------|
| `product_id` | INT (PK) | Auto-incremented |
| `product_name` | VARCHAR(255) | Product name |
| `category` | VARCHAR(100) | Product category |
| `subcategory` | VARCHAR(100) | Subcategory |
| `description` | TEXT | Product description |
| `price` | DECIMAL(10,2) | Current price |
| `cost` | DECIMAL(10,2) | Cost to company |
| `stock_quantity` | INT | Available stock |
| `rating` | DECIMAL(3,2) | Product rating (0-5) |
| `views` | INT | Page views |
| `clicks` | INT | Number of clicks |
| `searches` | INT | Times searched |

**Key Insights for ML**:
- Views/clicks/searches = user interest metrics
- Rating indicates product quality
- Price points can segment products
- Category enables product recommendations

---

#### Table: `discounts`
Discount campaigns and promotions.

| Column | Type | Notes |
|--------|------|-------|
| `discount_id` | INT (PK) | Auto-incremented |
| `discount_name` | VARCHAR(255) | Campaign name |
| `discount_type` | ENUM('percentage', 'fixed_amount') | Type |
| `discount_value` | DECIMAL(10,2) | % or $ amount |
| `min_purchase_amount` | DECIMAL(10,2) | Minimum cart value |
| `max_discount_amount` | DECIMAL(10,2) | Cap on discount |
| `applicable_category` | VARCHAR(100) | Target category |
| `start_date` | DATE | Campaign start |
| `end_date` | DATE | Campaign end |
| `is_active` | BOOLEAN | Current status |
| `usage_count` | INT | Times applied |
| `max_usage` | INT | Usage limit |

**Key Insights for ML**:
- Usage_count / max_usage = discount effectiveness
- Date ranges enable time-series analysis
- Categories show targeted campaigns

---

#### Table: `purchases`
Complete purchase history with transaction details.

| Column | Type | Notes |
|--------|------|-------|
| `purchase_id` | INT (PK) | Auto-incremented |
| `user_id` | INT (FK) | References users |
| `product_id` | INT (FK) | References products |
| `discount_id` | INT (FK) | References discounts (nullable) |
| `purchase_amount` | DECIMAL(10,2) | Amount spent |
| `quantity` | INT | Units purchased |
| `original_price` | DECIMAL(10,2) | Price before discount |
| `discount_amount` | DECIMAL(10,2) | $ discount given |
| `final_amount` | DECIMAL(10,2) | Amount paid |
| `payment_method` | VARCHAR(50) | Payment type |
| `purchase_date` | TIMESTAMP | When purchased |
| `order_status` | ENUM('pending', 'completed', 'cancelled', 'refunded') | Order state |

**Key Insights for ML**:
- Core transaction data for recommendation engine
- Discount impact on purchase behavior
- Payment methods and order status for risk modeling
- Time-series purchasing patterns

---

### ML-Ready Views

#### View: `user_product_engagement`
**Pre-aggregated user-product interaction metrics**

```sql
SELECT 
    u.user_id, u.username, u.email, u.account_type, u.country,
    p.product_id, p.product_name, p.category, p.price, p.rating,
    COUNT(DISTINCT pu.purchase_id) AS purchase_count,
    SUM(pu.quantity) AS total_quantity,
    AVG(pu.final_amount) AS avg_purchase_amount,
    MAX(pu.purchase_date) AS last_purchase_date,
    SUM(CASE WHEN pu.discount_id IS NOT NULL THEN 1 ELSE 0 END) AS discount_used_count
FROM users u
LEFT JOIN purchases pu ON u.user_id = pu.user_id
LEFT JOIN products p ON pu.product_id = p.product_id
GROUP BY u.user_id, p.product_id;
```

**Columns**:
| Column | Use Case |
|--------|----------|
| `user_id`, `username` | User identification |
| `account_type`, `country` | User segmentation features |
| `product_id`, `product_name`, `category` | Product identification |
| `price`, `rating` | Product features |
| `purchase_count` | Engagement strength |
| `total_quantity` | Volume purchased |
| `avg_purchase_amount` | Spending behavior |
| `last_purchase_date` | Recency (RFM analysis) |
| `discount_used_count` | Price sensitivity |

**Ideal for**: Personalized discount recommendations, product recommendations, user segmentation

---

#### View: `discount_performance`
Metrics on discount effectiveness.

```sql
SELECT 
    d.discount_id, d.discount_name, d.discount_type, d.discount_value,
    d.applicable_category,
    COUNT(DISTINCT pu.purchase_id) AS total_purchases,
    COUNT(DISTINCT pu.user_id) AS unique_users,
    SUM(pu.discount_amount) AS total_discount_given,
    AVG(pu.final_amount) AS avg_transaction_value,
    d.usage_count
FROM discounts d
LEFT JOIN purchases pu ON d.discount_id = pu.discount_id
GROUP BY d.discount_id;
```

**Ideal for**: Discount optimization, ROI analysis, campaign effectiveness

---

#### View: `category_performance`
Category-level engagement and sales metrics.

```sql
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
```

**Ideal for**: Category recommendations, market basket analysis

---

## Exporting Data for ML

### Option 1: Quick CSV Export (Recommended)

```bash
# From repository root
python3 scripts/export_ml.py --out data/ml_user_product_engagement.csv

# Optional: Limit to first N rows
python3 scripts/export_ml.py --out data/ml_sample.csv --limit 5000
```

**Output**: CSV file ready for pandas/sklearn

### Option 2: Export via Flask API

```bash
# Get JSON data from Flask
curl -s "http://localhost:5000/ml-preview?limit=10000" > data/ml_preview.json

# Convert to CSV with Python
python3 << 'EOF'
import json
import csv

with open('data/ml_preview.json', 'r') as f:
    data = json.load(f)

if data:
    with open('data/ml_preview.csv', 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)
    print(f"Exported {len(data)} rows to ml_preview.csv")
EOF
```

### Option 3: Direct MySQL Query

```bash
# SSH to host running MySQL, then:
mysql -u root -psecret discount_system << 'EOF' > ml_data.csv
SELECT * INTO OUTFILE '/tmp/ml_user_product_engagement.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
FROM user_product_engagement;
EOF
```

---

## Data Quality Notes

### Data Coverage

As of 2026-09-13:

```sql
SELECT 
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM products) as total_products,
    (SELECT COUNT(*) FROM discounts) as total_discounts,
    (SELECT COUNT(*) FROM purchases) as total_purchases;
```

### Known Data Patterns

1. **Sample Data**: Dataset includes realistic test data with:
   - Mix of user account types (standard, premium, VIP)
   - Geographic diversity (USA, UK, Canada, Germany, etc.)
   - Multiple product categories
   - Purchase history with discount application

2. **Temporal Patterns**: 
   - Purchases span multiple months
   - Discounts have defined active periods
   - Last_login tracks user activity

3. **Missing Values**:
   - `last_login` may be NULL for inactive users
   - `discount_id` is NULL for full-price purchases
   - Discount effectiveness depends on dataset size

### Data Cleaning Recommendations

```python
import pandas as pd

# Load data
df = pd.read_csv('data/ml_user_product_engagement.csv')

# Check for nulls
print(df.isnull().sum())

# Remove rows with no purchases
df = df[df['purchase_count'] > 0]

# Convert date columns
df['last_purchase_date'] = pd.to_datetime(df['last_purchase_date'])

# Handle outliers (unusual purchase amounts)
df = df[df['avg_purchase_amount'] < df['avg_purchase_amount'].quantile(0.99)]

print(f"Cleaned dataset: {len(df)} rows")
```

---

## Database Access for Divya

### Python Example

```python
from sqlalchemy import create_engine, text

# Connect
engine = create_engine('mysql+pymysql://root:secret@127.0.0.1:3306/discount_system')

# Query
query = text("""
    SELECT user_id, username, account_type, purchase_count, avg_purchase_amount
    FROM user_product_engagement
    WHERE purchase_count > 0
    LIMIT 100
""")

with engine.connect() as conn:
    results = conn.execute(query)
    data = results.fetchall()

# Process
for row in data:
    print(row)
```

### Pandas Example

```python
import pandas as pd
from sqlalchemy import create_engine

engine = create_engine('mysql+pymysql://root:secret@127.0.0.1:3306/discount_system')

# Load entire view into DataFrame
df = pd.read_sql_table('user_product_engagement', engine)

# Or use SQL query
df = pd.read_sql_query(
    "SELECT * FROM user_product_engagement WHERE purchase_count > 0",
    engine
)

print(df.info())
print(df.head())
```

### MySQL CLI

```bash
# Connect
mysql -h 127.0.0.1 -u root -psecret -D discount_system

# View data
mysql> SELECT COUNT(*) FROM user_product_engagement;
mysql> SELECT * FROM user_product_engagement LIMIT 10\G
mysql> EXIT;
```

---

## ML Work Recommendations

### Phase 1: Exploratory Data Analysis
- [ ] Load `user_product_engagement` view into pandas
- [ ] Analyze distribution of purchase patterns
- [ ] Identify user segments by spending
- [ ] Analyze product performance by category
- [ ] Examine discount effectiveness

### Phase 2: Feature Engineering
- [ ] Create RFM (Recency, Frequency, Monetary) features
- [ ] Encode categorical variables (account_type, country, category)
- [ ] Normalize numerical features (prices, purchase amounts)
- [ ] Create time-based features (days since last purchase)
- [ ] Calculate discount sensitivity score

### Phase 3: Model Development
- [ ] Build recommendation engine (collaborative filtering or content-based)
- [ ] Train discount optimization model
- [ ] Evaluate with appropriate metrics (precision@K, MAP, etc.)
- [ ] A/B test results

### Phase 4: Integration
- [ ] Deploy model predictions
- [ ] Add new endpoints to Flask API
- [ ] Monitor model performance
- [ ] Plan retraining schedule

---

## Contact & Support

**Database Concerns**: Contact Guru Aakesh
**Backend Integration**: Contact Divyalakshmi
**ML Requirements**: Divya (that's you!)

---

## Security Notes ⚠️

1. **Don't share credentials publicly** — This is for dev only
2. **Change password before production** — Edit `docker-compose.yml`
3. **Don't commit `.env` files** — Store secrets in environment
4. **API keys in headers** — Add authentication before deploying

---

## Files in This Repository

```
discount-system/
├── README.md                          ← Quick start
├── BACKEND_COORDINATION.md            ← Flask-MySQL setup
├── DATA_HANDOFF.md                    ← This file
├── docker-compose.yml                 ← Service configuration
├── database/
│   ├── schema.sql                     ← Table definitions
│   ├── sample_data.sql                ← Test data
│   ├── sql_operations.sql             ← SQL examples
│   ├── README_EXPORT.md               ← Export methods
│   └── SQL_PRACTICE_GUIDE.md          ← SQL tutorial
├── flask/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── main.py                    ← Flask endpoints
│       └── db.py                      ← Database queries
├── scripts/
│   └── export_ml.py                   ← CSV export tool
└── data/
    └── ml_user_product_engagement.csv ← Your ML dataset
```

---

## Ready to Start?

1. ✅ Start services: `docker-compose up --build`
2. ✅ Export data: `python3 scripts/export_ml.py --out data/ml_user_product_engagement.csv`
3. ✅ Load in Python: `df = pd.read_csv('data/ml_user_product_engagement.csv')`
4. ✅ Explore: `df.head()`, `df.describe()`, `df.info()`
5. ✅ Begin ML work!

Good luck with your analysis! 🚀


# Backend Coordination Guide - Flask & MySQL Integration

This document explains how to connect the Flask service to MySQL, handle database errors, and set up the backend for the discount system.

---

## Overview

**Architecture:**
- **Database**: MySQL 8.0 (runs in Docker container)
- **Backend Framework**: Flask 2.3.2
- **ORM/Query Tool**: SQLAlchemy 2.0.19
- **Database Driver**: PyMySQL 1.1.0

**Flow:**
```
Client Request → Flask App → SQLAlchemy Engine → MySQL Connection → Database → Results → JSON Response
```

---

## Quick Start

### Start Services with Docker Compose

```bash
# Navigate to repo directory
cd discount-system

# Build and start MySQL + Flask
docker-compose up --build

# In another terminal, verify services are running
docker ps
# You should see: discount-system-mysql-1 and discount-system-flask-1
```

### Access the Services

- **Flask Service**: http://localhost:5000
- **MySQL Service**: localhost:3306 (from host), mysql:3306 (from Flask container)
- **Database**: `discount_system`
- **MySQL User**: `root`
- **MySQL Password**: `secret`

---

## Database Connection Configuration

### Connection String (DATABASE_URI)

The Flask app connects using SQLAlchemy connection string:

```
mysql+pymysql://root:secret@mysql:3306/discount_system
```

**Components:**
- `mysql+pymysql://` — Driver specification (MySQL with PyMySQL driver)
- `root:secret` — Username:Password
- `@mysql:3306` — Host:Port (use `mysql` inside containers, `127.0.0.1` from host)
- `discount_system` — Database name

### Environment Variable

Set connection string via `DATABASE_URI` environment variable:

```bash
# In terminal (for local testing)
export DATABASE_URI="mysql+pymysql://root:secret@127.0.0.1:3306/discount_system"
python3 -m flask run

# In docker-compose.yml (already set)
environment:
  DATABASE_URI: "mysql+pymysql://root:secret@mysql:3306/discount_system"
```

### Default Connection (Fallback)

If `DATABASE_URI` is not set, the app uses:

```python
# From flask/app/db.py
DEFAULT_DB = 'mysql+pymysql://root:secret@127.0.0.1:3306/discount_system'
```

---

## Flask Application Structure

### Main Entry Point: `flask/app/main.py`

```python
from flask import Flask, jsonify, request
from .db import get_user_product_engagement

app = Flask(__name__)

@app.route('/')
def index():
    """Health check endpoint"""
    return jsonify({"status": "ok", "message": "Discount System Flask service"})

@app.route('/ml-preview')
def ml_preview():
    """Preview ML-ready user-product engagement data"""
    try:
        limit = int(request.args.get('limit', 200))
    except ValueError:
        limit = 200
    data = get_user_product_engagement(limit=limit)
    return jsonify(data)
```

### Database Module: `flask/app/db.py`

```python
import os
from sqlalchemy import create_engine, text

# Get connection string from environment or use default
DATABASE_URI = os.getenv('DATABASE_URI', 'mysql+pymysql://root:secret@127.0.0.1:3306/discount_system')

# Create engine for connection pooling
engine = create_engine(DATABASE_URI, echo=False, future=True)

def get_user_product_engagement(limit=200):
    """Fetch user-product engagement data from the database"""
    query = text("""
        SELECT user_id, username, email, account_type, country, 
               product_id, product_name, category, price, rating,
               purchase_count, total_quantity, avg_purchase_amount, 
               last_purchase_date, discount_used_count
        FROM user_product_engagement
        LIMIT :limit
    """)
    with engine.connect() as conn:
        rows = conn.execute(query, {"limit": limit}).all()
    
    # Convert to list of dicts for JSON serialization
    cols = [c for c in rows[0].keys()] if rows else []
    return [dict(zip(cols, r)) for r in rows]
```

---

## Common Endpoints

### 1. Health Check

**Endpoint**: `GET /`

**Response**:
```json
{
  "status": "ok",
  "message": "Discount System Flask service"
}
```

**Usage**:
```bash
curl http://localhost:5000/
```

### 2. ML Data Preview

**Endpoint**: `GET /ml-preview?limit=200`

**Response** (sample):
```json
[
  {
    "user_id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "account_type": "premium",
    "country": "USA",
    "product_id": 5,
    "product_name": "Laptop Pro",
    "category": "Electronics",
    "price": "1299.99",
    "rating": "4.8",
    "purchase_count": 2,
    "total_quantity": 2,
    "avg_purchase_amount": "974.99",
    "last_purchase_date": "2024-08-15",
    "discount_used_count": 1
  },
  ...
]
```

**Parameters**:
- `limit` (optional, default=200): Max number of records to return

**Usage**:
```bash
# Default limit (200)
curl http://localhost:5000/ml-preview

# Custom limit
curl "http://localhost:5000/ml-preview?limit=50"

# Pretty-print JSON
curl -s http://localhost:5000/ml-preview | python3 -m json.tool
```

---

## Error Handling

### Connection Errors

**Symptom**: `sqlalchemy.exc.OperationalError: (pymysql.err.OperationalError)`

**Common Causes**:
1. MySQL service not running
2. Wrong hostname (use `mysql` in Docker, `127.0.0.1` locally)
3. Wrong port (default 3306)
4. Database doesn't exist
5. Invalid credentials

**Fix**:
```bash
# Check if MySQL is running
docker ps

# Restart services
docker-compose down
docker-compose up --build

# Test connection manually
docker exec -it discount-system-mysql-1 mysql -u root -psecret -D discount_system
```

### Missing Table/View

**Symptom**: `pymysql.err.ProgrammingError: (1146, "Table 'discount_system.user_product_engagement' doesn't exist")`

**Cause**: Database schema hasn't been initialized

**Fix**:
```bash
# Ensure schema.sql was loaded (docker-compose does this automatically)
docker-compose down -v  # Remove volumes
docker-compose up --build  # Rebuild (schema re-initializes)
```

### Invalid SQL Query

**Symptom**: `pymysql.err.ProgrammingError: (1064, "You have an error in your SQL syntax")`

**Cause**: SQL syntax error in the query

**Fix**:
1. Review SQL in `flask/app/db.py`
2. Test query directly in MySQL:
   ```bash
   docker exec -it discount-system-mysql-1 mysql -u root -psecret -D discount_system
   mysql> SELECT * FROM user_product_engagement LIMIT 1;
   ```

### Authentication Failed

**Symptom**: `pymysql.err.OperationalError: (1045, "Access denied for user 'root'@'...'"`

**Cause**: Wrong username or password

**Fix**:
```bash
# Check credentials in docker-compose.yml
# Update DATABASE_URI if needed
docker-compose down
docker-compose up --build
```

---

## Adding New Endpoints

### Example: Get User by ID

```python
# Add to flask/app/main.py

from flask import Flask, jsonify, request
from .db import get_user_product_engagement

@app.route('/user/<int:user_id>')
def get_user(user_id):
    """Get user details by ID"""
    from sqlalchemy import text
    from .db import engine
    
    query = text("""
        SELECT user_id, username, email, account_type, country, 
               registration_date, last_login, is_active
        FROM users
        WHERE user_id = :user_id
    """)
    
    with engine.connect() as conn:
        result = conn.execute(query, {"user_id": user_id}).fetchone()
    
    if result:
        cols = result.keys()
        return jsonify(dict(zip(cols, result)))
    else:
        return jsonify({"error": "User not found"}), 404
```

**Test**:
```bash
curl http://localhost:5000/user/1
```

### Example: Get Purchase History

```python
# Add to flask/app/main.py

@app.route('/user/<int:user_id>/purchases')
def get_user_purchases(user_id):
    """Get all purchases by a user"""
    from sqlalchemy import text
    from .db import engine
    
    query = text("""
        SELECT 
            pu.purchase_id, pu.purchase_date, 
            p.product_name, pu.quantity, pu.final_amount,
            d.discount_name
        FROM purchases pu
        LEFT JOIN products p ON pu.product_id = p.product_id
        LEFT JOIN discounts d ON pu.discount_id = d.discount_id
        WHERE pu.user_id = :user_id
        ORDER BY pu.purchase_date DESC
    """)
    
    with engine.connect() as conn:
        rows = conn.execute(query, {"user_id": user_id}).all()
    
    cols = [c for c in rows[0].keys()] if rows else []
    return jsonify([dict(zip(cols, r)) for r in rows])
```

**Test**:
```bash
curl http://localhost:5000/user/1/purchases
```

---

## Deployment Considerations

### For Production

1. **Change MySQL Password**:
   - Edit `docker-compose.yml`
   - Change `MYSQL_ROOT_PASSWORD: secret` to a strong password
   - Update `DATABASE_URI` in `environment`

2. **Enable Error Logging**:
   ```python
   # In flask/app/db.py
   engine = create_engine(DATABASE_URI, echo=True, future=True)  # For debug
   ```

3. **Add Connection Pooling**:
   ```python
   from sqlalchemy.pool import QueuePool
   engine = create_engine(
       DATABASE_URI,
       poolclass=QueuePool,
       pool_size=10,
       max_overflow=20
   )
   ```

4. **Use Environment Files**:
   ```bash
   # Create .env file
   DATABASE_URI=mysql+pymysql://prod_user:strong_password@prod_host:3306/discount_system
   FLASK_ENV=production
   ```

5. **Enable CORS for Frontend**:
   ```python
   from flask_cors import CORS
   app = Flask(__name__)
   CORS(app)  # Allow cross-origin requests
   ```

---

## Testing the Backend

### Test 1: MySQL Connection

```bash
# Connect to MySQL directly
docker exec -it discount-system-mysql-1 mysql -u root -psecret -D discount_system

# Run a query
mysql> SELECT COUNT(*) as user_count FROM users;
mysql> SELECT COUNT(*) as product_count FROM products;
mysql> EXIT;
```

### Test 2: Flask API

```bash
# Test health check
curl http://localhost:5000/

# Test ML preview endpoint
curl -s http://localhost:5000/ml-preview | python3 -m json.tool | head -30

# Count records returned
curl -s "http://localhost:5000/ml-preview?limit=1000" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))"
```

### Test 3: Docker Logs

```bash
# View Flask logs
docker logs discount-system-flask-1 -f

# View MySQL logs (in another terminal)
docker logs discount-system-mysql-1 -f
```

---

## Coordination Checklist

Before Divya starts ML work, ensure:

- [ ] MySQL service is running and populated with sample data
- [ ] Flask service is running and responding to requests
- [ ] `/ml-preview` endpoint returns expected data structure
- [ ] `user_product_engagement` view exists and has data
- [ ] Database connection credentials are documented and secure
- [ ] Error logs are clean (no connection errors)
- [ ] Backend can export data to CSV (scripts/export_ml.py works)
- [ ] Frontend team has access to API documentation

---

## Questions for Backend Team

1. **Should we cache ML preview data?** (For large datasets, consider Redis)
2. **Do we need pagination?** (For >100k rows, implement cursor-based pagination)
3. **Should we add data filtering?** (E.g., `/ml-preview?category=Electronics`)
4. **What's the refresh rate?** (Real-time or batch updates?)
5. **Do we need authentication?** (For production APIs, add API keys/JWT)

---

## Useful Commands

```bash
# Restart services
docker-compose restart

# View service logs
docker-compose logs -f

# Stop services
docker-compose down

# Remove all data (clean slate)
docker-compose down -v

# Execute command in MySQL container
docker exec -it discount-system-mysql-1 mysql -u root -psecret -D discount_system

# Execute command in Flask container
docker exec -it discount-system-flask-1 /bin/bash
```


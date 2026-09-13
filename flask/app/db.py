import os
from sqlalchemy import create_engine, text

DATABASE_URI = os.getenv('DATABASE_URI', 'mysql+pymysql://root:secret@127.0.0.1:3306/discount_system')

engine = create_engine(DATABASE_URI, echo=False, future=True)

def get_user_product_engagement(limit=200):
    query = text(
        """
        SELECT user_id, username, email, account_type, country, product_id, product_name, category, price, rating,
               purchase_count, total_quantity, avg_purchase_amount, last_purchase_date, discount_used_count
        FROM user_product_engagement
        LIMIT :limit
        """
    )
    with engine.connect() as conn:
        rows = conn.execute(query, {"limit": limit}).all()
    # Convert to list of dicts
    cols = [c for c in rows[0].keys()] if rows else []
    return [dict(zip(cols, r)) for r in rows]

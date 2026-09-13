"""
Simple ML export script for the discount_system repository.

Usage:
  python scripts/export_ml.py --out data/ml_user_product_engagement.csv

It reads the DATABASE_URI environment variable or falls back to a default local connection.
"""
import os
import csv
import argparse
from sqlalchemy import create_engine, text

DEFAULT_DB = 'mysql+pymysql://root:secret@127.0.0.1:3306/discount_system'

def export_ml_view(outpath, uri=None, limit=None):
    uri = uri or os.getenv('DATABASE_URI') or DEFAULT_DB
    engine = create_engine(uri, future=True)
    q = "SELECT * FROM user_product_engagement"
    if limit:
        q += f" LIMIT {int(limit)}"
    query = text(q)
    with engine.connect() as conn:
        result = conn.execute(query)
        cols = result.keys()
        rows = result.fetchall()

    os.makedirs(os.path.dirname(outpath), exist_ok=True)
    with open(outpath, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(cols)
        for r in rows:
            writer.writerow(list(r))

    print(f"Wrote {len(rows)} rows to {outpath}")

if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--out', '-o', required=True, help='Output CSV file path')
    p.add_argument('--db', '-d', help='Database URI (overrides env)')
    p.add_argument('--limit', '-n', help='Limit rows exported')
    args = p.parse_args()
    export_ml_view(args.out, uri=args.db, limit=args.limit)

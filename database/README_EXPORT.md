# Exporting ML-ready datasets

This file explains how to export the ML views included in the schema.

Options:

1) Client-side CSV export (recommended for local development)

- Use the provided Python script:

  python3 scripts/export_ml.py --out data/ml_user_product_engagement.csv

- The script uses the DATABASE_URI environment variable if present, otherwise it connects to
  mysql+pymysql://root:secret@127.0.0.1:3306/discount_system by default. Change the URI for your environment.

2) Server-side INTO OUTFILE (requires file system access on the DB server)

  SELECT * FROM user_product_engagement
  INTO OUTFILE '/tmp/ml_user_product_engagement.csv'
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

Note: INTO OUTFILE writes files on the database server host and requires FILE privileges. For most development scenarios the client-side export script above is safer.

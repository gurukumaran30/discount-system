# Personalized Discount Recommendation System

This project uses MySQL to store users, products, discounts and purchase information.

## Quick dev environment (Docker)

The repository now includes a docker-compose configuration and a minimal Flask service to preview ML data.

1. Start the services (builds the Flask image):

   docker-compose up --build

   - The MySQL service initializes the database using the SQL files in ./database (schema.sql + sample_data.sql).
   - The Flask service will be available at http://localhost:5000 once started.

2. Preview ML data from the browser or curl:

   curl http://localhost:5000/ml-preview

3. Export the ML-ready view to CSV (from the host):

   python3 scripts/export_ml.py --out data/ml_user_product_engagement.csv

Notes:
- The docker-compose uses a placeholder root password `secret`. Change it before using in shared or production environments.
- The Flask service reads DATABASE_URI from the environment; docker-compose sets it to connect to the mysql service.

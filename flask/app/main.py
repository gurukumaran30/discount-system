from flask import Flask, jsonify, request
from .db import get_user_product_engagement

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({"status": "ok", "message": "Discount System Flask service"})

@app.route('/ml-preview')
def ml_preview():
    try:
        limit = int(request.args.get('limit', 200))
    except ValueError:
        limit = 200
    data = get_user_product_engagement(limit=limit)
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

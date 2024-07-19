from flask import Flask, request, jsonify
import mysql.connector
import logging
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # This will enable CORS for all routes

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

try:
    db = mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="plant_disease"
    )
    logger.info("Database connection established")
except mysql.connector.Error as err:
    logger.error(f"Error connecting to the database: {err}")

@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        username = data['username']
        password = data['password']

        cursor = db.cursor()
        cursor.execute("SELECT * FROM users WHERE username=%s AND password=%s", (username, password))
        user = cursor.fetchone()

        if user:
            return jsonify({'message': 'Login successful!'}), 200
        else:
            return jsonify({'message': 'Invalid credentials'}), 401
    except Exception as e:
        logger.error(f"Error in /login route: {e}")
        return jsonify({'message': 'An error occurred during login'}), 500

@app.route('/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        logger.info(f"Data received: {data}")
        username = data['username']
        email = data['email']
        password = data['password']

        cursor = db.cursor()
        cursor.execute("INSERT INTO users (username, email, password) VALUES (%s, %s, %s)", (username, email, password))
        db.commit()

        return jsonify({'message': 'User registered successfully!'}), 201
    except Exception as e:
        logger.error(f"Error in /register route: {e}")
        return jsonify({'message': 'An error occurred during registration'}), 500

if __name__ == '__main__':
    app.run(debug=True)

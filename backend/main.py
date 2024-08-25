from flask import Flask, request, jsonify, session, make_response
import mysql.connector
import logging
from flask_cors import CORS
from datetime import timedelta

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # Set a secret key for session management
app.permanent_session_lifetime = timedelta(hours=1)  # Set session lifetime

# Enable CORS for all routes and support credentials
CORS(app, supports_credentials=True)

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
            session['user'] = username
            response = make_response(jsonify({'message': 'Login successful!', 'username': username}))
            return response
        else:
            return jsonify({'message': 'Invalid credentials'}), 401
    except Exception as e:
        logger.error(f"Error in /login route: {e}")
        return jsonify({'message': 'An error occurred during login'}), 500

@app.route('/logout', methods=['POST'])
def logout():
    session.pop('user', None)  # Remove the user from the session
    response = make_response(jsonify({'message': 'Logged out successfully!'}))
    return response

@app.route('/check_session', methods=['GET'])
def check_session():
    if 'user' in session:
        return jsonify({'logged_in': True, 'user': session['user']}), 200
    else:
        return jsonify({'logged_in': False}), 401

@app.route('/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
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


# Dummy disease prediction function
def predict_disease(image_path):
    # Implement your image processing and prediction logic here
    return 'Example Disease'


@app.route('/predict_disease', methods=['POST'])
def predict_disease_route():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    image = request.files['image']
    # Save image and perform disease prediction
    disease = predict_disease(image.filename)  # You should process the image
    return jsonify({'disease': disease})


@app.route('/save_disease_info', methods=['POST'])
def save_disease_info():
    try:
        data = request.get_json()
        disease = data['disease']
        info = data['info']

        # Implement database saving logic here
        # For example, save to a 'disease_info' table

        return jsonify({'message': 'Disease information saved successfully!'}), 200
    except Exception as e:
        logger.error(f"Error saving disease info: {e}")
        return jsonify({'message': 'An error occurred while saving information'}), 500


if __name__ == '__main__':
    app.run(debug=True)

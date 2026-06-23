import dlib
import cv2
import numpy as np
import joblib
import mysql.connector
import datetime

from flask import Flask, request, jsonify
from jose import JWTError, jwt

# =====================================================
# CONFIG
# =====================================================

SHAPE_PREDICTOR = "shape_predictor_68_face_landmarks.dat"
FACE_RECOG_MODEL = "dlib_face_recognition_resnet_model_v1.dat"

SECRET_KEY = "sistem_tilang_secret"

DISTANCE_THRESHOLD = 0.45

# =====================================================
# LOAD MODEL
# =====================================================

detector = dlib.get_frontal_face_detector()

predictor = dlib.shape_predictor(
    SHAPE_PREDICTOR
)

face_rec_model = dlib.face_recognition_model_v1(
    FACE_RECOG_MODEL
)

knn = joblib.load(
    "knn_model.pkl"
)

le = joblib.load(
    "label_encoder.pkl"
)

X_train = np.load(
    "face_encoding.npy"
)

N_NEIGHBORS = min(
    3,
    len(X_train)
)

# =====================================================
# MYSQL
# =====================================================

def get_connection():

    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",  # sesuaikan
        database="sistem_tilang"
    )

# =====================================================
# USER
# =====================================================

def get_user_by_face_label(face_label):

    conn = get_connection()

    cursor = conn.cursor(
        dictionary=True
    )

    cursor.execute(
        """
        SELECT *
        FROM users
        WHERE face_label=%s
        LIMIT 1
        """,
        (face_label,)
    )

    user = cursor.fetchone()

    cursor.close()
    conn.close()

    return user

# =====================================================
# JWT
# =====================================================

def generate_token(user_id):

    payload = {
        "id": user_id,
        "exp": datetime.datetime.utcnow()
            + datetime.timedelta(days=7)
    }

    token = jwt.encode(
        payload,
        SECRET_KEY,
        algorithm="HS256"
    )

    return token

def verify_token(token):

    try:

        payload = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=["HS256"]
        )

        return payload["id"]

    except JWTError:

        return None

# =====================================================
# FACE ENCODING
# =====================================================

def get_face_encoding(image, face):

    shape = predictor(
        image,
        face
    )

    return np.array(
        face_rec_model.compute_face_descriptor(
            image,
            shape
        )
    )

# =====================================================
# FACE RECOGNITION
# =====================================================

def get_best_face_result(
    rgb_image,
    faces
):

    results = []

    for face in faces:

        encoding = get_face_encoding(
            rgb_image,
            face
        )

        encoding_2d = encoding.reshape(
            1,
            -1
        )

        pred_encoded = knn.predict(
            encoding_2d
        )[0]

        pred_name = le.inverse_transform(
            [pred_encoded]
        )[0]

        distances, indices = knn.kneighbors(
            encoding_2d,
            n_neighbors=N_NEIGHBORS
        )

        nearest_distance = float(
            distances[0][0]
        )

        confidence = (
            1 /
            (1 + nearest_distance)
        )

        label = (
            pred_name
            if nearest_distance <= DISTANCE_THRESHOLD
            else "Unknown"
        )

        result = {

            "label":
            label,

            "predicted_name":
            pred_name,

            "confidence":
            round(
                float(confidence),
                4
            ),

            "confidence_percent":
            round(
                float(
                    confidence * 100
                ),
                2
            ),

            "distance":
            round(
                nearest_distance,
                4
            ),

            "threshold":
            DISTANCE_THRESHOLD

        }

        results.append(result)

        print(
            "================================="
        )

        print(
            "Prediksi:",
            pred_name
        )

        print(
            "Distance:",
            nearest_distance
        )

        print(
            "Confidence:",
            confidence
        )

        print(
            "Label:",
            label
        )

        print(
            "================================="
        )

    best_result = min(
        results,
        key=lambda x: x["distance"]
    )

    return best_result, results

# =====================================================
# FLASK
# =====================================================

app = Flask(__name__)

# =====================================================
# HEALTH CHECK
# =====================================================

@app.route("/", methods=["GET"])
def health_check():

    return jsonify({

        "status": "ok",

        "message":
        "Face Recognition API Running",

        "labels":
        list(le.classes_),

        "distance_threshold":
        DISTANCE_THRESHOLD,

        "total_training_data":
        int(len(X_train))

    })

# =====================================================
# RECOGNIZE FACE
# =====================================================

@app.route(
    "/recognize-face",
    methods=["POST"]
)
def recognize_face():

    try:

        if "image" not in request.files:

            return jsonify({

                "status":"fail",

                "message":
                "Field image diperlukan"

            }),400

        file = request.files["image"]

        img_array = np.asarray(
            bytearray(
                file.read()
            ),
            dtype=np.uint8
        )

        image = cv2.imdecode(
            img_array,
            cv2.IMREAD_COLOR
        )

        if image is None:

            return jsonify({

                "status":"fail",

                "message":
                "Gambar tidak valid"

            }),400

        rgb = cv2.cvtColor(
            image,
            cv2.COLOR_BGR2RGB
        )

        rgb = np.ascontiguousarray(
            rgb,
            dtype=np.uint8
        )

        faces = detector(rgb)

        if len(faces) == 0:

            return jsonify({

                "status":"fail",

                "message":
                "Tidak ada wajah terdeteksi"

            }),400

        best_result, results = (
            get_best_face_result(
                rgb,
                faces
            )
        )

        if best_result["label"] == "Unknown":

            return jsonify({

                "status":"fail",

                "message":
                "Wajah tidak dikenali",

                "faces":
                results

            }),401

        user = get_user_by_face_label(
            best_result["label"]
        )

        if not user:

            return jsonify({

                "status":"fail",

                "message":
                "User tidak ditemukan"

            }),404
        
        token = generate_token(
            user["id"]
        )

        return jsonify({

            "status":"success",

            "message":
            "Wajah berhasil dikenali",

            "token":
                token,

            "user":{

                "id":
                    user["id"],

                "name":
                    user["name"],

                "email":
                    user["email"],

                "face_label":
                    user["face_label"]

            },

            "confidence":
                best_result["confidence"],

            "confidence_percent":
                best_result[
                    "confidence_percent"
                ],

            "distance":
                best_result["distance"]

        }),200

    except Exception as e:

        print("ERROR:", str(e))

        return jsonify({

            "status":"error",

            "message":
            str(e)

        }),500

# =====================================================
# MAIN
# =====================================================

if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )
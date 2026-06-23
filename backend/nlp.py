import json
import pickle
import random
import numpy as np

from flask import Flask
from flask import request
from flask import jsonify

from tensorflow.keras.models import load_model

from tensorflow.keras.preprocessing.sequence import (
    pad_sequences
)

# ==========================================
# LOAD FILE
# ==========================================

model = load_model(
    "intent_model.keras"
)

with open(
    "tokenizer.pkl",
    "rb"
) as f:

    tokenizer = pickle.load(f)

with open(
    "label_encoder.pkl",
    "rb"
) as f:

    encoder = pickle.load(f)

with open(
    "max_len.pkl",
    "rb"
) as f:

    max_len = pickle.load(f)

with open(
    "dataset.json",
    "r",
    encoding="utf-8"
) as f:

    dataset = json.load(f)

# ==========================================
# FLASK
# ==========================================

app = Flask(__name__)

# ==========================================
# GET RESPONSE
# ==========================================

def get_response(intent):

    for item in dataset["intents"]:

        if item["tag"] == intent:

            return random.choice(
                item["responses"]
            )

    return (
        "Maaf, saya tidak memahami pertanyaan tersebut."
    )

# ==========================================
# PREDICT
# ==========================================

def predict_intent(message):

    sequence = tokenizer.texts_to_sequences(
            [message.lower()]
        )

    padded = pad_sequences(
            sequence,
            maxlen=max_len,
            padding="post"
        )

    prediction = model.predict(
            padded,
            verbose=0
        )

    confidence = float(
            np.max(prediction)
        )

    intent_index = np.argmax(
            prediction
        )

    intent = encoder.inverse_transform(
            [intent_index]
        )[0]

    return (
        intent,
        confidence
    )

# ==========================================
# HEALTH CHECK
# ==========================================

@app.route(
    "/",
    methods=["GET"]
)
def home():

    return jsonify({

        "status":
        "ok",

        "message":
        "NLP API Running",

        "classes":
        encoder.classes_.tolist()

    })

# ==========================================
# CHAT
# ==========================================

@app.route(
    "/chat",
    methods=["POST"]
)
def chat():

    try:

        data = request.get_json()

        message = data.get(
                "message",
                ""
            )

        if not message:

            return jsonify({

                "response":
                "Silakan masukkan pertanyaan."

            })

        intent, confidence = predict_intent(
                message
            )

        if confidence < 0.50:

            return jsonify({

                "intent":
                "unknown",

                "confidence":
                confidence,

                "response":
                "Maaf, saya belum memahami pertanyaan tersebut."

            })

        response = get_response(
                intent
            )

        return jsonify({

            "intent":
            intent,

            "confidence":
            round(
                confidence,
                4
            ),

            "response":
            response

        })

    except Exception as e:

        return jsonify({

            "error":
            str(e)

        }),500

# ==========================================
# MAIN
# ==========================================

if __name__ == "__main__":

    app.run(

        host="0.0.0.0",

        port=8000,

        debug=True

    )
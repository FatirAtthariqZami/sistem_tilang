import json
import pickle
import numpy as np

from sklearn.preprocessing import LabelEncoder

from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import (
    Embedding,
    LSTM,
    Dense,
    Dropout
)
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
from tensorflow.keras.utils import to_categorical

# ==========================================
# LOAD DATASET
# ==========================================

with open(
    "dataset.json",
    "r",
    encoding="utf-8"
) as f:

    data = json.load(f)

texts = []
labels = []

for intent in data["intents"]:

    tag = intent["tag"]

    for pattern in intent["patterns"]:

        texts.append(
            pattern.lower()
        )

        labels.append(
            tag
        )

# ==========================================
# TOKENIZER
# ==========================================

tokenizer = Tokenizer(
    oov_token="<OOV>"
)

tokenizer.fit_on_texts(
    texts
)

sequences = tokenizer.texts_to_sequences(
    texts
)

max_len = max(
    len(seq)
    for seq in sequences
)

X = pad_sequences(
    sequences,
    maxlen=max_len,
    padding="post"
)

# ==========================================
# LABEL ENCODER
# ==========================================

encoder = LabelEncoder()

y = encoder.fit_transform(
    labels
)

y = to_categorical(y)

# ==========================================
# MODEL
# ==========================================

vocab_size = len(
    tokenizer.word_index
) + 1

num_classes = len(
    encoder.classes_
)

model = Sequential([

    Embedding(
        input_dim=vocab_size,
        output_dim=64,
        input_length=max_len
    ),

    LSTM(
        64
    ),

    Dropout(
        0.3
    ),

    Dense(
        64,
        activation="relu"
    ),

    Dense(
        num_classes,
        activation="softmax"
    )

])

model.compile(

    optimizer="adam",

    loss=
    "categorical_crossentropy",

    metrics=["accuracy"]

)

model.summary()

# ==========================================
# TRAIN
# ==========================================

model.fit(

    X,
    y,

    epochs=300,

    batch_size=8,

    verbose=1

)

# ==========================================
# SAVE MODEL
# ==========================================

model.save(
    "intent_model.keras"
)

with open(
    "tokenizer.pkl",
    "wb"
) as f:

    pickle.dump(
        tokenizer,
        f
    )

with open(
    "label_encoder.pkl",
    "wb"
) as f:

    pickle.dump(
        encoder,
        f
    )

with open(
    "max_len.pkl",
    "wb"
) as f:

    pickle.dump(
        max_len,
        f
    )

print(
    "\nMODEL BERHASIL DISIMPAN"
)

print(
    "Classes:"
)

print(
    encoder.classes_
)
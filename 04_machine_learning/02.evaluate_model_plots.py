#!/usr/bin/env python3

import os
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import confusion_matrix, classification_report, ConfusionMatrixDisplay
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import ImageDataGenerator

# === CONFIG ===
model_path = "coat_color_model.h5"
val_dir = "val"
IMG_SIZE = (256, 256)
BATCH_SIZE = 32
# ==============

print("📦 Loading model...")
model = load_model(model_path)
print("✅ Model loaded!")

# Load validation data
datagen = ImageDataGenerator(rescale=1./255)
val_data = datagen.flow_from_directory(
    val_dir,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    shuffle=False
)

y_true = val_data.classes
y_probs = model.predict(val_data)
y_pred = np.argmax(y_probs, axis=1)

# Get only labels actually present in y_true
from collections import Counter
labels_in_val = sorted(list(set(y_true)))
class_indices = val_data.class_indices
inv_map = {v: k for k, v in class_indices.items()}
present_class_names = [inv_map[i] for i in labels_in_val]

# Confusion matrix
cm = confusion_matrix(y_true, y_pred, labels=labels_in_val)
disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=present_class_names)

fig, ax = plt.subplots(figsize=(12, 12))
disp.plot(cmap='Blues', xticks_rotation=45, ax=ax)
plt.title("Confusion Matrix")
plt.tight_layout()
plt.savefig("confusion_matrix.png")
print("📊 Saved: confusion_matrix.png")

# Classification report
print("🧾 Classification Report:")
report = classification_report(y_true, y_pred, target_names=present_class_names, labels=labels_in_val)
print(report)

with open("classification_report.txt", "w") as f:
    f.write(report)
print("📄 Saved: classification_report.txt")


#!/usr/bin/env python3

import matplotlib.pyplot as plt

# File path
log_file = "train_model.log"

# Lists to hold parsed values
train_loss = []
val_loss = []
train_acc = []
val_acc = []

# Read and clean the log file
with open(log_file, "r") as f:
    for line in f:
        if " - loss:" in line and "accuracy:" in line and "val_loss:" in line and "val_accuracy:" in line:
            # Clean up weird characters like backspaces
            clean_line = line.encode("ascii", "ignore").decode().strip()
            parts = clean_line.split(" - ")
            for part in parts:
                if part.startswith("loss:"):
                    train_loss.append(float(part.split(":")[1].strip()))
                elif part.startswith("accuracy:"):
                    train_acc.append(float(part.split(":")[1].strip()))
                elif part.startswith("val_loss:"):
                    val_loss.append(float(part.split(":")[1].strip()))
                elif part.startswith("val_accuracy:"):
                    val_acc.append(float(part.split(":")[1].strip()))

# Plot accuracy
plt.figure()
plt.plot(train_acc, label="Train Accuracy")
plt.plot(val_acc, label="Validation Accuracy")
plt.xlabel("Epoch")
plt.ylabel("Accuracy")
plt.title("Model Accuracy")
plt.legend()
plt.savefig("accuracy_plot.png", dpi=300)
print("Saved: accuracy_plot.png")

# Plot loss
plt.figure()
plt.plot(train_loss, label="Train Loss")
plt.plot(val_loss, label="Validation Loss")
plt.xlabel("Epoch")
plt.ylabel("Loss")
plt.title("Model Loss")
plt.legend()
plt.savefig("loss_plot.png", dpi=300)
print("Saved: loss_plot.png")


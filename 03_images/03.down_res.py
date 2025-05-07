#!/usr/bin/env python3
import os
import cv2
from PIL import Image

# Crop and resize settings
crop_bottom = 100
crop_sides = 150
target_size = (256, 256)
base_dir = os.getcwd()

def process_image(path):
    img = cv2.imread(path)
    if img is None:
        return None
    h, w = img.shape[:2]
    if h <= crop_bottom or w <= 2 * crop_sides:
        return None
    cropped = img[:h - crop_bottom, crop_sides:w - crop_sides]
    resized = cv2.resize(cropped, target_size)
    return Image.fromarray(cv2.cvtColor(resized, cv2.COLOR_BGR2RGB))

# Loop through species folders
for species in os.listdir(base_dir):
    species_path = os.path.join(base_dir, species)
    downres_path = os.path.join(species_path, "down_res")
    if not os.path.isdir(downres_path):
        continue

    print(f"☼ Processing: {species}/down_res")

    # Recursively walk through down_res
    for root, _, files in os.walk(downres_path):
        for fname in files:
            if not fname.lower().endswith((".jpg", ".jpeg", ".png")):
                continue
            fpath = os.path.join(root, fname)
            try:
                img_out = process_image(fpath)
                if img_out:
                    img_out.save(fpath)
                    print(f"  ☼ Processed: {fpath}")
                else:
                    print(f"  ERROR: Skipped (invalid size): {fpath}")
            except Exception as e:
                print(f"  ERROR: processing {fpath}: {e}")


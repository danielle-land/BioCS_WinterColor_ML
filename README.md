# Utilizing Machine Learning to Score Coat Colors from GBIF Images for Mammals and Birds that Turn White in the Winter

## About
**This project is for the KU Spring 2025 course _"Computer Science for Biology"_ (BIOL 505) taught by Dr. Jocelyn Colella.**  
The goal is to create the framework for a machine learning model that analyzes human observation images from GBIF (mainly iNaturalist) to classify whether an individual is **"brown"**, **"white"**, or **"molting"** during the winter season.

---

## Steps

### 1. **Download GBIF Data via API**
- **Relevant script:** `01_download_GBIF_data/01.download_GBIF_data.sh`
- Prompts for:
  - Species (e.g., `Mustela nivalis, Mustela erminia, Mustela richardsonii, Vulpes lagopus, Lagopus leucura, Lagopus lagopus, Lagopus muta, Lepus americanus`)
  - Taxon keys (e.g., `5218987, 5219019, 9134203, 5219303, 5227717, 2473421, 5227679, 2436794`)
  - User info (username, email, password)
  - Query customization via `query.json`:
    - e.g., BasisOfRecord = HumanObservation, MediaType = Image, Month = 1,2,12
- Downloads species data into species-specific folders.

---

### 2. **Clean Data**
- **Scripts (in `02_clean_GBIF_data/`)**:
  - `01.GBIF_mm_duplicatesRemoved.sh`
    - Uses files from `01_download_GBIF_data/`
    - Outputs in the current or subdirectory
    - Keeps only one image per record
  - `02.GBIF_combine_mm_occ.sh`
    - Combines `species_multimedia.txt` and `species_occurrence.txt`
    - Includes occurrence metadata and image links
  - `03.GBIF_erminia_correct.sh`
    - Moves *M. erminia* North American records into *M. richardsonii*
    - Removes them from the original file

---

### 3. **Download, Rename, and Resize All Images**
- **Scripts (in `03_images/`)**:
  - `01.GBIF_download_images.sh`
    - Creates species folders
    - Downloads images using URLs
    - Names images using GBIF ID
  - `02.sort_images_fixed.sh`
    - Run **after manual scoring** (see below)
    - Moves images into `train/`, `val/`, and `test/` folders (80/10/10 split)
    - Organizes into a folder called `down_res/`
  - `03.down_res.py` (run via `03.RUN_down_res.sh`)
    - Crops and downsamples images to standardized size

---

### 4. **Run Scored Images Through a Transferred ML Model**
- **Script:** `04_machine_learning/01.model_transfer_learning.py` (run via `01.RUN_model.sh`)
- Applies transfer learning with MobileNetV2 to classify coat color

---

### 5. **Visualize Model Efficiency**
- **Scripts (in `04_machine_learning/`)**:
  - `02.evaluate_model_plots.py`
    - Creates a confusion matrix
  - `03.plot_training_history.py`
    - Plots model accuracy and loss over time

---

## **Scoring Images**
- All images must be centered and contain **only one animal**
- Use the following standardized categories:
  - `White`
  - `Brown`
  - `Molting`
  - `Other` (e.g., tracks, unclear images, multiple individuals)

---

## **Modeling**
- Dataset split (by species & coat color: 33 categories):
  - 80% training
  - 10% validation
  - 10% testing
- **Model Architecture:**
  - **Base:** MobileNetV2 (pretrained on ImageNet, frozen)
  - **Custom top layers:**  
    `GlobalAveragePooling2D → Dense(128, ReLU) → Dense(num_classes, Softmax)`
- **Optimizer:** Adam (`lr=1e-4`)
- **Loss Function:** Categorical Crossentropy
- **Data Augmentation:** Horizontal flip, random rotation

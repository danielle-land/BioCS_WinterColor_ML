# Utilizing machine learning to score coat colors from GBIF images for mammals and birds that turn white in the winter
## About:
==This project is for the KU Spring 2025 course "Computer Science for Biology" (BIOL 505) taught by Dr. Jocelyn Colella. The goal for this project is to create the framework for a machine learning model that will go through human observations (i.e., still images) from GBIF (mainly from iNaturalist) to identify whether an individual is "brown", "white", or "molting" during the winter season.== 
## Steps:
### 1. **Download GBIF data via API download**
    - Relevant scripts: 01_download_GBIF_data/01.download_GBIF_data.sh 
	- Prompts for
        - Enter species: e.g. Mustela nivalis,Mustela erminia,Mustela richardsonii,Vulpes lagopus,Lagopus leucura,Lagopus lagopus,Lagopus muta,Lepus americanus
	    - Enter taxon key: e.g 5218987,5219019,9134203,5219303,5227717,2473421,5227679,2436794
	    - Enter user information [username, email, password]
	    - Customize output using query.json
            - e.g. basis of record = human observation, MediaType is Image, Month is 1,2,12
    - Downloads species data for each species into associated folders
### 2. **Clean data**
    - Relevant scripts (in 02_clean_GBIF_data/): 01.GBIF_mm_duplicatesRemoved.sh, 02.GBIF_combine_mm_occ.sh, 03.GBIF_erminia_correct.sh
	- 01.GBIF_mm_duplicatesRemoved.sh:
        - uses files from 01_download_GBIF_data/, but outputs in this directory or a subdirectory of this directory
        - keeps only one image per record
    - 02.GBIF_combine_mm_occ.sh
        - also uses files from 01_download_GBIF_data/, but outputs in this directory or a subdirectory of this directory
        - combines the species_multimedia.txt and species_occurence.txt files
        - includes occurence metadata and image links
    - 03.GBIF_erminia_correct.sh
        - takes M_erminia occurences in N America, and puts them into a M_richardsonii file
        - also removes those records from M_eriminia file
### 3. **Download, rename, and resize all images**
    - relevant scripts (in 03_images): 01.GBIF_download_images.sh, 02.sort_images_fixed.sh, 03.down_res.py, 03.RUN_down_res.sh 
    - uses output files of previous step (in 02_clean_GBIF_data/combined_mm_occ) and outputs in this directory or subdir of
    - 01.GBIF_download_images.sh
        - uses file name to make directories for each species
        - uses image url column to download using wget
        - uses GBIF ID column to name images
    - 02.sort_images_fixed.sh
        - use AFTER manually scoring (more info further down)
        - copies and moves images
            - unscored images remain lose
            - images go into train/test/val directories
                - automatically split into those 3 directories at 80-10-10 ratio 
        - names directories as "down_res" in preparation for next step
    - 03.down_res.py
        - run using a shell script (03.RUN_down_res.sh)
        - crops and reduces resolution of downloaded images to a standardized size
### 4. **Run scored images through a transferred ML model**
    - relevant scripts (in 04_machine_learning): 01.model_transfer_learning.py
    - 01.model_transfer_learning.py
        - run using shell script (01.RUN_model.sh)
        - runs the model...
### 5. **Visualize model efficiency**
    - relevant scripts (in 04_machine_learning): 02.evaluate_model_plots.py, 03.plot_training_history.py 
    - 02.evaluate_model_plots.py 
        - makes a confusion matrix
    - 03.plot_training_history.py
        - makes plots of Model Accuracy and Model Loss
### ** Scoring images***
    - All images must be centered, of only one creature per photo.
    - use standardized categories. We used:
        -  White
        - Brown
        - Molting
        - Other (category for tracks, unidentifiable, etc.)
### ** Modeling **
	-  Split (by species and coat color, 33 variables) into:
		- 80% training
		- 10% validation
		- 10% testing
	- Base model: MobileNetV2 (pretrained on ImageNet)
	- Custom top layers: GlobalAveragePooling2D → Dense(128, ReLU) → Dense(num_classes, Softmax)
	- Frozen base layers (transfer learning only)
	- Optimizer: Adam (lr=1e-4)
	- Loss: Categorical Crossentropy
	- Data Augmentation: Horizontal flip, rotation


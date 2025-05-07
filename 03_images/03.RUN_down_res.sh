#!/bin/bash
#SBATCH --job-name=GBIFimages
#SBATCH --partition=bi 
#SBATCH --time=0-08:00:00 
#SBATCH --ntasks=1 
#SBATCH --mem=50g
#SBATCH --output=downres_images.log

# Activate environment
module load conda
conda activate snowmen

# Run the Python script
conda run -n snowmen python 03.down_res.py

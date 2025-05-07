#!/bin/bash
#SBATCH --job-name=train_model
#SBATCH --partition=bi
#SBATCH --time=0-08:00:00
#SBATCH --ntasks=1
#SBATCH --mem=50G
#SBATCH --output=train_model.log

# Load the Conda module
module load conda

# Run your model training script using the snowmen environment
conda run -n snowmen python 01.model_transfer_learning.py


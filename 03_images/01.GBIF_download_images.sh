#!/bin/bash
#SBATCH --job-name=GBIFimages
#SBATCH --partition=bi 
#SBATCH --time=0-08:00:00 
#SBATCH --ntasks=1 
#SBATCH --mem=50g
#SBATCH --output=download_images.log

# Define directories
input_dir="/kuhpc/work/bi/d135l135/WinterColor_ML/02_clean_GBIF_data/combined_mm_occ"
output_dir="/kuhpc/work/bi/d135l135/WinterColor_ML/03_images"

# Loop through each metadata text file
for file in "$input_dir"/*.txt; do
    # Get species name from filename and remove the rest
    species=$(basename "$file" | cut -d'_' -f1,2)
    species_dir="$output_dir/$species"

    # Skip if species folder exists and is not empty
    if [[ -d "$species_dir" && "$(ls -A "$species_dir")" ]]; then
        echo "☼ Skipping $species — images already exist."
        continue
    fi

    echo "☼ Downloading images for $species..."

    # Create species folder
    mkdir -p "$species_dir"

    # Read the text file line by line (skip header)
    tail -n +2 "$file" | while IFS=$'\t' read -r gbifID type format identifier rest; do
        if [[ -z "$gbifID" || -z "$identifier" ]]; then
            continue
        fi

        # Extract extension from URL
        ext="${identifier##*.}"
        ext="${ext%%\?*}"

        # Download image
        wget -q -O "$species_dir/${gbifID}.${ext}" "$identifier"
    done
done

echo "☼☼ ALL DONE ☼☼"


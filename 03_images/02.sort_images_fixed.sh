#!/bin/bash
#SBATCH --job-name=sort_images
#SBATCH --partition=sixhour
#SBATCH --time=0-06:00:00
#SBATCH --ntasks=1
#SBATCH --mem=32G
#SBATCH --output=sort_images.log

score_dir="scored_records"
coat_colors=("brown" "white" "molting" "other")

for species_path in */; do
    species="${species_path%/}"

    [[ "$species" == "scored_records" ]] && continue

    echo "☼ Processing $species"

    # Create base down_res and split folders
    mkdir -p "$species_path/down_res"
    for split in train val test; do
        for color in "${coat_colors[@]}"; do
            mkdir -p "$species_path/down_res/$split/$color"
        done
    done

    # COPY all image files into flat down_res (keep unscored here)
    find "$species_path" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec cp {} "$species_path/down_res/" \;

    # Find matching metadata file
    meta_file=$(find "$score_dir" -name "${species}_*.txt")
    if [[ ! -f "$meta_file" ]]; then
        echo "  WARNING: No metadata for $species"
        continue
    fi

    # Read header and get column indices
    IFS=$'\t' read -r -a columns < "$meta_file"
    for i in "${!columns[@]}"; do
        [[ "${columns[$i]}" == "color" ]] && color_col=$i
        [[ "${columns[$i]}" == "gbifID" ]] && gbif_col=$i
        [[ "${columns[$i]}" == "id" ]] && inat_col=$i
    done

    # Count expected number of columns
    expected_cols=${#columns[@]}

    # Process each row in metadata
    tail -n +2 "$meta_file" | while IFS=$'\t' read -ra row; do
        # Pad missing columns to prevent shift issues
        while [ "${#row[@]}" -lt "$expected_cols" ]; do
            row+=("")
        done

        color=$(echo "${row[$color_col]}" | tr '[:upper:]' '[:lower:]' | xargs)

        # Only handle scored rows with valid coat color
        if [[ ! " ${coat_colors[*]} " =~ " $color " ]]; then
            continue
        fi

        if [[ "$species" == "M_frenata" ]]; then
            image_id="${row[$inat_col]}"
        else
            image_id="${row[$gbif_col]}"
        fi
        [[ -z "$image_id" ]] && continue

        # Find the copied file in flat down_res folder
        match=$(find "$species_path/down_res" -maxdepth 1 -type f -name "${image_id}.*" \
                \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | head -n 1)

        if [[ -n "$match" ]]; then
            # Hash-based 80/10/10 split
            hash_val=$(echo "$image_id" | cksum | cut -d ' ' -f1)
            mod_val=$((hash_val % 10))
            if (( mod_val < 8 )); then
                split="train"
            elif (( mod_val == 8 )); then
                split="val"
            else
                split="test"
            fi

            dest="$species_path/down_res/$split/$color/$(basename "$match")"
            mv "$match" "$dest"
            echo "  ☼ Moved $image_id → $split/$color"
        else
            echo "  WARNING: No match found for $image_id"
        fi
    done

done

echo "☼☼ ALL SPECIES PROCESSED ☼☼"


#!/bin/bash

# Set paths to directories
DATA_DIR="/kuhpc/work/bi/d135l135/WinterColor_ML/01_download_GBIF_data"
CLEAN_DIR="/kuhpc/work/bi/d135l135/WinterColor_ML/02_clean_GBIF_data"
OUTDIR="$CLEAN_DIR/duplicatesRemoved_multimedia"
mkdir -p "$OUTDIR"

# Loop through all GBIF species folders ending in _GBIF_raw
for dir in "$DATA_DIR"/*_GBIF_raw; do
    # Extract species name from the folder name
    species=$(basename "$dir" | sed 's/_GBIF_raw//')
    raw_data="$DATA_DIR/${species}_GBIF_raw/${species}_multimedia.txt"
    clean_data="$OUTDIR/${species}_multimedia_duplicatesRemoved.txt"

    echo "☼ Processing $species"

    if [[ ! -f "$raw_data" ]]; then
        echo "ERROR: File not found $raw_data"
        continue
    fi

    # Keep header and the first occurrence for each gbifID
    {
        head -n 1 "$raw_data"
        tail -n +2 "$raw_data" | awk -F '\t' '!seen[$1]++'
    } > "$clean_data"

    echo "  ☼ Saved cleaned file to: $clean_data"
done

echo "☼☼ FINISHED PROCESSING ☼☼"


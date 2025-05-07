#!/bin/bash

# Set paths to directories
RAW_DIR="/kuhpc/work/bi/d135l135/WinterColor_ML/01_download_GBIF_data"
CLEAN_DIR="/kuhpc/work/bi/d135l135/WinterColor_ML/02_clean_GBIF_data/duplicatesRemoved_multimedia"
OUT_DIR="/kuhpc/work/bi/d135l135/WinterColor_ML/02_clean_GBIF_data/combined_mm_occ"
mkdir -p "$OUT_DIR"

for mmfile in "$CLEAN_DIR"/*_multimedia_duplicatesRemoved.txt; do
    species=$(basename "$mmfile" _multimedia_duplicatesRemoved.txt)
    occfile="$RAW_DIR/${species}_GBIF_raw/${species}_occurrence.txt"
    outfile="$OUT_DIR/${species}_combined_mm_occ.txt"

    echo "☼ Processing $species"

    if [[ ! -f "$occfile" ]]; then
        echo "	ERROR: No occurrence file for $species, skipping."
        continue
    fi

    # Extract headers from both files
    mm_header=$(head -n 1 "$mmfile")
    occ_header=$(head -n 1 "$occfile" | cut -f2-)  # Do not transfer duplicate gbifID column

    echo -e "${mm_header}\t${occ_header}" > "$outfile"

    # Use join to merge on gbifID and sort to make sure they are in the same order!
    tail -n +2 "$mmfile" | sort -k1,1 > /tmp/mm_sorted.txt
    tail -n +2 "$occfile" | sort -k1,1 > /tmp/occ_sorted.txt
    join -t $'\t' -1 1 -2 1 /tmp/mm_sorted.txt /tmp/occ_sorted.txt >> "$outfile"

    echo "	☼ Merged $species TO $outfile"
done

echo "☼☼ FINISHED PROCESSING ☼☼"

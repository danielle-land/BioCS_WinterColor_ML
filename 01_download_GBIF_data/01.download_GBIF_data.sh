#!/bin/bash

# Prompt the user for inputs
# Inputs for this project:
	# Enter species name: Mustela nivalis,Mustela erminia,Mustela richardsonii,Vulpes lagopus,Lagopus leucura,Lagopus lagopus,Lagopus muta,Lepus americanus
	# Enter taxon key: 5218987,5219019,9134203,5219303,5227717,2473421,5227679,2436794
		# NOTE: you can find taxon key in the url of the GBIF species page
read -p "Enter species names (comma-separated): " SPECIES_INPUT
read -p "Enter taxon keys (comma-separated, in the same order): " TAXON_KEYS
read -p "Enter your GBIF username: " USERNAME
read -p "Enter your GBIF email: " EMAIL
read -s -p "Enter your GBIF password: " PASSWORD # -s will hide password while typing out
echo

# Turn the species names and taxon keys into arrays
# IFS is a field separator which is then set to look at comma-delimited
IFS=',' read -r -a SPECIES_ARRAY <<< "$SPECIES_INPUT"
IFS=',' read -r -a TAXON_ARRAY <<< "$TAXON_KEYS"

# Make sure number of species = number of taxon keys provided
if [ "${#SPECIES_ARRAY[@]}" -ne "${#TAXON_ARRAY[@]}" ]; then
  echo "ERROR: Number of species and taxon keys do not match"
  exit 1
fi

# Loop through each species
for i in "${!SPECIES_ARRAY[@]}"; do
  SPECIES="${SPECIES_ARRAY[$i]}"
  SPECIESKEY="${TAXON_ARRAY[$i]}"
  
  # Shorten the species names for files (e.g., Mustela nivalis = M_nivalis)
  SHORT_NAME=$(echo "$SPECIES" | awk '{print substr($1,1,1)"_"$2}' | sed 's/[^a-zA-Z_]//g')

  echo " ☼ Processing $SPECIES (Taxon key: $SPECIESKEY)"

  # Skip if already downloaded
  ZIP_NAME="${SHORT_NAME}_gbif.zip"
  if [ -f "$ZIP_NAME" ]; then
    echo "ERROR: $ZIP_NAME already exists. Skipping download."
    continue
  fi

  # Make a json file to submit to GBIF with criteria specified / standardized
  # NOTE: matchCase is needed or this will not work
  cat <<EOF > query.json
{
  "creator": "$USERNAME",
  "notificationAddresses": [
    "$EMAIL"
  ],
  "sendNotification": true,
  "format": "DWCA",
  "predicate": {
    "type": "and",
    "predicates": [
      {
        "type": "equals",
        "key": "BASIS_OF_RECORD",
        "value": "HUMAN_OBSERVATION",
        "matchCase": false
      },
      {
        "type": "equals",
        "key": "MEDIA_TYPE",
        "value": "StillImage",
        "matchCase": false
      },
      {
        "type": "in",
        "key": "MONTH",
        "values": [
          "1",
          "2",
          "12"
        ],
        "matchCase": false
      },
      {
        "type": "equals",
        "key": "TAXON_KEY",
        "value": "$SPECIESKEY",
        "matchCase": false
      }
    ]
  }
}
EOF

  # Submit the download request to GBIF
  echo " ☼ Submitting download request to GBIF..."
  RESPONSE=$(curl -s -u "$USERNAME:$PASSWORD" -H "Content-Type: application/json" -d @query.json https://api.gbif.org/v1/occurrence/download/request)

  # DEBUG: print full raw response from GBIF
  echo " ☼ Checking if the following download key is valid: $RESPONSE"

  # Extract download key or print error
  if [[ "$RESPONSE" =~ ^[0-9]{7}-[0-9]+$ ]]; then
    KEY="$RESPONSE"
    echo " ☼ Success! Download key $KEY is valid! Begin download"
  else
    echo "ERROR: Failed to submit download for $SPECIES"
    echo " 		☼ GBIF said: $RESPONSE"
    continue
  fi

  # Poll GBIF download status until ready (once every 30 seconds)
  echo " ☼ Waiting for GBIF to finish processing..."
  while true; do
    STATUS=$(curl -s https://api.gbif.org/v1/occurrence/download/$KEY | grep -o '"status":"[^\"]*"' | sed 's/"status":"//;s/"//')
    echo "   ☼ Status: $STATUS"
    if [[ "$STATUS" == "SUCCEEDED" ]]; then
      break
    elif [[ "$STATUS" == "FAILED" || "$STATUS" == "CANCELLED" ]]; then
      echo "ERROR: Download failed for $SPECIES"
      continue 2
    fi
    sleep 30
  done

  # Sleep for 5 minutes to avoid overwhelming GBIF servers
  # NOTE: This step is absolutely needed!
  echo " ☼ Sleeping 5 minutes before polling GBIF..."
  sleep 300 

  # Download zip file
  curl -L -u "$USERNAME:$PASSWORD" "https://api.gbif.org/v1/occurrence/download/request/$KEY.zip" -o "$ZIP_NAME"
  echo "Downloaded $ZIP_NAME"

  # Unzip and rename the new folder to shortened species name
  OUTPUT_DIR="${SHORT_NAME}_GBIF_raw"
  mkdir -p "$OUTPUT_DIR"
  TMP_DIR="unzipped_${SHORT_NAME}"
  mkdir -p "$TMP_DIR"
  unzip -q "$ZIP_NAME" -d "$TMP_DIR"

  for FILE in "$TMP_DIR"/*; do
    BASENAME=$(basename "$FILE")
    mv "$FILE" "$OUTPUT_DIR/${SHORT_NAME}_$BASENAME"
  done

  rm -r "$TMP_DIR"

done

echo " ☼☼ Downloads complete ☼☼ "


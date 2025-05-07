#!/bin/bash

src_root="/kuhpc/work/bi/d135l135/WinterColor_ML/03_images"
dest_root="/kuhpc/work/bi/d135l135/WinterColor_ML/04_machine_learning"

mkdir -p "$dest_root"/{train,val,test}

for species in "$src_root"/*/; do
    species_name=$(basename "$species")
    
    for split in train val test; do
        for color in brown white molting other; do
            src="$species/down_res/$split/$color"
            class="${species_name}_${color}"
            dest="$dest_root/$split/$class"
            mkdir -p "$dest"

            if [ -d "$src" ]; then
                echo "Copying $species_name $split/$color → $class"
                cp "$src"/* "$dest/" 2>/dev/null
            fi
        done
    done
done


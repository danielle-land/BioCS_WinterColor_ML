#!/bin/bash

awk -F "\t" '$95=="NORTH_AMERICA" {print}' combined_mm_occ/M_erminia_combined_mm_occ.txt >> combined_mm_occ/M_richardsonii_combined_mm_occ.txt


awk -F "\t" '$95!="NORTH_AMERICA" {print}' combined_mm_occ/M_erminia_combined_mm_occ.txt > tmp &&  mv tmp combined_mm_occ/M_erminia_combined_mm_occ.txt




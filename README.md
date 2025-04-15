# Utilizing machine learning to score coat colors from GBIF images for mammals and birds that turn white in the winter
## About:
This project is for the KU Spring 2025 course "Computer Science for Biology" (BIOL 505) taught by Dr. Jocelyn Colella. The goal for this project is to create the framework for a machine learning model that will go through human observations (i.e., still images) from GBIF (mainly from iNaturalist) to identify whether an individual is "brown", "white", or "molting" during the winter season. 
## Steps:
1. Download GBIF data via API download
	- Enter species: Mustela nivalis,Mustela erminia,Mustela richardsonii,Vulpes lagopus,Lagopus leucura,Lagopus lagopus,Lagopus muta,Lepus americanus
	- Enter taxon key: 5218987,5219019,9134203,5219303,5227717,2473421,5227679,2436794
	- Enter user information
	- Download species data for each species into associated folders
		- BasisOfRecord is Human Observation
		- MediaType is Image
		- Month is one of (January, February, December)
2. Clean data
	- *Mustela erminia* in North America --> *Mustela richardsonii*
	- Only keep one photo per occurrence
3. Download, rename, and resize all images
4. Sort images into coat color categories and score on CSV for each species as **Training Data**
	- White
	- Brown
	- Molting
	- Other (category for tracks, unidentifiable, etc.)
***MORE TO ADD HERE***

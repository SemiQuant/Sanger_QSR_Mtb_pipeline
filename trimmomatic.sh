#!/bin/bash

java -Xmx32g -jar ~/bin/programs/Trimmomatic-0.32/trimmomatic.jar PE -phred33 \
		"$1" "$2" \
		"$3/$4 forward_paired.fq.gz" "$3/$4 forward_unpaired.fq.gz" \
		"$3/$4 reverse_paired.fq.gz" "$3/$4 reverse_unpaired.fq.gz" \
		ILLUMINACLIP:"./bin/programs/Trimmomatic-0.32/adapters/TruSeq3-PE.fa":2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:"$6" MINLEN:30 \

		#Remove adapters
		#Remove leading low quality or N bases (below quality 3)
		#Remove trailing low quality or N bases (below quality 3)	
		#Scan the read with a 3-base wide sliding window, cutting when the average quality per base drops below 15
		#Drop reads below the 30 bases long


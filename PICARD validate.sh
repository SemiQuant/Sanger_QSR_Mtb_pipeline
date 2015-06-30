#!/bin/bash
#validate SAM or BAM file

#validate SAM or BAM file with PICARD
	java -Xmx32g -jar ~/bin/programs/picard-tools-1.124/picard.jar ValidateSamFile \
	I="$1/$2_sorted.bam" \
	O="$3/$2_sorted.bam.txt"
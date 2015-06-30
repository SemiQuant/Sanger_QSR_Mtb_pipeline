#!/bin/bash

#convert SAM into sorted BAM via picard
java -Xmx32g -jar ~/bin/programs/picard-tools-1.124/picard.jar SortSam \
	INPUT="$1/$2.sam" \
	OUTPUT="$1/$2_sorted.bam" \
	SORT_ORDER=coordinate \
	VALIDATION_STRINGENCY=LENIENT
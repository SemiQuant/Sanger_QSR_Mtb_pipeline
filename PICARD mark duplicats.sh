#!/bin/bash
#Mark Duplicates and perform local realign around indels with PICARD


#Index using samtools
/opt/exp_soft/samtools-1.1/samtools index "$1/$2_sorted.bam"

#validate SAM or BAM file with PICARD
java -Xmx32g -jar ~/bin/programs/picard-tools-1.124/picard.jar ValidateSamFile \
	I="$1/$2_sorted.bam" \
	O="$3/$2_sorted.bam.txt"

#Mark PCR duplicates with PICARD
java -Xmx32g -jar ~/bin/programs/picard-tools-1.124/picard.jar MarkDuplicates \
	INPUT="$1/$2_sorted.bam" \
	OUTPUT="$1/$2_sorted_dedup.bam" \
	VALIDATION_STRINGENCY=LENIENT \
	REMOVE_DUPLICATES=TRUE \
	ASSUME_SORTED=TRUE \
	M="$1/$2_sorted_dedup.bam.txt"


#!/bin/bash
#SMALT alignment
#generate a hash index has to be generated for the genomic reference sequences
smalt index -k "$5" -s "$6" "$1" "$1"
	#-k number is length of hash (2<x<=20)
	#-s is spacing of hash words (6)

gunzip -d "$7"
	R1s=`find "$2" -type f -iname "*forward_paired.fq"` #R1smalt(decomp.)=fastq R1
gunzip -d "$8"
	R2s=`find "$2" -type f -iname "*reverse_paired.fq"` #R2smalt(decomp.)=fastq R2

#map sequence reads to reference - must be unzipped
smalt map -f sam -o "$2/$3 no_RG_SMALT.sam" "$1" "$R1s" "$R2s"

#Add read group information 
java -jar ~/bin/programs/picard-tools-1.124/picard.jar AddOrReplaceReadGroups \
	INPUT="$2/$3 no_RG_SMALT.sam" \
 	OUTPUT="$2/$3 SMALT.sam" \
	RGID="$3" RGLB=library RGPL=illumina RGSM="$3" RGPU=truseq \
	CREATE_INDEX=TRUE \
	VALIDATION_STRINGENCY=LENIENT


#validate SAM or BAM file with PICARD
java -jar ~/bin/programs/picard-tools-1.124/picard.jar ValidateSamFile \
		INPUT= "$2/$3 SMALT.sam" \
		OUTPUT="$4/$3 SMALT.txt"

rm "$1.output*"	#delete smalt hashtable

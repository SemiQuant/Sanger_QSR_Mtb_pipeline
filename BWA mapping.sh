#!/bin/bash
#BWA mapping

####################################################################################################
#all refs will be indexed and already in a folder - just here for info
#index reference genome 
	##bwa index “ref.fasta” "output"
####################################################################################################

#map raw reads to ref genome
	~/bin/bwa/bwa aln -t 8 "$1" "$4" > "$2/$3 forward_paired.sai"
	~/bin/bwa/bwa aln -t 8 "$1" "$5" > "$2/$3 reverse_paired.sai"
		#Do this for each individual “paired file from the trimmomatic”

#Map to reference using BWA
	#paired ends
		~/bin/bwa/bwa sampe -r "@RG\tID:$3\tSM: :$3\tPL:Illumina" "$1" "$2/$3 forward_paired.sai" "$2/$3 reverse_paired.sai" "$4" "$5" > "$2/$3 BWA.sam"
			#-r option allows for adding read group headers as a str

#validate SAM or BAM file with PICARD
	java -Xmx32g -jar ~/bin/programs/picard-tools-1.124/picard.jar ValidateSamFile \
		INPUT= "$2/$3 BWA.sam" \
		OUTPUT="$6/$3 BWA.txt"
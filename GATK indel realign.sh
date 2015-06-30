#!/bin/bash

#Perform local realignment around indels to correct mapping-related artifacts with GATK
#generate index  with picard
java -Xmx32g -jar ~/bin/programs/picard-tools-1.124/picard.jar BuildBamIndex \
	I="$1/$2_sorted_dedup.bam" \
	VALIDATION_STRINGENCY= LENIENT
####################################################################################################
#all refs will be indexed and already in a folder - just here for info
#Index Ref for Use via picard - create .dict file
##java -Xmx32g -jar ~/bin/programs/picard-tools-1.124/picard.jar CreateSequenceDictionary \ 
	##R=input.fa \
	##O=output.dict
####################################################################################################

#Create a target list of intervals to be realigned with GATK
java -Xmx32g -jar ~/bin/programs/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
    	-T RealignerTargetCreator \
	-nct 8 \
    	-R "$3" \
    	-I "$1/$2_sorted_dedup.bam" \
    	-o "$1/$2_sorted_dedup.bam.list"
	#-known indels if available.vcf

#Perform realignment of the target intervals (base quality score recalibrations)
	java -Xmx32g -jar ~/bin/programs/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
   		-T IndelRealigner \
		-nct 8 \
    		-R "$3" \
    		-I "$1/$2_sorted_dedup.bam" \
    		-targetIntervals "$1/$2_sorted_dedup.bam.list" \
  	    	-o "$1/$2_sorted_dedup_realigned.bam"
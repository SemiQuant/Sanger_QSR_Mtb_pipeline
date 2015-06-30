#!/bin/bash
#BQSR
#"$Ref_name" "$Temp" "$Name BWA" "$Data" "$SeqStats" "$Script_dir"
####################################################################################################
#Analyze patterns of covariation in the sequence dataset
##Need know variants or doesnt works!! - it skips over the variants inputted
java -Xmx32g -jar ~/bin/programs/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
	-T BaseRecalibrator \
	-nct 8 \
	-knownSites "$6/references/Variants/myQSR/BQSrecal.vcf" \
	-R "$1" \
  	-I "$2/$3_sorted_dedup_realigned_sorted.bam" \
	-o "$4/$3_sorted_dedup_realigned.recal.table"

#Generate before/after plots
java -Xmx32g -jar ~/bin/programs/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
	-T AnalyzeCovariates \
	-nct 8 \
	-R "$1" \
	-before "$4/$3_sorted_dedup_realigned.recal.before.table" \
	-after "$4/$3_sorted_dedup_realigned.recal.table_after.pdf" \
	-plots "$4/$3_sorted_dedup_realigned.recal.table_plots.pdf"

#Apply the recalibration to your sequence data
java -Xmx32g -jar ~/bin/programs/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
	-T PrintReads \
	-nct 8 \
	-R "$1" \
	-I "$2/$3_sorted_dedup_realigned_sorted.bam" \
	-BQSR "$4/$3_sorted_dedup_realigned.recal.table" \
	-o "$2/$3_sorted_dedup_realigned_BQSRrecal.bam"


####################################################################################################

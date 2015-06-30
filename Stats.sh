#!/bin/bash
Ref_name=$1
Temp=$2
Name=$3
Data=$4
SeqStats=$5
Script_dir=$6

#CollectMultipleMetrics
java -Xmx32g -jar ~/bin/programs/picard-tools-1.124/picard.jar CollectMultipleMetrics \
	VALIDATION_STRINGENCY=LENIENT \
	INPUT="$2/$3_sorted_dedup_realigned_sorted.bam" \
	OUTPUT="$5/$3"

#bedtools genome coverage
#get stats on <10 coverage genome sites (bedtools)
#~/bin/bedtools2/bin/bedtools genomecov -ibam "$2/$3_sorted_dedup_realigned_sorted.bam" -bg | awk '$4 < 10' > "$5/$3_sorted_dedup_realigned_sorted_genome_coverage_10depthsites.txt"

~/bin/bedtools2/bin/bedtools genomecov -ibam "$2/$3_sorted_dedup_realigned_sorted.bam" -bg > "$5/$3_sorted_dedup_realigned_sorted_genome_coverage.txt"

chmod 757 "$5/$3_sorted_dedup_realigned_sorted_genome_coverage.txt"

cat "$5/$3_sorted_dedup_realigned_sorted_genome_coverage.txt" | awk '$4 < 10' > "$5/$3_sorted_dedup_realigned_sorted_genome_coverage_10depthsites.txt"

	#annotate
	Rscript "$6/Genome_cov_annot.R" "$5/$3_sorted_dedup_realigned_sorted_genome_coverage_10depthsites.txt" "$6"
	  #rm "$5/$3_sorted_dedup_realigned_sorted_genome_coverage_10depthsites.txt" 

	#add | wc -l to get count - can then say y% have less than X coverage
	
#samtools flagstats -get mapping statistics
/opt/exp_soft/samtools-1.1/samtools flagstat "$2/$3_sorted_dedup_realigned_sorted.bam" >> "$5/$3_sorted_dedup_realigned_sorted.flagstat.txt"


exit 0

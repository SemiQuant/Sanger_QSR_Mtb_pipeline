#!/bin/bash
#call variants with GATK

#Calling variants with GATK UnifiedGenotyper
	#for diplod use HaplotypeCaller 
#for filenames can perform on many bam files viz. -I file1 -I file2 -I fileN
java -Xmx32g -jar ~/bin/programs/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
    	-T UnifiedGenotyper \
	-nct 8 \
    	-R "$1" \
    	-I "$2/$3_sorted_dedup_realigned_BQSRrecal.bam" \
    	-ploidy 1 \
    	-glm BOTH \
    	-stand\_call\_conf "$4" \
	-stand\_emit\_conf "$5" \
    	-o "$6/$3 raw_variants_GATK_unified_genotyper.vcf"

#HaplotypeCaller - better at calling indels
java -Xmx32g -jar ~/bin/programs/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
    	-T HaplotypeCaller \
	-nct 8 \
    	-R "$1" \
    	-I "$2/$3_sorted_dedup_realigned_BQSRrecal.bam" \
   	--genotyping_mode DISCOVERY \
    	-stand_emit_conf "$4" \
    	-stand_call_conf "$5" \
    	-o "$6/$3 raw_variants_GATK_haplotype_caller.vcf"

####################REMEMBER TO ADD THE REMOVING OF NON HOMOZYGOUS IF USING HAPLOTYPE GATK CALLER
#remove 'non-homozygous" variants - keeps formatting 
	cat "$6/$3 raw_variants_GATK_haplotype_caller.vcf" | grep -v AF1=0 > "$6/$3 raw_variants_GATK_haplotype_call_homozygous.vcf"
	#sed -i '/AF1=0/ d' "$6/$3 raw_variants_GATK_haplotype_caller.vcf" #overwrite original file

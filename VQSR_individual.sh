#!/bin/bash
#Variant recalibration
#Analyze patterns of covariation in the sequence dataset


#sh "/Users/jdlim/Desktop/full pipline/New ref genome/Variant Scripts/VQSR - working but need to edit for pipeline.txt" "$Ref_name" "$InVcf" "$Data" "$Name" "$Script_dir/references/Variants/Broad Variants - Partic mapped/SA.1_merged_PASS.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/KwaZulu-Natal.3_merged_PASS.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/KwaZulu-Natal.3_merged.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/SA.1_merged.vcf"


#run VCF check
#vcf-validator "$2" 

#SNP variant recal
java -Xmx32g -jar /Library/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
	-T VariantRecalibrator \
	-R "$1" \
	-input "$2" \
  	-resource:dbsnp,known=true,training=false,truth=true,prior=6.0 "$5" \
	-resource:dbsnp,known=true,training=false,truth=true,prior=6.0 "$6" \
	-resource:dbsnp,known=false,training=true,truth=true,prior=10.0 "$7" \
	-resource:dbsnp,known=false,training=true,truth=true,prior=10.0 "$8" \
  	-an QD -an MQ -an DP -an MQRankSum \
  	-mode SNP \
  	-recalFile "$3/$4_SNP_output.recal" \
	-tranchesFile "$3/$4_SNP_output.tranches" \
	-rscriptFile "$3/$4_SNP_output.plots.R" \
	--maxGaussians 4

#Apply reacl to dataset
java -Xmx32g -jar /Library/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
	-T ApplyRecalibration \
	-R "$1" \
	-input "$2" \
	-mode SNP \
	-tranchesFile "$3/$4_SNP_output.tranches" \
	-recalFile "$3/$4_SNP_output.recal" \
	-o "$3/$4_SNP_output.recalibrated.filtered.vcf" \
	--ts_filter_level 90.0 
	#CONFIDENCE THAT ITS REAL ts_filter_level

#INDEL
java -Xmx32g -jar /Library/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
	-T VariantRecalibrator \
	-R "$1" \
	-input "$2" \
	-resource:dbsnp,known=true,training=false,truth=true,prior=6.0 "$5" \
	-resource:dbsnp,known=true,training=false,truth=true,prior=6.0 "$6" \
	-resource:dbsnp,known=false,training=true,truth=true,prior=10.0 "$7" \
	-resource:dbsnp,known=false,training=true,truth=true,prior=10.0 "$8" \
	-an QD -an MQ -an DP -an MQRankSum \
  	-mode INDEL \
  	-recalFile "$3/$4_indel_output.recal" \
	-tranchesFile "$3/$4_indel_output.tranches" \
	-rscriptFile "$3/$4_indel_output.plots.R" \
	--maxGaussians 4

java -Xmx32g -jar /Library/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
	-T ApplyRecalibration \
	-R "$1" \
	-input "$2" \
	-mode INDEL \
	-tranchesFile "$3/$4_indel_output.tranches" \
	-recalFile "$3/$4_indel_output.recal" \
	-o "$3/$4_indel_output.recalibrated.filtered_INDEL.vcf" \
	--ts_filter_level 90.0 
	#CONFIDENCE THAT ITS REAL ts_filter_level
exit 0
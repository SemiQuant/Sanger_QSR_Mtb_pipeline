#!/bin/bash

#if [[ $1 == "Y" ]] || [[ $1 == "y" ]]; then


	java -Xmx32g -jar ~/bin/programs/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
		-T CombineVariants \
		-R "$2" \
		--variant "$4" \
		--variant "$5" \
		--variant "$6" \
		--variant "$7" \
		-o "$3 merged-$(date +%Y-%m-%d).vcf" \
		-genotypeMergeOptions UNIQUIFY



#elif [[ $1 == "N" ]] || [[ $1 == "n" ]]; then
#	java -Xmx32g -jar ~/bin/programs/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
#		-T CombineVariants \
#		-R "$2" \
#		--variant "$4" \
#		--variant "$5" \
#		-o "$3 merged-$(date +%Y-%m-%d).vcf" \
#		-genotypeMergeOptions UNIQUIFY
#fi


cat "$3 merged-$(date +%Y-%m-%d).vcf" | grep -v AF1=0 > "$3 merged-$(date +%Y-%m-%d)_homozygous.vcf"
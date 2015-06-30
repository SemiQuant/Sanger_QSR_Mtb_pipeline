#!/bin/bash
module load java/jdk-1.8
Script_dir=$(dirname "$0") #get directory where script is
Programs="$Script_dir/programs for pipeline" #location of program files
F_dir="$1"
ls -d "$F_dir/"*/ > "$Script_dir/TEMP_directories.txt" #output store directories in folder to text file
FQDirs="$Script_dir/TEMP_directories.txt"

#changable parameters 
Trim=20 #$2
Call=30 #$3
Emit=10 #$4
K=20 #$5
S=6 #$6
Ref_name="$Script_dir/references/H37Rv/H37Rv.fasta" #$7

IFS=$'\n'
for F_dir in $(cat $FQDirs); do
	R1=$(find "$F_dir" -type f -iname "*R1_001.fastq*") #R1=fastq R1
	R2=$(find "$F_dir" -type f -iname "*R2_001.fastq*") #R2=fastq R2
	
	Name=$(basename $F_dir)
	F_dir="${F_dir%?}"
	mkdir "$F_dir/$Name"
	Mdata="$F_dir/$Name/Data"
	mkdir "$Mdata"
	SeqStats="$Mdata/Sequence Stats"
	mkdir "$SeqStats"
	Data="$Mdata/BWA-$(date +%Y-%m-%d)"
	mkdir "$Data"
	Variants="$Mdata/Variants"
	mkdir "$Variants"
	Temp="$F_dir/Temp"
	mkdir "$Temp"
	basic_log="$Mdata/Run_log_Basic.log"
	START="$(date +%s)" #strat time of script run - end at bottom and diff calc

		
	#fastQC sequence stats
echo "$(date) fastQC sequence stats started" >> "$basic_log"
	nohup sh "$Script_dir/FastQC.sh" "$R1" "$R2" "$SeqStats"
	mv "$SeqStats/$R1_fastqc.html" "$SeqStats $Name forward_fastqc.html"
	mv "$SeqStats/$R1_fastqc.zip" "$SeqStats $Name forward_fastqc.zip" 
	mv "$SeqStats/$R2_fastqc.html" "$SeqStats $Name forward_fastqc.html"
	mv "$SeqStats/$R2_fastqc.zip" "$SeqStats $Name forward_fastqc.zip"
echo "$(date) fastQC sequence stats completed" >> "$basic_log"

	#Trim sequences and clip adapters - Paired End
echo "$(date) Trim sequences and clip adapters started" >> "$basic_log"
	sh "$Script_dir/trimmomatic.sh" "$R1" "$R2" "$Temp" "$Name" "$Programs" "$Trim"
echo "$(date) Trim sequences and clip adapters completed sucessfully" >> "$basic_log"
	R1paired="$Temp/$Name forward_paired.fq.gz"
	R2paired="$Temp/$Name reverse_paired.fq.gz"

#fastQC sequence stats
echo "$(date) fastQC sequence stats post trim started" >> "$basic_log"
	nohup sh "$Script_dir/FastQC.sh" "$R1paired" "$R2paired" "$SeqStats"
	mv "$SeqStats/$R1paired_fastqc.html" "$SeqStats $Name forward_postTrim_fastqc.html"
	mv "$SeqStats/$R1paired_fastqc.zip" "$SeqStats $Name forward_postTrim_fastqc.zip" 
	mv "$SeqStats/$R2paired_fastqc.html" "$SeqStats $Name forward__postTrimfastqc.html"
	mv "$SeqStats/$R2paired_fastqc.zip" "$SeqStats $Name forward_postTrim_fastqc.zip"
echo "$(date) fastQC sequence stats post trim completed" >> "$basic_log"

	############################BWA mapping############################
echo "$(date) BWA mapping started" >> "$basic_log"
	#BWA alignment and mapping followed by PICARD validation
	sh "$Script_dir/BWA mapping.sh" "$Ref_name" "$Temp" "$Name" "$R1paired" "$R2paired" "$Data"

	#Convert SAM to sorted BAM using PICARD
	sh "$Script_dir/PICARD SAM to BAM.sh" "$Temp" "$Name BWA"
		
	#Mark Duplicates and perform local realign around indels with PICARD then validate
	sh "$Script_dir/PICARD mark duplicats.sh" "$Temp" "$Name BWA" "$Data"
	
	#Add read group information *IF NECESSARY

	#Perform local realignment around indels to correct mapping-related artifacts with GATK
	sh "$Script_dir/GATK indel realign.sh" "$Temp" "$Name BWA" "$Ref_name"
	#Sort and Index with samtools
	sh "$Script_dir/samtools sort and index.sh" "$Temp" "$Name BWA" 

	#perform multiple stats on seq
	sh "$Script_dir/Stats.sh" "$Ref_name" "$Temp" "$Name BWA" "$Data" "$SeqStats" "$Script_dir"
echo "$(date) BWA mapping completed" >> "$basic_log"

echo "$(date) BWA variant calling started" >> "$basic_log"

	#perform BQSR
	sh "$Script_dir/BQSRecal.sh" "$Ref_name" "$Temp" "$Name BWA" "$Data" "$SeqStats" "$Script_dir"

	#Calling Variants
	#Calling variants with samtools and bcftools
	sh "$Script_dir/SAMTOOLS variant call.sh" "$Ref_name" "$Temp" "$Name BWA" "$Data"
	
	#call variants with GATK
	sh "$Script_dir/GATK variant call.sh" "$Ref_name" "$Temp" "$Name BWA" "$Call" "$Emit" "$Data"
	####################REMEMBER TO ADD THE REMOVING OF NON HOMOZYGOUS IF USING HAPLOTYPE GATK CALLER
echo "$(date) BWA variant calling completed" >> "$basic_log"


echo "$(date) SMALT mapping started" >> "$basic_log"
	DataS="$F_dir/$Name/Data/SMALT-$(date +%Y-%m-%d)"
	mkdir "$DataS"
	
	#SMALT alignment and mapping and PICARD add read groups and validate
	sh "$Script_dir/SMALT alignment and mapping and PICARD read groups.sh" "$Ref_name" "$Temp" "$Name" "$DataS" "$K" "$S" "$R1paired" "$R2paired"
				
	#PICARD SAM to sorted BAM
	sh "$Script_dir/PICARD SAM to BAM.sh" "$Temp" "$Name SMALT"
		
	#PICARD validate SAM or BAM file
	sh "$Script_dir/PICARD validate.sh" "$Temp" "$Name SMALT" "$DataS"
	
	#Mark Duplicates with PICARD
	sh "$Script_dir/PICARD mark duplicats.sh" "$Temp" "$Name SMALT" "$DataS"

	#Perform local realignment around indels to correct mapping-related artifacts with GATK
	sh "$Script_dir/GATK indel realign.sh" "$Temp" "$Name SMALT" "$Ref_name"
	#Sort and Index with samtools
	sh "$Script_dir/samtools sort and index.sh" "$Temp" "$Name SMALT" 

	#perform multiple stats on seq
	sh "$Script_dir/Stats.sh" "$Ref_name" "$Temp" "$Name SMALT" "$DataS" "$SeqStats" "$Script_dir"
echo "$(date) SMALT mapping completed" >> "$basic_log"
echo "$(date) SMALT variant calling started" >> "$basic_log"

	#perform BQSR
	sh "$Script_dir/BQSRecal.sh" "$Ref_name" "$Temp" "$Name SMALT" "$DataS" "$SeqStats" "$Script_dir"

	#Calling Variants
	#Calling variants with samtools and bcftools
	sh "$Script_dir/SAMTOOLS variant call.sh" "$Ref_name" "$Temp" "$Name SMALT" "$DataS"
	
	#call variants with GATK
	sh "$Script_dir/GATK variant call.sh" "$Ref_name" "$Temp" "$Name SMALT" "$Call" "$Emit" "$DataS"
	####################REMEMBER TO ADD THE REMOVING OF NON HOMOZYGOUS IF USING HAPLOTYPE GATK CALLER
echo "$(date) SMALT variant calling completed" >> "$basic_log"

	#merge variant files
	echo "$(date) merge variants started" >> "$basic_log"
	sh "$Script_dir/merge and index GATK.sh" "$ParamS" "$Ref_name"  "$Variants/$Name" "$Data/$Name BWA raw_variants_Samtools_cons_caller.vcf" "$Data/$Name BWA raw_variants_GATK_unified_genotyper.vcf" "$DataS/$Name SMALT raw_variants_GATK_unified_genotyper.vcf" "$DataS/$Name SMALT raw_variants_Samtools_cons_caller.vcf"
	echo "$(date) merge variants completed" >> "$basic_log"

#VQSRecal on merged VCF
	#sh "$Script_dir/Variant Scripts/VQSR.sh" "$Ref_name" "$Variants/$Name merged-$(date +%Y-%m-%d).vcf" "$Seq_stats" "$Name" "$Script_dir/references/Variants/Broad Variants - Partic mapped/SA.1_merged_PASS.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/KwaZulu-Natal.3_merged_PASS.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/KwaZulu-Natal.3_merged.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/SA.1_merged.vcf"


#VQSR on individual files
#sh "$Script_dir/Variant Scripts/VQSR_individual.sh" "$Ref_name" "$Data/$Name BWA raw_variants_Samtools_cons_caller.vcf" "$Data" "$Name BWA raw_variants_Samtools_cons_caller.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/SA.1_merged_PASS.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/KwaZulu-Natal.3_merged_PASS.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/KwaZulu-Natal.3_merged.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/SA.1_merged.vcf"

#sh "$Script_dir/Variant Scripts/VQSR_individual.sh" "$Ref_name" "$Data/$Name BWA raw_variants_GATK_unified_genotyper.vcf" "$Data" "$Name BWA raw_variants_GATK_unified_genotyper.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/SA.1_merged_PASS.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/KwaZulu-Natal.3_merged_PASS.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/KwaZulu-Natal.3_merged.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/SA.1_merged.vcf"

#sh "$Script_dir/Variant Scripts/VQSR_individual.sh" "$Ref_name" "$DataS/$Name SMALT raw_variants_GATK_unified_genotyper.vcf" "$DataS" "$Name SMALT raw_variants_GATK_unified_genotyper.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/SA.1_merged_PASS.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/KwaZulu-Natal.3_merged_PASS.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/KwaZulu-Natal.3_merged.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/SA.1_merged.vcf"

#sh "$Script_dir/Variant Scripts/VQSR_individual.sh" "$Ref_name" "$DataS/$Name SMALT raw_variants_Samtools_cons_caller.vcf" "$DataS" "$Name SMALT raw_variants_Samtools_cons_caller.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/SA.1_merged_PASS.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/KwaZulu-Natal.3_merged_PASS.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/KwaZulu-Natal.3_merged.vcf" "$Script_dir/references/Variants/Broad Variants - Partic mapped/SA.1_merged.vcf"

	#Annotate varinats
	echo "$(date) annotate variants started" >> "$basic_log"
	#sh "$Script_dir/Variant Scripts/annotate variants.sh" "$Variants/$Name merged-$(date +%Y-%m-%d).vcf"
	sh "$Script_dir/Variant Scripts/SNPeff.sh" "$Variants/$Name merged-$(date +%Y-%m-%d).vcf" "$Script_dir"
	Rscript "$Script_dir/Variant Scripts/Annotate_automated.R" "$Variants/$Name merged-$(date +%Y-%m-%d).vcf.reordered.txt" "$Script_dir" "$F_dir"
	echo "$(date) annotate variants completed" >> "$basic_log"
	
	#VennCompare - can clean this up alot
	echo "$(date) Venn compare variants started" >> "$basic_log"
	Rscript "$Script_dir/Variant Scripts/Venn Automated.R" "$Data/$Name BWA raw_variants_Samtools_cons_caller.vcf" "$Data/$Name BWA raw_variants_GATK_unified_genotyper.vcf" "$DataS/$Name SMALT raw_variants_Samtools_cons_caller.vcf" "$DataS/$Name SMALT raw_variants_GATK_unified_genotyper.vcf" "$Script_dir" "$F_dir" "$Name" "$Ref_name"
	echo "$(date) Venn compare variants completed" >> "$basic_log"

	#merge depth files
	#10 DP
	Rscript "$Script_dir/merge_coverage_files.R" "$SeqStats/$Name BWA_sorted_dedup_realigned_sorted_genome_coverage_10depthsites.txt" "$SeqStats/$Name SMALT_sorted_dedup_realigned_sorted_genome_coverage_10depthsites.txt" "$Name" "$SeqStats" "$SeqStats/$Name ,erged_sorted_dedup_realigned_sorted_genome_coverage_10depthsites.txt"
	#all DP
	Rscript "$Script_dir/merge_coverage_files.R" "$SeqStats/$Name BWA_sorted_dedup_realigned_sorted_genome_coverage.txt" "$SeqStats/$Name SMALT_sorted_dedup_realigned_sorted_genome_coverage.txt" "$Name" "$SeqStats" "$SeqStats/$Name ,erged_sorted_dedup_realigned_sorted_genome_coverage_all_depthsites.txt"

	############################SMALT mapping############################

echo "$(date) SpolPred Started" >> "$basic_log"
		#Spoligotype Prediction -SpolPred
		#needs unziped file
		gunzip "$R1"
		spolfile="${R1%???}"
		sh "$Script_dir/SpolPred.sh" "$spolfile" "$MData" "$Name"
echo "$(date) SpolPred Completed" >> "$basic_log"

	mv "$Temp/$Name BWA_sorted_dedup_realigned_sorted.bam" "$Data/$Name BWA_sorted_dedup_realigned_sorted.bam"
	mv "$Temp/$Name SMALT_sorted_dedup_realigned_sorted.bam" "$DataS/$Name SMALT_sorted_dedup_realigned_sorted.bam"

	gzip "$Data/$Name BWA_sorted_dedup_realigned_sorted.bam"
	gzip "$DataS/$Name SMALT_sorted_dedup_realigned_sorted.bam"
	

	rm "$FQDirs"
	rm -rf "$Temp"
	rm "$spolfile"    	#DELETE READS FILES cos server edition!!
	rm "$R2"

	END=$(date +%s)
	DIFF=$(( ($END - $START) / 60 )) >> "$basic_log"

done #end of multi for statment
	

END=$(date +%s)
DIFF=$(( ($END - $START) / 60 ))

exit 0

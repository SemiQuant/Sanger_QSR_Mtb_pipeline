#!/bin/bash
#call variants with SAMTOOLS and bcftools

/opt/exp_soft/samtools-1.1/samtools mpileup -pmF -ugf "$1" "$2/$3_sorted_dedup_realigned_BQSRrecal.bam" | /home/lmbjas002/bin/bcftools-1.1/bcftools call -vcO v -o "$4/$3 raw_variants_Samtools_cons_caller.vcf"


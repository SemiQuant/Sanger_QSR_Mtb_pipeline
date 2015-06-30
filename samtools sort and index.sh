#!/bin/bash

#sort file with samtools
	/opt/exp_soft/samtools-1.1/samtools sort "$1/$2_sorted_dedup_realigned.bam" "$1/$2_sorted_dedup_realigned_sorted"

#index the sorted file
	/opt/exp_soft/samtools-1.1/samtools index "$1/$2_sorted_dedup_realigned_sorted.bam"


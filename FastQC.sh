#!/bin/bash
#fastQC sequence stats

~/bin/programs/FastQC/fastqc "$1" -o "$3"
~/bin/programs/FastQC/fastqc "$2" -o "$3"
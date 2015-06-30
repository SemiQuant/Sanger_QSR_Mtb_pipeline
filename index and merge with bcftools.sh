#!/bin/bash
#merge variant files

if [[ $1 == "Y" ]] || [[ $1 == "y" ]]; then
	bgzip "$2"
	bgzip "$3"
	bgzip "$4"
	bgzip "$5"
	~/bin/programs/tabix-0.2.6/tabix -s1 -b2 -e3 "$2"
	~/bin/programs/tabix-0.2.6/tabix -s1 -b2 -e3 "$3"
	~/bin/programs/tabix-0.2.6/tabix -s1 -b2 -e3 "$4"
	~/bin/programs/tabix-0.2.6/tabix -s1 -b2 -e3 "$5"

	bcftools merge "$2" "$3" "$4" "$5" -o "$6/$7 merged.vcf"

elif if [[ $1 == "N" ]] || [[ $1 == "n" ]]; then
	bgzip "$2"
	bgzip "$3"
	~/bin/programs/tabix-0.2.6/tabix -s1 -b2 -e3 "$2"
	~/bin/programs/tabix-0.2.6/tabix -s1 -b2 -e3 "$3"

	~/bin/programs/bcftools-1.1/bcftools merge "$2" "$3" -o "$6/$7 merged.vcf"

fi

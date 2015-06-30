args <- commandArgs(TRUE)
genomecov <- args[1]
Script_dir <- args[2]

#assign gene names to output from Bedtools Genome Coverage
library(data.table)

dt1 <- read.table(genomecov, header=F)
#dt1 <- dt1[c(1,4,3,2)]
colnames(dt1) <- c('Genome','Gene_start','Gene_end','Coverage (depth)')
#dt1 <- dt1[c(1,2,3)]

annots <- paste(Script_dir, '/references/Annotation files/broad as bed.txt', sep="")
dt2 <- read.table(annots, header=F, sep="\t")
colnames(dt2) <- c('Genome','Gene_start','Gene_end','Gene_ID')

DT1 <- data.table(dt1)
DT2 <- data.table(dt2)


setkey(DT2, Genome, Gene_start, Gene_end)
# The last two columns in both by.x and by.y should each correspond to the start and end interval columns in x and y respectively.
outputtable <- foverlaps(DT1, DT2)[, c("Genome","i.Gene_start","i.Gene_end","Gene_ID"),  with = FALSE]

setnames(outputtable,'i.Gene_start','Start')
setnames(outputtable,'i.Gene_end','End')
setnames(outputtable,'Gene_ID','Gene ID')

outfile <- paste(genomecov,"_annotated.txt", sep="")

write.table(outputtable, outfile, sep="\t", na="non-coding", row.names = FALSE)

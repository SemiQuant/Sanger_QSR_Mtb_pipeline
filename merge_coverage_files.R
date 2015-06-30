args <- commandArgs(TRUE)
f1 <- args[1]
f2 <- args[2]
namein <- args[3]
SeqStats <- args[4]
outfile <- args[5]

file1 <- read.table(f1, header = F)
colnames(file1) <- c("Genome", "Start", "End", "Coverage")
file2 <- read.table(f2, header = F)
colnames(file2) <- c("Genome", "Start", "End", "Coverage")
merged <- merge(file1, file2, by=c("Start", "End"))

merged <- merged[c(3,1,2,4)]
colnames(merged) <- c("Genome", "Start", "End", "Gene ID")

write.table(merged, file = outfile, sep='\t', row.names = FALSE)

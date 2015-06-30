#graph from bedtools coverage output
library(ggplot2)
args <- commandArgs(TRUE)
Gcov <- args[1]
out <- args[2]
#setwd("/Users/jdlim/Desktop/WGS Trial/PIPELINE TEST/Single test/Temp")
coverage <- read.table(Gcov, sep = "\t", header=F)
names(coverage)[c(2,3)] <- c("Base", "Coverage") 
name <- args[3]
ref <- args[4]
name <- paste("Coverage of ",name, " Across ", ref)

png(out,height=600, width=1600)
ggplot(subset(coverage, coverage$V1=="genome"), aes(x=coverage$Base, y=coverage$Coverage))+
  geom_line(colour="orange")+ggtitle("Coverage Across Reference")+
  xlab("Reference Start Position")+
  ylab("Coverage")+
  geom_line(aes(colour = coverage$Coverage))
  #scale_colour_gradient(low="red")
  #colour red to blue but doesnt work for this graph as too many lines
#can also do
#scale_colour_gradient(limits=c(10, 100), low="red", high="white", , space="Lab")
#POINTS OUTSIDE LIMITS NOT PLOTTED
dev.off()

png(out,height=800, width=600)
qplot(Coverage, data=coverage, geom="histogram")
dev.off()
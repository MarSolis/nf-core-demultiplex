if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("basecallQC")
install.packages("writexl")
install.packages("ini")


library(basecallQC)
library(writexl)
library(ini)

#Recover Arguments
args=commandArgs(trailingOnly=TRUE)
runDir = args[1]
inputDir = args[2]
outDir = args[3]

#Test Arguments
runDir = "D:\\FUJINOMICS\\Demultiplexing\\Output\\230210_M01349_0311_000000000-KTG6P"
fileLocations <- system.file("extdata",package="basecallQC")
runXML = "RunInfo.xml"
config = "config.ini"
outDir = "Data\\Intensities\\BaseCalls\\OutDir\\"
inputDir = "Data\\Intensities\\BaseCalls\\OutDir\\Stats"


#Create config.ini file empty
fileConn<-file("config.ini")
writeLines(c("[paths]","[output]","[programs]"), fileConn)
close(fileConn)


setwd(runDir)

#Define params 
bcl2fastqparams <- BCL2FastQparams(runXML,config,inputDir,outDir,verbose=FALSE)

#Get Demultiplex Metrics
demuxMetrics <- demultiplexMetrics(bcl2fastqparams)
demuxmetrics_1 <- demuxMetrics[[1]]

#Change count column from list to df column
list <- demuxmetrics_1$Count
demuxmetrics_1$Count <- as.integer(list)

write.csv(demuxmetrics_1,paste(paste(outDir,"\\demuxMetrics1.csv", sep = "")))


#Get baseCall Metrics
bclMetrics <- baseCallMetrics(bcl2fastqparams)
bclMetrics
head(bclMetrics[[1]])
write.csv(bclMetrics[[2]],"D:\\FUJINOMICS\\Demultiplexing\\Output\\bclMetrics2.csv")




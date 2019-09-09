


library(base) 
library(stringr)
library(Matrix)
library(devtools)
library(lmerTest) # newest version of lme4 to have p-values of fixed affect
library(lme4)
library(utils)
library(data.table)
library(dplyr)
library(MASS)

# Task arg: 
args <- commandArgs(TRUE)
task <- args[1]
organization <- args[2]
# load ICC function:
icc.variability<-dget(paste0("/data3/cdb/anna/SSI/final.jae/scripts/analysis/03_icc.R"))
matdir <- sprintf("/data3/cdb/jcho/hcp180/analysis/icc/icc_csv/%s_%s", task,organization)
csvfile <- sprintf("%s/%sy.csv", matdir, task)
covfile <- sprintf("%s/%scov.csv", matdir, task)
# Load conn_all
resty <- read.csv(csvfile,header=TRUE)
y <- t(resty)
y <- y[-1,]
# Load covariates:
restcov <- read.csv(covfile,header=TRUE)
subIDs <- restcov$subID
meanFD <- restcov$meanFD
age <- restcov$age
gconn <- restcov$gconn
gender <- as.factor(restcov$gender) #no demean gender
nparcels <- 360
#(4) run model
all_out<-icc.variability(y)
nconns<-dim(y)[1]
#(5) save ICC, variation between, variation within, total variation tables
out_icc<-all_out$out_icc
#(5)1 icc
iccvector <- out_icc$ICC
iccname <- paste0(sprintf("%s/%s_icc_vector.csv", matdir, task))
write.csv(iccvector,iccname)

#(5)2 var_within
var_within <- out_icc$VarWithinSubj
withinname <- paste0(sprintf("%s/%s_within_vector.csv", matdir, task))
write.csv(var_within,withinname)

#(5)3 var_between
var_between <- out_icc$VarBetweenSubj
betweenname <- paste0(sprintf("%s/%s_between_vector.csv", matdir, task))
write.csv(var_between,betweenname)

#(5)4 total variation
var_total <- out_icc$varY
totalname <- paste0(sprintf("%s/%s_vartotal_vector.csv", matdir, task))
write.csv(var_total,totalname)
#(5)5 other statistics
xnames <- c('inter', 'age', 'gender', 'meanFD', 'gconn')
stats_names <- c('t-value', 'p-value')
for (xname in xnames) {
  col<-paste0("stats_", xname)
  col<-which(names(all_out)==col)
  stats <- all_out[[col]]
  for (stats_name in stats_names){
    s.col<-which(names(stats)==stats_name)
    #save as csv
    fname = paste0(matdir,'/stats_', xname, '_',  stats_name,".csv")
    write.table(stats[[s.col]], fname, sep = ",", col.names =stats_name,row.names = F )
  }
}

try(if(! file.exists(fname)) {stop("Rerun LMM")}else{print(sprintf("Done with LMM pipeline"))})
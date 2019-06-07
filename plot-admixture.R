library(pophelper)
library(readxl)
library(magrittr) # need to run every time you start R and want to use %>%
library(dplyr) # alternative, this also loads %>%
library(gridExtra)
library(grid)
library(ggplot2)
library(lattice)
folder = '~/freeze2019'
setwd(folder)
newid<-function (x){
  paste0(strsplit(x,"_")[[1]][2],"_",strsplit(x,"_")[[1]][3])
}
#kelly <- c("#F2F3F4","#222222","#F3C300","#875692","#F38400","#A1CAF1","#BE0032","#C2B280","#848482","#008856","#E68FAC","#0067A5","#F99379","#604E97","#F6A600","#B3446C","#DCD300","#882D17","#8DB600", "#654522","#E25822","#2B3D26")
# Variables
sample_data <- read_excel("~/GR+simons+pagani+1000G.xlsx")
title_label <- 'Sorted Russians and Outgroups'
files <- list.files(path = folder, pattern = "\\.Q$", full.names=T)
files <-files[order(nchar(files), files)]
fam_path <- list.files(path = folder, pattern = "\\.fam$")
adm_results = sapply(files, readQ)
sample_info <- read.delim(fam_path,
                          sep = ' ',
                          header = F,
                          stringsAsFactors = F)
sample_data[['newid']]<-sapply(sample_data[['new_iid']], newid)
more_info <- merge(x = sample_info, y = sample_data,  by.x = "V2", by.y= "newid", all.x = TRUE, sort = F)

sample_labels <- more_info$V2
labels_adm <- 1:length(files);
k<-0;
sapply(adm_results, function(x) { k<<-k+1; labels_adm[[k]]<<-paste0('K=',sprintf("%01d",k+1))})
for (j in 1:k){rownames(adm_results[[j]])<-sample_labels}
names(adm_results)<-labels_adm;
gr <- more_info[, "population", drop =F]
#colnames(gr)[colnames(gr)=="continent_region"] <- "continent"
rownames(gr) <- sample_labels

plotQ(adm_results,imgoutput="join",
      returnplot=T,exportplot=T,quiet=T,basesize=5,
      grplab=gr,grplabjust= 0, grplabsize=2.0,linesize=0.5,
      pointsize=1, grplabangle = 90, grplabheight= 6,#width=300,
      showindlab=F,indlabwithgrplab=T, indlabangle =90, indlabsize = 4, sharedindlab=F, panelratio=c(10,10),splab=labels_adm)#,clustercol=kelly)

plotQMultiline(adm_results,exportplot=T,useindlab=T, grplabsize = 25, 
               showindlab=T,returnplot=T, indlabsize = 20, 
               grplab=gr,ordergrp=T, width=80, dpi=600)

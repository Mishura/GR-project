library(pophelper)
library(readxl)
library(magrittr) # need to run every time you start R and want to use %>%
library(dplyr)    # alternative, this also loads %>%
library(gridExtra)
library(grid)
library(ggplot2)
library(lattice)
setwd( '~/freeze2019')

kelly <- c("#F2F3F4","#222222","#F3C300","#875692","#F38400","#A1CAF1","#BE0032","#C2B280","#848482","#008856","#E68FAC","#0067A5","#F99379","#604E97","#F6A600","#B3446C","#DCD300","#882D17","#8DB600", "#654522","#E25822","#2B3D26")
# Variables
sample_data <- read_excel("~/GR+simons+pagani+1000G.xlsx")
title_label <- 'Sorted Ancient and Modern'
files <- list.files(path = '~/freeze2019', pattern = "\\.Q$", full.names=T)
files <-files[order(nchar(files), files)]
fam_path <- list.files(path = '~/freeze2019', pattern = "\\.fam$")
out_path <- '~/freeze2019.3'
adm_results = sapply(files, readQ)
sample_info <- read.delim(fam_path,
                          sep = ' ',
                          header = F,
                          stringsAsFactors = F)
more_info <- merge(x = sample_data, y = sample_info, by.x = "new_iid", by.y= "V2",all.y = TRUE)

family_labels <- sample_info[, 2, drop = F]
sample_labels <- sample_info$V2
labels_adm <- 1:length(files);
k<-0;
sapply(adm_results, function(x) {rownames(x)<-sample_labels; k<<-k+1; labels_adm[[k]]<<-paste0('K=',sprintf("%02d",k))})
names(adm_results)<-labels_adm;
continent_gr <- more_info[, c('continent_region'), drop =F]
colnames(continent_gr)[colnames(continent_gr)=="continent_region"] <- "continent"
rownames(continent_gr) <- sample_labels
plotQ(adm_results,imgoutput="join",
      returnplot=T,exportplot=T,quiet=T,basesize=5,
      grplab=continent_gr,grplabjust= 0, grplabsize=1,linesize=0.5,
      pointsize=1, grplabangle = 90, grplabheight= 6,
      showindlab=F,indlabwithgrplab=F, indlabangle =90, indlabsize = 4, sharedindlab=F, 
      ordergrp = T,panelratio=c(10,10),splab=labels_adm,clustercol=kelly)

# Main Project file
# 26-FEB-2016 by MR
# 
# 
# Modification history:
# 
# 26-FEB-2016 - created by MR   



# Initiate session
rm(list=ls())

#memory.size()

switch(Sys.info()[['sysname']],
       Windows= {memory.size()},
       Linux  = {gc()},
       Darwin = {gc()})

# Load needed packages or install if something is missing
pkgs <- c("base","gmodels", "Rmisc","xlsx","dplyr","lazyeval","ReporteRs","rtable","tidyr","stringr","car","broom","ggplot2", "data.table", "PropCIs")
new.pkgs <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
if(length(new.pkgs)) install.packages(new.pkgs)
sapply(pkgs, require, character.only = TRUE)


# Set working directory



getwd()

#sessionInfo()
library(ggplot2)
#cpu_info <- read.xlsx("/Users/mrotkevich/Desktop/DATA/cpu-stats.xls", header = T,sheetName = "page1")
cpu_info <- read.xlsx("/Users/mrotkevich/Desktop/DATA/Excel_Workbook.xls", header = F,1)

cpu_num <- c()
#cpu_info1<-na.omit(cpu_info[cpu_info$CPU != 'Min:' &cpu_info$Step != 'Total:' ,])

long_cpu<-cpu_info %>% gather(Observation, Time, -X2,-X1)
#long_cpu<-long_cpu[long_cpu$Observation != 'Avg',]
long_cpu$X1<-factor( as.numeric(as.character(long_cpu$X1)),labels=unique(long_cpu$X1))
long_cpu$X2<-factor( as.numeric(as.character(long_cpu$X2)),labels = unique(long_cpu$X2))
names(long_cpu)[1]<-'CPU'
names(long_cpu)[2]<-'Step'
cpus <- summarySE(long_cpu,
                   measurevar="Time",
                   groupvars=c("CPU","Step"))

cpu_plot <- ggplot(cpus, aes(x=Step, y=Time, colour=CPU)) +
  geom_errorbar(aes(ymin=Time-se, ymax=Time+se, group=CPU),
                width=.1) +
  geom_line(aes(group=CPU)) +
  geom_point() + ggtitle("Time execution of a script depending on CPU and quantity of rows")
cpu_plot



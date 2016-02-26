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
cpu_info <- read.xlsx("/Users/mrotkevich/Desktop/DATA/cpu-stats.xls", header = T,sheetName = "page1")

cpu_num <- c()
cpu_info1<-na.omit(cpu_info[cpu_info$CPU != 'Min:' &cpu_info$Step != 'Total:' ,])
cpu_info1<-cpu_info1[c("CPU","Step","Avg")]

#plot(cpu_info1$Step,cpu_info1$Avg,"l",col='black',xlab = 'Step', ylab = 'Seconds',xlim=c(0, 550), ylim=c(0, 100))
mtcars$gear <- factor(mtcars$gear,levels=c(3,4,5),
                      labels=c("3gears","4gears","5gears")) 
mtcars$am <- factor(mtcars$am,levels=c(0,1),
                    labels=c("Automatic","Manual")) 
mtcars$cyl <- factor(mtcars$cyl,levels=c(4,6,8),
                     labels=c("4cyl","6cyl","8cyl")) 




long_cpu<-cpu_info1 %>% gather(Observation, Time, -CPU,-Step)
long_cpu<-long_cpu[long_cpu$Observation != 'Avg',]
long_cpu$CPU<-factor( as.numeric(as.character(long_cpu$CPU)),labels=cpu_num)
long_cpu$Step<-factor( as.numeric(as.character(long_cpu$Step)),labels = c(50,100,150,200,250,300,350,400,450,500))

cpus <- summarySE(long_cpu,
                   measurevar="Time",
                   groupvars=c("CPU","Step"))
qplot(Step, Time, data=long_cpu, geom=c("point", "smooth"), method="lm")

cpu_plot <- ggplot(cpus, aes(x=Step, y=Time, colour=CPU)) +
  geom_errorbar(aes(ymin=Time-se, ymax=Time+se, group=CPU),
                width=.1) +
  geom_line(aes(group=CPU)) +
  geom_point() + ggtitle("Time execution of a script depending on CPU and quantity of rows")
cpu_plot


for (j in 1:9) {
  #cpu_info_2<-na.omit(cpu_info[cpu_info$CPU == j &cpu_info$Step != 'Total:' ,])
  #cpu_info_2$Step<-as.numeric(as.character(cpu_info_2$Step))
  #lines(cpu_info_2$Step,cpu_info_2$Avg,col = j)
  cpu_num<-c(cpu_num,paste('cpu',j))
}
legend(x="topright", legend = cpu_num, col = 2:9,
       lty=rep(1,7))
title("Effeciency",
      cex.main = 2,   font.main= 1, col.main= "black")

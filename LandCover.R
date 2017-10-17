#################### Program to change Land cover indices from Hydroterre to the MM-PIHM format##################
#################### Felipe Montes                             ##########################


###############################################################################################################
#                          Loading Packages and setting up working directory                        
###############################################################################################################



#  Tell the program where the package libraries are  #####################


.libPaths("C:/Felipe/Sotware&Coding/R_Library/library")  ;

#  Set Working directory


setwd("C:/Felipe/PIHM-CYCLES/PIHM/PIHM_R_Scripts/PIHMVegetation") ; 

########### Install packages  #####################


# install.packages('raster', dep=TRUE)


########### Call the library packages needed for the program to work #############

# load libraries
#library(Hmisc) ;

############# Load the vegetation parameter table and the convertion parameters for PIHM - MM ################

NUMLC<-read.table("./vegprmt.tbl", skip=0, as.is=T, nrows=1) ;


vegprmt.tbl<-read.table("./vegprmt.tbl", skip=1, sep="", as.is=T, header=T, nrows=NUMLC[1,2]) ;

Description<-read.table("./vegprmt.tbl", skip=1, sep="\t", as.is=T, header=T, nrows=NUMLC[1,2], comment.char="") ;

vegprmt.tbl$Description<-sapply(strsplit(Description[,1], "#"), "[" , 2) ;

Otherprmt.tbl<-read.table("./vegprmt.tbl", skip=NUMLC[1,2]+2, sep="", as.is=T, header=F, nrows=5) ;



############# Load the vegetation parameter map from the NLCD to the MM-PIHM Land Cover type 
############# "NLCD land cover class mapping to PIHM land cover type ############################          


NLCD_PIHM.lc<-read.table("./vegprmt.tbl", skip=NUMLC[1,2]+10, sep= ">" , as.is=T, header=F,comment.char="") ;

PIHM.lc<-NLCD_PIHM.lc[,2];

NLCD.lc<-as.integer(sapply(strsplit(NLCD_PIHM.lc[,1], split = " "), "[" , 2)) ;

NLCD_to_PIHM<-merge(data.frame(NLCD.lc, PIHM.lc), vegprmt.tbl, by.x= "PIHM.lc", by.y= "INDEX", all=T) ;





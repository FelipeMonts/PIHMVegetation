#################### Program to change Land cover indices from Hydroterre to the MM-PIHM format##################
#################### Felipe Montes                             ##########################


###############################################################################################################
#                          Loading Packages and setting up working directory                        
###############################################################################################################



#  Tell the program where the package libraries are  #####################


.libPaths("C:/Felipe/Sotware&Coding/R_Library/library")  ;

#  Set Working directory


setwd("C:/Felipe/PIHM-CYCLES/PIHM/PIHM_Felipe/CNS/WE-38/WE38_Files_PIHM_Cycles20170208/SWATPIHMRcode") ; 

########### Install packages  #####################


# install.packages('raster', dep=TRUE)


########### Call the library packages needed for the program to work #############

# load libraries
library(Hmisc) ;

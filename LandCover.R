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


NLCD_to_PIHM[!is.na(NLCD_to_PIHM$NLCD.lc),]


######### Load the attribute file to change the LC codes from NLCD to the NEw PIHM

att<-read.table("C:/Felipe/PIHM-CYCLES/PIHM/PIHM_Felipe/CNS/Manhantango/HydroTerreFullManhantango/HansYostDeepCreek/Aug2920171550/4DataModelLoader/MergeVectorLayer000_q30_a200000.att",as.is=T,col.names=c('Index', 'Soil', 'Geol','LC','IS_IC', 'Snw_IC', 'Srf_IC', 'Ust_IC', 'St_IC', 'Ppt', 'Tmp', 'RH', 'Wnd', 'Rn', 'G', 'VP', 'S', 'mF', 'BC.0', 'BC.1', 'BC.2', 'mP'));

names(att)

######### MErge with the NLCD_to_PIHM data to change the NLCD LC data to the MM-PIHM Land Cover


att.expanded<-merge(att,NLCD_to_PIHM, by.x="LC", by.y="NLCD.lc", all.x=T ) ;


###### change the name of the LC column that will be used in the revised attributes

revised.names<-names(att)   ;

revised.names[4]<- "PIHM.lc" ;

Revised.att<-att.expanded[order(att.expanded$Index),revised.names] ;

names(Revised.att)[4]<-'LC'  ;


write.table(Revised.att[,c('Index', 'Soil', 'Geol','LC','IS_IC', 'Snw_IC', 'Srf_IC', 'Ust_IC', 'St_IC', 'Ppt', 'Tmp', 'RH', 'Wnd', 'Rn', 'G', 'VP', 'S', 'mF', 'BC.0', 'BC.1', 'BC.2', 'mP')], file="C:/Felipe/PIHM-CYCLES/PIHM/PIHM_Felipe/CNS/Manhantango/HydroTerreFullManhantango/HansYostDeepCreek/Aug2920171550/4DataModelLoader/Revised.att" , row.names=F, quote=F , sep = "\t" ) ; # ,col.names=header.att, quote=F

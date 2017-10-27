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


###############################################################################################################
#                         Add correction for the river material units in the .riv file
#                         Taken and adapted from the R code PIHMInputs on the PIHM_R_Scripts directory
#                         2017 10 25 By Felipe Montes
###############################################################################################################



# *************************************************READ THE RIVER FILE . riv  ****************************************************



# The river file has several blocks of data in the same file
# It starts with a single column in the first row names NumRiv, which indicates the number of river segments
# Then is has a block of data with the river elements and nodes. This block has the following variables:
# Index FromNode ToNode Down LeftEle RightEle Shape Material IC BC Res

# Variable Name: Variable Type: Variable Description: Remarks
# NumRiv Integer Number of River Segments
# Index Integer River Segment ID Beginning with 1
# FromNode Integer From Node ID
# ToNode Integer To Node ID
# Down Integer Downstream Segment ID
# LeftEle Integer Left Element ID
# RightEle Integer Right Element ID
# Shape Integer Shape ID
# Material Integer Material ID
# IC Integer Initial Condition ID
# BC Integer Boundary Condition ID
# Res Integer Reservoir ID

River.file<-'C:/Felipe/PIHM-CYCLES/PIHM/PIHM_Felipe/CNS/Manhantango/HydroTerreFullManhantango/HansYostDeepCreek/Aug2920171550/4DataModelLoader/MergeVectorLayer000_q30_a200000.riv'

NumRiv<-read.table(River.file,as.is=T,nrows=1)[1,1];


riv.elements<-read.table(River.file,as.is=T,skip=1,nrows=NumRiv,col.names=c('Index', 'FromNode', 'ToNode', 'Down', 'LeftEle', 'RightEle', 'Shape', 'Material', 'IC', 'BC', 'Res'));

# the the files continues with a block containing shape attributes. The block starts with a row with two coulms "Shape" and "NumShape"
# Then it is followed by a list of attributes regarding the shape: Index Depth InterpOrd WidCoeff

# Variable Name: Variable Type: Variable Description: Remarks
# Index Integer Shape ID Beginning with 1
# Depth Double Depth of the River Segment
# InterpOrder Integer Interpolation Order * 1 if a rectangular
# WidCoeff Double Width Coefficient * width if a rectangular
# * Interpolation Order (b) and Widht Coefficient (a) are parameters defining relation between Width and Depth of a river segment as: [D = a x (W/2)b].

shape<-read.table(River.file,as.is=T,skip=1+NumRiv,nrows=1);

NumShape<-shape[1,2];

riv.shape<-read.table(River.file, as.is=T,skip=1+NumRiv+1,nrows=NumShape,col.names=c('Index', 'Depth', 'InterpOrd', 'WidCoeff'));


# Afterwards the file continues with the Material information for the river shapes. The block starts with a row with two coulms "Material" and NumMat
# The file continues with 6 columns with the following attribute values: Index n Cwr KsatH KsatV Bed

# Variable Name: Variable Type: Variable Description: Remarks
# NumMat Integer Number of Material Types
# Index Integer Material ID Beginning with 1
# n Double Manning's Roughness Coefficient
# Cwr Double Discharge Coefficient
# KsatH Double Size Hydraulic Conductivity
# KsatV Double Bed Hydraulic Conductivity
# Bed Double Bed Depth



Material<-read.table(River.file,as.is=T,skip=1+NumRiv+1+NumShape,nrows=1);

NumMat<-Material[1,2];

riv.material<-read.table(River.file,as.is=T,skip=1+NumRiv+1+NumShape+1,nrows=NumMat,col.names=c('Index', 'n', 'Cwr', 'KsatH','KsatV','Bed'));


# The river file then continues with a block describing the initial conditions for the river elements.
# The block starts with a row with two coulms "IC" and NumIC
# Then it has a block of with two coulms: Index Value


# Variable Name: Variable Type: Variable Description: Remarks
# NumIC Integer Number of Initial Condition Types
# Index Integer Initial Condition ID Beginning with 1
# Value Double Intial Condition Water Table

IC<-read.table(River.file,as.is=T,skip=1+NumRiv+1+NumShape+1+NumMat,nrows=1);

NumIC<-IC[1,2]; 

riv.IC<-read.table(River.file,as.is=T,skip=NumRiv+1+NumShape+1+1+NumMat+1,nrows=NumIC,col.names=c('Index', 'Value'));


# Finaly the river file contains the boundary condition information
# It starts with a row with two coulms "BC" and NumBC. NumBC indicates the number of boundary conditions time series. In this example the NumBC=0, therefore there is no information about the boundary conditions. 
# see the PIHM2x_input_file_format.pdf file

BC<-read.table(River.file,as.is=T,skip=1+NumRiv+1+NumShape+1+NumMat+1+NumIC,nrows=1);

NumBC<-BC[1,2];


# Finally the river file has a last line with a double coumn and following variables "Res" NumRes
# this information indicates the number of reservoirs



Res<-read.table(River.file,as.is=T,skip=1+NumRiv+1+NumShape+1+NumMat+1+NumIC+max(c(NumBC,1)),nrows=1);


###############################################################################################################
#                         Print the corrected  .riv file in th right format
#                         Taken and adapted from the R code MM_PHIMinputs on the PIHM_R_Scripts directory
#                         2017 10 25 By Felipe Montes
###############################################################################################################




###################   Write the appropiate formated "River" File for the MM-PIHM input format  #################################

######## path to print the revised River file .riv

Revised.River.File<-"C:/Felipe/PIHM-CYCLES/PIHM/PIHM_Felipe/CNS/Manhantango/HydroTerreFullManhantango/HansYostDeepCreek/Aug2920171550/4DataModelLoader/Revised.riv"

##   Add river elements
header.riv<-c( NumRiv, 'FROM' , 'TO' ,  'DOWN' , 	'LEFT' , 	'RIGHT' , 	'SHAPE' ,	'MATERIAL' ,	'IC' ,	'BC' ,	'RES' )  ;

write.table(riv.elements,file=Revised.River.File, row.names=F , col.names=header.riv, quote=F, sep= "\t" ) ;


##    Add river Shape


## write the word Shape as title before writting the tabel with the data

Shape.title<-c('Shape');

write.table(Shape.title,file=Revised.River.File , row.names=F , col.names=F, quote=F, append=T , sep= "\t") ;


header.riv.Shape<-c(NumShape, 'DPTH' ,  'OINT' ,	'CWID' );

write.table(riv.shape,file=Revised.River.File, row.names=F , col.names=header.riv.Shape, quote=F, append=T, sep = "\t") ;


##   Add river Material

Material.title<-('MATERIAL');



write.table(Material.title,file=Revised.River.File, row.names=F , col.names=F, quote=F, append=T , sep = "\t") ;


header.riv.Material<-c( NumMat , 'ROUGH' ,  'CWR' ,	'KH' ,	'KV' ,	'BEDTHICK');

##  Convert units of Manning's roughness coefficient [day m-1/3] , River bank hydraulic conductivity (horizontal KH) and
##   River bed hydraulic conductivity (vertical KV) [m/day] into  [s m-1/3] and [m/s] 

riv.material$ROUGH<-riv.material$n * 86400  ;

riv.material$KH<-riv.material$KsatH / 86400  ;

riv.material$KV<-riv.material$KsatV / 86400  ;



write.table(riv.material[,c('Index','ROUGH' ,  'Cwr' ,	'KH' ,	'KV' ,	'Bed')],file=Revised.River.File , row.names=F , col.names=header.riv.Material, quote=F, append=T , sep = "\t") ;


##### The initial condition was removed from the current version of the .riv file
# ##   Add initial condition  ###
# 
# IC.title<-c('IC');
# 
# write.table(IC.title,file=paste0(inputfile.name, ".riv") , row.names=F , col.names=F, quote=F, append=T , sep = "\t") ;
# 
# 
# write.table(riv.IC, file=paste0(inputfile.name, ".riv") , row.names=F , col.names= c(NumIC, 'HRIV'), quote=F, append=T , sep = "\t") ;

##   Add boundary condition


write.table(BC[2],file=Revised.River.File, row.names=F , col.names= c('BC'), quote=F, append=T, sep = "\t") ;


##   Add Reservoirs

write.table(Res[2],file=Revised.River.File, row.names=F , col.names=c('RES'), quote=F, append=T , sep = "\t") ;





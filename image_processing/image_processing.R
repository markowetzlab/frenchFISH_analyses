library(FISHalyseR)
library(autothresholdr)

path_to_dir <- "~" # change to be path to frenchFISH_analyses directory
setwd(paste(path_to_dir, "/frenchFISH_analyses/image_processing", sep = ""))

source("processFISH.R")
source("FISHalyseR/R/GetStain.R")
source("FISHalyseR/R/GetDistances.R")
source("FISHalyseR/R/CreateVectors.R")
source("FISHalyseR/R/analyseParticles.R")

a=sqrt((60^2) - ((60-45)^2))
min_area=pi*(a^2)

channelColours = list(G=c(0,255,0),R=c(255,0,0),Y=c(255,255,0))
sizeNucleus = c(min_area,7000000)
bgCorrMethod = list(0,100)


#samples with precipitation across channels
samples<-c("BL32077_Myc_Terc")

fields_of_view<-list(
  rbind(c(1,5),c(5,1),c(5,2),c(5,4),c(7,1)))

names(fields_of_view)<-samples

probeSizes= rbind(c(40,500),c(40,500),c(100,1000))

for(s in samples)
{
  for(k in 1:nrow(fields_of_view[[s]]))
  {
    i<-fields_of_view[[s]][k,2]
    j<-fields_of_view[[s]][k,1]
    #probeSizes<-sizeProbe[[s]]
    green = paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/tile_x=",j,"_y=",i,"_c=2.jpg",sep="")
    red = paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/tile_x=",j,"_y=",i,"_c=3.jpg",sep="")
    aqua = paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/tile_x=",j,"_y=",i,"_c=4.jpg",sep="")
    channelSignals = list(green,red,aqua)
    writedir<-paste(path_to_dir, "/frenchFISH_analyses/image_processing/results2/",s,"/",sep="")
    combinedImg<-paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/tile_x=",j,"_y=",i,"_c=1.jpg",sep="")
    tryCatch(
      processFISH(combinedImg,writedir,bgCorrMethod,channelSignals,channelColours,sizeNucleus,probeSizes,
                  norm_method=c("RenyiEntropy","RenyiEntropy","Intermodes")),
      error=function(e) print(paste("Error in image processing:",e,sep="")),
      finally=print("Finished")
    )
  }
}



#samples with yellow precipitation
samples<-c(
  "BL024199_Myc_Terc",
  "BL32080_Myc_Terc",
  "BL_024216_Myc_Terc")

fields_of_view<-list(rbind(c(3,2),c(4,2),c(4,5),c(5,2),c(5,3)),
                     rbind(c(4,4)),
                     rbind(c(2,5),c(4,1),c(4,2),c(5,2)))

names(fields_of_view)<-samples

for(s in samples)
{
  for(k in 1:nrow(fields_of_view[[s]]))
  {
    i<-fields_of_view[[s]][k,2]
    j<-fields_of_view[[s]][k,1]
    #probeSizes<-sizeProbe[[s]]
    green = paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/tile_x=",j,"_y=",i,"_c=2.jpg",sep="")
    red = paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/tile_x=",j,"_y=",i,"_c=3.jpg",sep="")
    aqua = paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/tile_x=",j,"_y=",i,"_c=4.jpg",sep="")
    channelSignals = list(green,red,aqua)
    writedir<-paste(path_to_dir, "/frenchFISH_analyses/image_processing/results2/",s,"/",sep="")
    combinedImg<-paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/tile_x=",j,"_y=",i,"_c=1.jpg",sep="")
    tryCatch(
      processFISH(combinedImg,writedir,bgCorrMethod,channelSignals,channelColours,sizeNucleus,probeSizes,
                  norm_method=c("RenyiEntropy","RenyiEntropy","Intermodes")),
      error=function(e) print(paste("Error in image processing:",e,sep="")),
      finally=print("Finished")
    )
  }
}


#good samples
gsamples<-c("PS09.20676_2B_Myc_Terc",
            "PS09_287383C_Myc_Terc",
            "PS11.10021_2B_Myc_Terc",
            "PS11_167511L_Myc_Terc")
gfields_of_view<-list(rbind(c(1,6),c(2,1)),
                  rbind(c(1,7),c(2,7),c(6,2)),
                  rbind(c(3,4),c(7,2),c(4,2),c(4,3),c(4,4)),
                  rbind(c(1,1),c(1,3),c(4,1),c(4,4),c(4,5)))
names(gfields_of_view)<-gsamples

for(s in gsamples)
{
  for(k in 1:nrow(gfields_of_view[[s]]))
  {
    i<-gfields_of_view[[s]][k,2]
    j<-gfields_of_view[[s]][k,1]
    #probeSizes<-sizeProbe[[s]]
    green = paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/tile_x=",j,"_y=",i,"_c=2.jpg",sep="")
    red = paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/tile_x=",j,"_y=",i,"_c=3.jpg",sep="")
    aqua = paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/tile_x=",j,"_y=",i,"_c=4.jpg",sep="")
    channelSignals = list(green,red,aqua)
    writedir<-paste(path_to_dir, "/frenchFISH_analyses/image_processing/results2/",s,"/",sep="")
    combinedImg<-paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/tile_x=",j,"_y=",i,"_c=1.jpg",sep="")
    tryCatch(
      processFISH(combinedImg,writedir,bgCorrMethod,channelSignals,channelColours,sizeNucleus,probeSizes,
                  norm_method=c("RenyiEntropy","RenyiEntropy","Intermodes")),
      error=function(e) print(paste("Error in image processing:",e,sep="")),
      finally=print("Finished")
    )
  }
}


#squamous cell samples
ssamples<-c("SC_028",
            "SC_011",
            "SC_030",
            "SC_007")
sfields_of_view<-list(c(1,2,3,4,5),
                      c(2,4,5),
                      c(1,2,3,4,5),
                      c(9,11))
names(sfields_of_view)<-ssamples

for(s in ssamples)
{
  samps<-sfields_of_view[[s]]
  for(k in 1:length(samps))
  {
    x<-samps[k]
    aqua = paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/image_",x,"_c=2.jpg",sep="")
    red = paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/image_",x,"_c=3.jpg",sep="")
    green = paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/image_",x,"_c=4.jpg",sep="")
    channelSignals = list(green,red,aqua)
    writedir<-paste(path_to_dir, "/frenchFISH_analyses/image_processing/results2/",s,"/",sep="")
    combinedImg<-paste(path_to_dir, "/frenchFISH_analyses/image_processing/input_data/",s,"/image_",x,"_c=1.jpg",sep="")
    tryCatch(
      processFISH(combinedImg,writedir,bgCorrMethod = list(0,100),channelSignals,channelColours,sizeNucleus,probeSizes,
                  norm_method=c("RenyiEntropy","RenyiEntropy","Intermodes")),
      error=function(e) print(paste("Error in image processing:",e,sep="")),
      finally=print("Finished")
    )
  }
}

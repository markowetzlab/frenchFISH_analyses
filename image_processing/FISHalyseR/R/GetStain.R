###
# lImage - label mask image
# Channel - gray image with the probes
# dimension - dimension of the feature list
#
# Return FCells - features of the cells
#        PList -  pixel list, probe id,  cell id  
# 
###
GetStain <- function(lImage, Channel, dimension) {
      
      FeaturesCells<-matrix(data=NA,nrow=1,ncol=dimension);
      #FeaturesCells<-data.frame();
      PixelList<-list()
      
      # loop through all the cells from the label image
      for (i in 1:max(lImage)){
         
            iCell<-lImage==i    # corresponding cell pixel values will be true or 1 other pixels 0
            # return only the cell as a binary image
            ROIiCell<-GetROI(iCell) #get bounding box around cell
            
            #get cell from the colour channel image as binary
            ROIChannel<-GetROI(Channel,ROIiCell$Location$x1,ROIiCell$Location$y1,ROIiCell$Location$x2,ROIiCell$Location$y2)   
            
            # only probes will be 1 others 0
            Stain<-ROIiCell$ROI*ROIChannel$ROI
            
            # label the probes to the pixels coordinates of the probes
            LabelStain<-bwlabel(Stain)
            
            if ((max(LabelStain)>0) && all(dim(LabelStain)>60)){ #else no probe found (or cell to small)
                  
                  Features<-computeFeatures(LabelStain,Stain,methods.noref=c('computeFeatures.moment','computeFeatures.shape'),properties=FALSE)
                  
                  # features of each cell as a row - last column indicates the cell id
                  FeaturesCells<-rbind(FeaturesCells,cbind(Features,matrix(data=i,nrow=dim(Features)[1],ncol=1)));     #add index i (pos 89)
                  
                  #add list of pixels for probes in the cells
                  for (j in 1:max(LabelStain)){                                           #pixellist, probesid, cellid
                        PixelList[length(PixelList)+1]<-list(list(list(which(LabelStain==j,arr.ind=TRUE)),j,i))
                  }
            }
            #if not does not contain this probe
      }
      return(list(FCells=FeaturesCells,PList=PixelList))
}

###
#
# Return the cell image pixel list
# bounding box coordinates of the the cell
#
###
GetROI <- function(bImage,x1=NA,y1=NA,x2=NA,y2=NA){ #left upper corner, right lower corner
      if (is.na(x1)){ # no coordinates provided
            ListOfPixel<-which(bImage,arr.ind=TRUE)  
            ROI<-bImage[min(ListOfPixel[,1]):max(ListOfPixel[,1]),
                        min(ListOfPixel[,2]):max(ListOfPixel[,2])]
            x1<-min(ListOfPixel[,2])
            y1<-min(ListOfPixel[,1])
            x2<-max(ListOfPixel[,2])
            y2<-max(ListOfPixel[,1])
      }else{
            ROI<-bImage[y1:y2,x1:x2]    
      }
      return(list(ROI=ROI,Location=list(x1=x1,y1=y1,x2=x2,y2=y2)))
}

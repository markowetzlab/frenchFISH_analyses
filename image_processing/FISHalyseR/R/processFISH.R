###
# 1. combinedImg - combined image;  RGB images composed of all available stains
# 2. writedir - Output directory
# 3. bgCorrMethod - list with two arguments. Currently three types are supported: 
#                 0 - None 
#                 1 - gaussian blur (current) 
#                     e.g. bgCorrMethod <- list(1, 100)
#                 2 - User-provided illumination image
#                     e.g. bgCorrMethod <- list(2,"/exIllCorr.png")
#                 3 - illumination correction if multiple images are available
#                     e.g. bgCorrMethod <- list(3,"/path/to/stack","*.png",6)
# 4. channelSignals - list of paths to channel image probes
# 5. channelColours - list of color modes with names
#                    e.g. channelColours <- list(R=c(255,0,0),G=c(0,255,0),B=c(0,0,255))
# 6. sizeNucleus - c(5,100)  - Analyse only nuclei within that range (in pixels)
# 7. sizeProbe - c(5,100) - Analyse only probes within that range (in pixels)
# 8. maxprobes - Maximum limit for probes per nuclei
# 9. outputImageFormat - specify output format e.g. jpg or png
###
processFISH <- function(combinedImg, writedir, bgCorrMethod=list(1,100), channelSignals=NULL, channelColours=NULL,sizeNucleus = c(5,15000), sizeProbe =c(5,100), gaussigma=20,outputImageFormat=".png"){      
      starttime <- Sys.time()
      
      #--------------- check the argument types ---------------------------------------
      checkArguments(writedir,channelSignals,channelColours,sizeNucleus,sizeProbe)
          
      imageName<-basename(combinedImg)
      
      # load the combined image
      tryCatch({
            
            CombinedChannel = readImage(combinedImg)
            
      },error=function(cond) {
            stop(paste("Composite image not found: ",combinedImg ))
      }
      )
      
      #check gray image or color image and change the color image to gray 
      if(length(dim(CombinedChannel)) != 2){
            imgG <- channel(CombinedChannel,"gray")
      }else{
            imgG <- CombinedChannel
      }
      dimension  = dim(imgG)
      
      #making directory with the imagename and set as working dir to store the outputs
      message('setting up directory structure')
      rootdir <- setUpDirectory(writedir,imageName)
      
      writeArguments(bgCorrMethod,channelColours,channelSignals,sizeNucleus,sizeProbe)

      #------------------------  background correction --------------------------------
      illu <- NULL
      CellMask <- NULL
      if(is.list(bgCorrMethod)){
          if(bgCorrMethod[[1]]>0){
            if(bgCorrMethod[[1]]==1){
                  message('Multiple Gaussian blurring background subtraction...')
                  if(is.numeric(bgCorrMethod[[2]])){
                        illu = gblur(imgG, sigma=gaussigma)
                        
                        for(i in 1:bgCorrMethod[[2]]){
                              illu = gblur(illu, sigma=gaussigma)
                        }
                        
                        CellMask <- imgG - illu + mean(illu)
                        CellMask[CellMask<0] <-0
                  }else{
                        stop('Background subtraction arguments are not correct')
                  }
            }else if(bgCorrMethod[[1]]==2){
                  # read the illumination image
                  message('Using user specified illumination corrcetion image...')
                  
                  if(file.exists(bgCorrMethod[[2]])){
                        illu = readImage(bgCorrMethod[[2]])
                        illu = gblur(illu, sigma=gaussigma)
                        CellMask= imageSubtract(imgG,illu)
                        
                  }else{
                        stop('Background subtraction arguments are not correct')
                  }
                 
                  
            }else if(bgCorrMethod[[1]]==3){
                  # compute illumation image from the stack of images
                  
                  print('Computing illumination correction image from stack')
                  illu <- computeIlluminationCorrection(bgCorrMethod[[2]], bgCorrMethod[[3]],bgCorrMethod[[4]])
                  CellMask= imageSubtract(imgG,illu)
                  
            }else{
                  stop('argument should 1 or 2 or 3')
            }
      }else{
        message('No illumination correction method selected')
        #set illumination correction image to black
        illu<-imageSubtract(imgG,imgG) #black image 
        CellMask<-imgG        
      }
      }
      else{
            stop('bgCorrMethod should be type list')
      }
      
      message('Extracting mask from the image....')
      CellMask = processCombined(CellMask,sizeNucleus)
      dim(CellMask) = c(dimension[1],dimension[2])
            
      message('Dividing nuclei')
      gradImage = bwPerim(CellMask)
      CellMask[gradImage>0.03] <- 0
      
      # write Mask Image 
      writeImage(CellMask,paste(imageName,'_Cellmask',outputImageFormat,sep=""))
      
      # overlay of the cell mask - for visualization of the combined image
      ImCom <- rgbImage(red=0*gradImage, green=gradImage, blue=gradImage)
      
      # ----------------------- extracting probes information ------------------------------
      message('Processing channel probes')
      channelImg <- list()
      
      # if the combined image is a color image and length is 1
      # extract the color channels from RGB channels
      img = readImage(channelSignals[[1]])
      
      # process only if it is color image and channel argument is one
      if(isColorImage(img)==1 && length(channelSignals)==1){
            
            #extract colors from the combined image
            message('Extracting Red, Green, Blue from the combined cell image')
            
            channelImg[[1]] <- img[,,1]
            channelImg[[2]] <- img[,,2]
            channelImg[[3]] <- img[,,3]
            
            # for in the CSV file rr, gg, bb
            channelColours = list(r=c(255,0,0), g= c(0,255,0),b=c(0,0,255))
            
      }else{
            message('loading channels .....')
            
            for(i in 1:length(channelSignals) ){
                  #print(i)
                  img = readImage(channelSignals[[i]])
                  channelImg[[i]] <- img
            }
      }
      
      n <- names(channelColours)
      
      #process all the color channels
      for(im in 1:length(channelImg)){
            message(paste('loading channel : ',n[im],sep=""))
            
            imgG <- imageSubtract(channelImg[[im]],illu)
            
            imgG = processChannels(imgG, sizeProbe[2], sizeProbe[1])
            channelImg[[im]] <- imgG
            
            writeImage(imgG, paste(imageName,'_',names(channelColours)[im],outputImageFormat,sep=""))
      }
      
      ImageOverlay <- combineImage(channelImg,ImCom,channelColours,dimension[1],dimension[2])

      writeImage(ImageOverlay ,paste(imageName,'_Overlay.png',sep=""))
      writeImage(ImageOverlay ,paste(imageName,".png",sep=""))
      
      
      # ------------------------ EXTRACT FISH PROCESS ---------------------------------
      message('extracting features from the cell mask image')
      LabelCellmask<-bwlabel(CellMask)
      
      # save cell id as an Image
      message('saving label image with cell id')
      plotLabelMatrix(LabelCellmask,paste(imageName,'_Label.jpg',sep=''))
      
      message('computing features .... ')
      FeaturesCellmask<-computeFeatures(LabelCellmask,CellMask,methods.noref=c('computeFeatures.moment','computeFeatures.shape'),properties=FALSE)
      
      cellIndex = dim(FeaturesCellmask)[2] + 1
      
      # computing probe features and pixel coordinates for each probes with coresponding cell id
      cellInfo <- list()
      
      for(i in 1:length(channelImg)){
            message(paste("Processing channel ", n[[i]], sep=""))
            cellStr <- GetStain(LabelCellmask,channelImg[[i]],cellIndex)
            cellInfo[[n[[i]]]] <- cellStr
            save(cellStr, file=paste('./RData/',imageName,'_',n[i],'.RData',sep=''))
      }

      # ------------- find max probes in each cell id -----------------------------------
      
      # create columns as length of channels
      # rows to store cell ids
      maxCellProbe <- matrix(data=NA,nrow=max(LabelCellmask),ncol=length(n))
      for (iCell in 1:max(LabelCellmask)){ 
            
            for(i in 1:length(channelColours)){
                  maxCellProbe[iCell,i] <- length(which(cellInfo[[n[i]]]$FCells[,cellIndex]==iCell))
            }
      }
      
      #---------------------------- Distances ------------------------------------------

      message("Computing distances between probes")
      
      dMatChannels <- list()
      maxProbeDist <- list()
      
      datanamelist <- list()
      probeAreaNames <- list()
      
      for (i in 1:length(channelColours)){
            for(j in 1:length(channelColours)){
                  if(i==j){
                        #process same channels
                        message (paste("computing distance between ",n[i]," and ", n[j], sep=""))
                        # get the featurers
                        same1 <- cellInfo[[n[i]]]$FCells
                        same2 <- cellInfo[[n[j]]]$FCells
                        cname <- paste(n[i],n[j],sep="")
                        distMatSame <-  GetDistances(same1,same2,cellInfo[[n[i]]],cellInfo[[n[j]]],isOneColour=1)
                        dMatChannels[[cname]] <- distMatSame
                        maxProbeDist[[cname]] <- findProbeMaxLength(distMatSame, 1)
                        
                        # calculating names for data frame
                        if(maxProbeDist[[cname]][1]!=0){
                              ind <- 1
                              for(x in maxProbeDist[[cname]][1]:1){
                                    for(y in 1:x){
                                          datanamelist[length(datanamelist)+1] <- paste(n[i],ind,' ',n[j],y+ind,sep="")
                                    }
                                    ind<- ind +1
                              }
                              
                              mprobesame <- maxProbeDist[[cname]][1]+1
                              for(x in 1:mprobesame){
                                    probeAreaNames[length(probeAreaNames)+1] <- paste("A",n[i] ,x,sep="")
                              }
                        }else{
                              probeAreaNames[length(probeAreaNames)+1] <- 'not found'
                              datanamelist[length(datanamelist)+1] <- 'not found'
                        }

                  }else {
                        if(j<=i){
                              next
                        }else{
                              message (paste("computing distance between ",n[i]," and ", n[j], sep=""))
                              # get the featurers
                              diff1 <- cellInfo[[n[i]]]$FCells
                              diff2 <- cellInfo[[n[j]]]$FCells
                              cname <- paste(n[i],n[j],sep="")
                              distMatDiff <-  GetDistances(diff1,diff1,cellInfo[[n[i]]],cellInfo[[n[j]]],isOneColour=0)
                              dMatChannels[[cname]] <- distMatDiff
                              maxProbeDist[[cname]] <- findProbeMaxLength(distMatDiff, 0)
                              
                              # calculating names for data frame
                              
                              if(maxProbeDist[[cname]][1]!=0 && maxProbeDist[[cname]][2]!=0){
                                    for(x in 1:maxProbeDist[[cname]][1]){
                                          for(y in 1:maxProbeDist[[cname]][2]){
                                                
                                                datanamelist[length(datanamelist)+1] <- paste(n[i],x,' ',n[j],y,sep="")
                                                
                                          }
                                    }
                              }else{
                                    datanamelist[length(datanamelist)+1] <- 'not found'
                              }
                              
                        }
                  }
                  
            }    # end of for loop
      }
      
      #-------------------------- data analyse -----------------------------------
      
      Analysis.data<-data.frame()
      message('saving data to csv file ............ ')
      
      for (iCell in 1:max(LabelCellmask)){
            message(paste('processing cell id: ',iCell))
            # have to write cells
            Nucleus<-GetNucleus(CombinedChannel,iCell,FeaturesCellmask)
            writeImage(Nucleus, paste('./cells/','CellID',iCell,'.png',sep=''))
            
            Nucleus<-GetNucleus(ImageOverlay,iCell,FeaturesCellmask)
            writeImage(Nucleus,paste('./cells/','CellID',iCell,'_a.png',sep=''))
            
            probeDist <- list()
            probeArea <- list()
            # calculating the distances every channels for each cells
            for (i in 1:length(channelColours)){
                  for(j in 1:length(channelColours)){
                        if(i==j){
                              cname <- paste(n[i],n[j],sep="")
                              probeDist[[cname]] <- CreateOutputDistanceVector(dMatChannels[[cname]],iCell,maxProbeDist[[cname]],isOneColour=1)
                              
                              mprobesame <- maxProbeDist[[cname]][1]+1
                              probeArea[[cname]]  <- CreateOutputAreaVector(cellInfo[[n[[i]]]]$FCells,iCell,maxProbeDist[[cname]][1])
                              
                        }else{
                              if(j<=i){
                                    next
                              }else{
                                    cname <- paste(n[i],n[j],sep="")
                                    probeDist[[cname]] <- CreateOutputDistanceVector(dMatChannels[[cname]],iCell,maxProbeDist[[cname]],isOneColour=0)
                              }
                        }
                  }
            }
            
            # create a data frame
            Analysis.data <- rbind(Analysis.data, data.frame(paste(imageName,'.png',sep=''),
                                                             iCell,
                                                             FeaturesCellmask[iCell,'x.0.m.eccentricity'],
                                                             
                                                             rbind(maxCellProbe[iCell,]), # num of probes in a channel
                                                             
                                                             rbind(unlist(probeDist,use.names=FALSE)), # all the distances probe
                                                             
                                                             FeaturesCellmask[iCell,'x.0.m.cx'],    #X of center of mass of nucleus
                                                             FeaturesCellmask[iCell,'x.0.m.cy'],    #Y of center of mass of nucleus
                                                             FeaturesCellmask[iCell,'x.0.s.area'],    #area of nucleus
                                                             FeaturesCellmask[iCell,'x.0.s.perimeter'],    #perimeter of nucleus
                                                             FeaturesCellmask[iCell,'x.0.s.radius.mean'],   #mean radius of nucleus    
                                                             
                                                             rbind(unlist(probeArea,use.names=FALSE))
            ))
            
      }
      
      # ------------------------------ column names -----------------------------------------
      dataColNames <- list()
      dataColNames[1] <- "filename"
      dataColNames[2] <- "nucleus ID"
      dataColNames[3] <- "eccentricity"
      
      for(i in 1:length(channelColours)){
            dataColNames[length(dataColNames)+1] <- paste("num of ",n[i]," probes",sep="")
      }
      
      # append distance names 
      dataColNames <- c(dataColNames, datanamelist)
      
      dataColNames[length(dataColNames)+1] <- 'X center of mass'
      dataColNames[length(dataColNames)+1] <- 'Y center of mass'
      dataColNames[length(dataColNames)+1] <- 'area of nucleus'
      dataColNames[length(dataColNames)+1] <- 'perimeter of nucleus'
      dataColNames[length(dataColNames)+1] <- 'radius of nucleus'
      
      # names for the probe areas
      dataColNames <- c(dataColNames, probeAreaNames)
      
      # add names to data frame
      colnames(Analysis.data) <- dataColNames
      
      write.table(Analysis.data, paste('./csv/',imageName,'_data.csv',sep=''), sep=",", row.names=FALSE, col.names=TRUE) 
      
      save(Analysis.data, file=paste('./RData/',imageName,'_final.RData',sep=''))

      message('Done processing fish data ...')
      
      endtime <- Sys.time()
      timetaken <-  endtime - starttime
      print(timetaken)
}

###
# Processing the combined image
###
processCombined <- function(imgG,sizeNucleus) {
      
      # get the background subtracted image
      imgG  = medianFilter(imgG, 5)
      
      message('thresholding the nuclei ...')
      t=calculateThreshold(imgG)
      imgG[imgG < t] <- 0
      imgG[imgG >= t] <- 1
      
      imgG  = medianFilter(imgG, 5)
      
      kern = makeBrush(5, shape='disc')
      imgG = erode(imgG, kern)
      
      message('analysing the nuclei ...')
      imgG = analyseParticles(imgG,sizeNucleus[2],sizeNucleus[1],1)
      
      return (imgG)
}

###
#
# processing probes
#
###
processChannels <- function(Image, Maxsize, Minsize){  
      t = calculateMaxEntropy(Image)
      Image = applyThreshold(Image,t)
      Image = analyseParticles(Image,Maxsize,Minsize,0)
      return (Image)
}



bwPerim <- function(Image){
      y = distmap(Image)
      Image = watershed(y)
      fx = matrix(c(1, 2 ,1, 0,0,0,-1,-2,-1), ncol=3, nrow=3)
      fy = t(fx)
      Ix = filter2(Image, fx)
      Iy = filter2(Image, fy)
      gradient = sqrt (Ix^2 + Iy^2)
      return (gradient)
}

imageSubtract <- function(Image1, Image2){
      Image1  = Image1 - Image2
      Image1[Image1<0]<-0
      return (Image1)
}

applyThreshold <- function(Image, t){
      Image[Image<t]<-0
      Image[Image>=t]<-1
      return (Image)
}

###
#
# Write arguments to a file
#
###
writeArguments <- function(bgCorrMethod,channelColours,channelSignals,sizeNucleus, sizeProbe){
      string1 = "Argument list"
      
      string1 = c(string1,"---- Background subtraction ----")
      if(is.list(bgCorrMethod)){
            if(bgCorrMethod[[1]]==1){
                  string1 <- c(string1, "Multiple Gaussian blurring")
                  
            }else if(bgCorrMethod[[1]]==2){
                  string1 <- c(string1, "Subtract user-specified illumination image")
                  
            }else if(bgCorrMethod[[1]]==3){
                  string1 <- c(string1, "Multidimensional Illumination Correction")
            }
      }
      
      if(is.list(channelColours) && is.list(channelSignals)){ 
            string1 = c(string1, 'Probes information')
            for(i in 1:length(channelColours)){
                  chval <- paste(channelColours[[i]], collapse=', ')
                  string1 = c(string1, paste(names(channelColours)[i],chval,channelSignals[[i]] , sep=" - "))
            }
      }

      string1 = c(string1,"---- Analyse Cells ----")
      string1 = c(string1,paste('Maximum area', sizeNucleus[1], sep=" - "), paste('Minimum area', sizeNucleus[2], sep=" - "))

      string1 = c(string1,"---- Analyse Probes ----")
      string1 = c(string1,paste('Maximum area', sizeProbe[1], sep=" - "), paste('Minimum area', sizeProbe[2], sep=" - "))

      fileConn<-file("arguments.txt")
      writeLines(string1, fileConn)
      close(fileConn)
}

###
#
# set up directory structure for store the output values
#
###
setUpDirectory <- function(writedir,imageName){
      maindir = paste(writedir,imageName,sep="")
      if (file.exists(maindir)){
            setwd(file.path(maindir))
            # clean up the directory structure
            unlink(paste(maindir,'/*',sep=""), recursive =TRUE)
      } else {
            dir.create(file.path(maindir),recursive=TRUE)
            print(paste('Setting work directory to ',file.path(maindir),sep=''))
            setwd(file.path(maindir))
      }
      
      #write parameters for debugging purpose
      #system(paste('mkdir -p',' ./csv/',sep=''))
      #system(paste('mkdir -p',' ./cells/',sep=''))
      #system(paste('mkdir -p',' ./RData/',sep=''))
      dir.create('./csv/')
      dir.create('./cells/')
      dir.create('./RData/')     
      return(maindir)
}

###
#
# combine all the channel images
# channelImg - list of channel
# ImCom - combined image
#
###
combineImage <- function(channelImg, ImCom, channelColours, dim1, dim2){
      
      c1 <- matrix(rep(0,dim1*dim2), nrow=dim1, ncol=dim2)
      c2 <- matrix(rep(0,dim1*dim2), nrow=dim1, ncol=dim2)
      c3 <- matrix(rep(0,dim1*dim2), nrow=dim1, ncol=dim2)
      n <- names(channelColours)
      for(i in 1:length(channelImg)){
            channel <- channelImg[[i]]
            c1 <- c1 + channel*(channelColours[[n[i]]][1]/255)
            c2 <- c2 + channel*(channelColours[[n[i]]][2]/255)
            c3 <- c3 + channel*(channelColours[[n[i]]][3]/255)
      }
      c1 <- c1 + imageData(ImCom)[,,1]
      c2 <- c2 + imageData(ImCom)[,,2]
      c3 <- c3 + imageData(ImCom)[,,3]
      # add overlay image to this 
      imCombined = rgbImage(red=c1, green=c2, blue=c3)
      return(imCombined)
}

###
#s
# validate the user arguments
#
#check all the argument types before processing
# 1. writedir exists
# 2. bgCorrMethod is list type
# 3. sizeNucleus and sizeProbes is numeric with length 2
# 4. channelColours is list and arguments color is length 3 and numeric
# 5. channelCell is list
###
checkArguments <- function (writedir,channelSignals,channelColours,sizeNucleus,sizeProbe){
      
      if(file.exists(writedir)){
            
            # check cell size arguments
            if(length(sizeNucleus)!=2 || class(sizeNucleus)!="numeric" || length(sizeProbe)!=2 || class(sizeProbe)!="numeric"){
                  stop('sizeNucleus or sizeProbe arguments are not correct type or length')
            }
            
            # check channel probes arguments
            if( is.list(channelColours) && is.list(channelSignals)){
                  
                  if(length(names(channelColours))!=0){
                        for(x in names(channelColours)){
                              if(nchar(x)==0){
                                    stop('channelColours should have values for all the channels')
                              }
                              a<- channelColours[[x]]
                              if(length(a)!=3 || class(a)!="numeric"){
                                    stop("colour channels arguments are not  umeric values or length of 3")
                              }
                              if(!all((a<=255 & a>=0)==TRUE)){
                                    stop('color channel values should be between 0 to 255')
                              }
                        }
                  }else{
                        stop('channelColours should have list names')
                  }
            }else{
                  stop('channelColours and channelSignals arguments should be of type list') 
            } 
      }else{
            dir.create(writedir, showWarnings = TRUE, recursive = TRUE)
      }
}

GetNucleus <- function(Image,iCell,Features){
      # todo max radius
      MaxRadius<-Features[iCell,'x.0.s.radius.max']
      Width<-(MaxRadius+5)*2 #add 5 px frame
      Height<-(MaxRadius+5)*2 #add 5 px frame
      OriginX<-Features[iCell,1]-Height/2  #top left corner
      OriginY<-Features[iCell,2]-Width/2
      if (OriginX<0){
            OriginX<-0
      }
      if (OriginY<0){
            OriginY<-0
      }
      if (OriginX+Height>dim(Image)[2]){
            Height<-round(Height-((OriginX+Height)-dim(Image)[2]))
      }
      if (OriginY+Width>dim(Image)[1]){
            Width<-round(Width-((OriginY+Width)-dim(Image)[1]))
      }
      Nucleus<-Image[round(OriginX):round(OriginX+Height),round(OriginY):round(OriginY+Width),]
      return(Nucleus)
}

plotLabelMatrix<-function(Image,Filename){
      AnnotatedImage<-GlobalThreshold(Image,0.05);
      AnnotatedImage<-flip(AnnotatedImage)
      Image<-flip(Image)
      
      Features<-computeFeatures(Image,Image,methods.noref=c('computeFeatures.moment','computeFeatures.shape'),
                                properties=FALSE)
      MaxX=dim(Image)[1]
      MaxY=dim(Image)[2]
      jpeg(filename=Filename)
      image(seq(dim(AnnotatedImage)[1]), seq(dim(AnnotatedImage)[2]), AnnotatedImage, xlab="",ylab="")
      
      for (i in 1:max(Image)){
            text(Features[i,1], Features[i,2], i, cex=0.8,col="blue")
      }
      
      garbage <- dev.off()
}

GlobalThreshold<-function(Image,Threshold){
      return((Image>=Threshold)*1)
}

isColorImage <- function(Img){
      dimension <- dim(Img)
      valr <- 0
      if(length(dimension)==3){
            if(dimension[3]==3){
                  valr <- 1
            }
      }
      return(valr)
}

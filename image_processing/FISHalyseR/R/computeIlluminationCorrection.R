###
# 
# Compute the illumination correction image from the stack of images
###
computeIlluminationCorrection<-function(Images,pattern='*',AmountOfFiles=6){
      ListOfFiles<-dir(Images,pattern)
      tmp<-getwd() #backup wd
      tryCatch({
            setwd(Images)         
      },error=function(cond) {
            stop(paste("Image path is not valid"))
      }
      )
      
     
      idx <- file.info(dir(Images,pattern))$size
      #f <- dir()[grepl('Da', dir())]
      #idx <- idx[grepl('Da', dir())]
      
      #sort only the images you got
      ListOfFiles <- ListOfFiles[sort.list(idx, decreasing=TRUE)]
      setwd(tmp)
      
      if(length(ListOfFiles)<AmountOfFiles){
            stop('amount of files are less')
      }
      
      #ListOfFiles<-ListOfFiles[1:AmountOfFiles] #take the first n files
      for (i in 1:length(ListOfFiles)){
            print(paste('Reading',ListOfFiles[i]))
            I<-readImage(paste(Images,'/',ListOfFiles[i],sep=''))
            I<-channel(I,'gray') 
            Ip<-imComplement(I) 
            if (i==1){
                  Combined<-array(dim=c(dim(Ip)[1],dim(Ip)[2]))
            }
            Combined<-abind(Combined,Ip,along=3)
      }
      
      #get maximum == background
      I<-imComplement(apply(Combined,1:2, function(x) Mode(x)))
      I<-gblur(I,s=5)
      I<-as.Image(I)
      return(I)
}

imComplement<-function(Image){
      return((Image-1)*-1)
}

Mode <- function(x) {
      ux <- unique(x)
      ux[which.max(tabulate(match(x, ux)))]
}
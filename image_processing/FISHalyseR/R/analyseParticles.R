###
# analyse particles
# remove particles between MaxSize and MinSize (smaller Nucleus)
# return the binary image
###
analyseParticles <-function(Image,MaxSize,MinSize,isMask){
      
      l<-bwlabel(Image)
      RegionProperties<-computeFeatures.shape(l)
      
      if(isMask==1){
            # In case as nucleus mask is passed to the function remove nuclei that have an  
            # area smaller than MaxSize and greater than MinSize
            idx1<-which(RegionProperties[,"s.area"]>MaxSize)
            idx2<-which(RegionProperties[,"s.area"]<MinSize)
            idx<-sort(union(idx1,idx2))
      }else if(isMask==0){
            # In case a probes images, remove those with an area smaller than MinSize 
            # and greater than MaxSize            
            idx<-which(RegionProperties[,"s.area"]<MinSize | RegionProperties[,"s.area"]>MaxSize )
      }
      l2<-rmObjects(l, as.vector(idx))
      #reenumerate(l2)     
      return((l2>0)*1)
}

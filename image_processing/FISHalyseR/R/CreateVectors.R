###
# 
# calculate the distance vector from the distances matrix
# 
###
CreateOutputDistanceVector <- function(Channel,iCell,maxProbe,isOneColour){
      
      if(maxProbe[1]!=0 && maxProbe[2]!=0){
            
            ProbeIds<-unique(Channel[which(Channel[,2]==iCell),3]) #sort by size
            
            # is different colour total connection per cell - maxCol1 x maxCol2
            if(isOneColour==0){
                  dVector<-matrix(data=NA, ncol=maxProbe[1]*maxProbe[2], nrow=1)
            }else if (isOneColour==1){
                  sum<-0
                  for(i in 1:maxProbe[1]){
                        sum<-sum +i
                  }
                  dVector<-matrix(data=NA,ncol=sum,nrow=1)
            }
            
            # we find some probes
            if (length(ProbeIds)>0) {
                  
                  # atleast two rows per cell id
                  if (isTRUE(dim(Channel[which(Channel[,2]==iCell),])[1]>1)){
                        
                        # contains distances per cell id as a matrix
                        SubChannel<-Channel[which(Channel[,2]==iCell),]
                  }else{
                        # make matrix format if it is one row
                        SubChannel<-t(as.matrix(Channel[which(Channel[,2]==iCell),]))
                  }
                  
                  if(isOneColour==1){
                        
                        pos <- maxProbe[1]
                        first <- 1
                        for( i in ProbeIds){
                              lastlen <- (first+pos) -1
                              # print (paste(first," " ,i2))
                              dVector[1,first:lastlen] <- c(SubChannel[which(SubChannel[,3]==i)][1:pos])
                              first <- first+pos
                              pos <- pos -1
                        }
                        
                  }else if(isOneColour==0){
                        idVector=seq(1, maxProbe[1]*maxProbe[2], maxProbe[2])
                        pos<-1
                        
                        for (i in ProbeIds){
                              dVector[1,idVector[pos]:(idVector[pos]+(maxProbe[2]-1))]<-c(SubChannel[which(SubChannel[,3]==i)][1:maxProbe[2]]) #sort()
                              pos <- pos +1
                        } 
                  }
            }
      }else{
            dVector = matrix(data=c(-999), nrow=1, ncol=1)
      }
      return (dVector)
}

###
# 
# Channel - features of the probes with their cell id
# MaxNElements - maximum no of probes within a cell 
#         more MaxNElements - sorted select first MaxNElements
#         less MaxNElements - fill with NA
# return the areas of the probe within a cell 
# 
###
CreateOutputAreaVector <- function(Channel,iCell,MaxNElements){
      
      # iCell is the CellID
      if(MaxNElements!=0){
            celIndex =  ncol(Channel)
      
            nProbes<-length(Channel[which(Channel[,celIndex]==iCell),'x.0.s.area'])
            
            aVector <- matrix(data=NA, ncol=MaxNElements+1, nrow=1)
            
            if(nProbes>0){
                  aVector[1,1:nProbes] <-Channel[which(Channel[,celIndex]==iCell),'x.0.s.area']
            }
      }else{
            dVector = matrix(data=c(-999), nrow=1, ncol=1)
      }
      return(aVector)
}

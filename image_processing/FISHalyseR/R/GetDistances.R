###
# Channel1, Channel2 - features of the probes with cell id
# 
# Channel1PList, Channel2PList
# - features of the probes with cellid
# - pixel lists - (pixel coordinates, probe id, cell id)
#
# isOneColour 1- same color channel
#             2- different color channel
# 
# return - dMat_RG : dist , cellid, channel1 probe ids
###
GetDistances <- function(Channel1,Channel2,Channel1PList,Channel2PList,isOneColour) {
      
      #count the number of the column
      celIndex =  ncol(Channel1)
      
      # remove NA from the first row 
      Channel1<-na.exclude(Channel1)
      Channel2<-na.exclude(Channel2)
      
      #omit this part - we already know what channels are processing - generic way - test if Channel1 == Channel2
#       if (isTRUE(all.equal(Channel1,Channel2))) { #we are comparing e.g. red vs red
#             print('One colour mode ON')
#             isOneColour<-1
#       }else{
#             isOneColour<-0
#       }
      
      RowCounter<-1
      # length should be greater than 0 to compute distances between two channel probes
      # if length is 0 then no probes in the channel so we omit
      if (length(Channel1)>0){
            
            # get the uni cell ids from the last column
            IdOfCells<-unique(na.exclude(Channel1[,celIndex],na.rm=TRUE)) #it is sufficient to calculate the distance between C1 vs C2
            
            if (isOneColour==1){
                  dMat<-matrix(data=NA,nrow=30*length(IdOfCells),ncol=3) #2nd col =  id of Cell, 3rd = if of probe  //TODO: 30(3) max probes
            }else{
                  dMat<-matrix(data=NA,nrow=160*length(IdOfCells),ncol=3) #2nd col = id of Cell, 3rd = if of probe   16 = 4x4 x amountOfCells (OdOfCells) //TODO: 160(16) max probes
            }
            
            if (max(IdOfCells)>=0){ # cells found
                  
                  # loop through the cells
                  for (iCell in IdOfCells){
                        # rowid at the top
                        # element id which are equal to cell id 
                        IdChannel1<-which(na.exclude(Channel1[,celIndex]==iCell)); #get rowids of the specific CellID
                        IdChannel2<-which(na.exclude(Channel2[,celIndex]==iCell));
                       
                        MaxDots1<-length(IdChannel1) # how many dots of this kind has the cell with this id
                        MaxDots2<-length(IdChannel2)
                        
                        d<-CalcDistAll(Channel1PList,Channel2PList,iCell,isOneColour)              
                        
                        if (length(d)>=1){ #else only one probe was found
                              
                              # loop through the distances 
                              for (l in 1:length(d)){
                                    dMat[RowCounter,1]<-as.numeric(d[[l]][['Dist']]) #fill matrix with distances
                                    dMat[RowCounter,2]<-iCell
                                    dMat[RowCounter,3]<-as.numeric(d[[l]][['ProbeId']]) 
                                    RowCounter<-RowCounter+1
                              }
                        }

                  } #cell loop
                  dMat<-unique(na.exclude(dMat)); #remove all the temporary NAs placed during initialisation and the 
            }
      }else{ #no probe found
            message('No probe found!')
            if (isOneColour==1){
                  dMat<-rbind(c(NA,NA,NA),c(NA,NA,NA),c(NA,NA,NA))
            }else{
                  dMat<-rbind(c(NA,NA,NA),c(NA,NA,NA),c(NA,NA,NA),
                              c(NA,NA,NA),c(NA,NA,NA),c(NA,NA,NA),
                              c(NA,NA,NA),c(NA,NA,NA),c(NA,NA,NA),
                              c(NA,NA,NA),c(NA,NA,NA),c(NA,NA,NA),
                              c(NA,NA,NA),c(NA,NA,NA),c(NA,NA,NA),
                              c(NA,NA,NA))
                  
            }
      }
      return(dMat)
}

###
#
# calculate all the dist and get the smallest dist
#
# Channel1PList, Channel2PList
# - features of the probes with cellid
# - pixel lists - (pixel coordinates, probe id, cell id)
# 
#  CellID - id of the cell
#  
###
CalcDistAll <- function(s1,s2,CellId,isOneColour=0){  #returns list (distance) of lists (probeid)
      Distance<-list()  #initialze with arbitrary high number 
      
      #get length of the probes
      LengthS1<-length(s1[['PList']])
      LengthS2<-length(s2[['PList']])  
      #matrix(data=unlist((s1[['PList']][[l1]][[1]])),nrow=length(unlist(s1[['PList']][[l1]][[1]]))/2,ncol=2)
      #if ((LengthS1 > 0) & (LengthS2 > 0)){
      
      #loop through the probes
      for(l1 in 1:LengthS1){
            
            # get the cell id for the probe
            if (s1[['PList']][[l1]][3]==CellId){
                  
                  #loop through the probes
                  for(l2 in 1:LengthS2){
                        if (s2[['PList']][[l2]][3]==CellId){
                              #check if it is the same probe
                              
                              #print(paste('l1=',l1,' l2=',l2))
                              
                              if (isOneColour==1){
                                    if (l2<=l1){
                                          next; 
                                          #skip measurement ... else we would measure the same distance twice 
                                          #because if index l2 is smaller than l1 the probe has already been processed
                                    }
                              }
                              if (isTRUE(all.equal(unlist(s1[['PList']][[l1]][1]),unlist(s2[['PList']][[l2]][1])))){
                                    print('Skipping probe ... comparison versus same probe')
                                    next; #skip this one ... 
                              }else{
                                    # length of the pixel list - unlist 2 column matrix and divide by 2
                                    # can use nrow(s1[['PList']][[l1]][[1]][[1]])
                                    LengthP1<-length(unlist(s1[['PList']][[l1]][[1]]))/2
                                    LengthP2<-length(unlist(s2[['PList']][[l2]][[1]]))/2 
                                    
                                    # list of pixels coordinates
                                    ListP1<-unlist(s1[['PList']][[l1]][[1]][[1]])
                                    ListP2<-unlist(s2[['PList']][[l2]][[1]][[1]])
                                    
                                    tDistance<-list()
                                    for(p1 in 1:LengthP1){ #loop through the pixels            
                                          for(p2 in 1:LengthP2){ #loop through the pixels  
                                                x1<-ListP1[p1,1]
                                                x2<-ListP2[p2,1]
                                                y1<-ListP1[p1,2]
                                                y2<-ListP2[p2,2]
                                                d<-CalcDist(x1,y1,x2,y2)
                                                tDistance[length(tDistance)+1]<-d
                                          }
                                    }
                                    Distance[length(Distance)+1]<-list(list(Dist=min(unlist(tDistance)),ProbeId=s1[['PList']][[l1]][2])) #store all distances (smallest one is then selected) and the respective probe
                              }
                        }
                  }
                  
            } #first probe          
      }
      # } #if
      #   if (Distance==0){
      #     Distance<-(-1) #colocalization
      #   }
      return(Distance)
}

###
#
# find the maximum number of probes amoung all of the cells for each channels
# return
#     maxProbes (c1,c2) - for the same channels c1- (max-1) probe in that chnnel, c2- total length of distance
#                         diff channel c1, c2 max probes of each channels
###
findProbeMaxLength <- function(Channel, isOneColour){
      cells <- unique(Channel[,2])
      maxProbes <- c(0,0)
      
      #if no distances between channels
      if(unique(!is.na(cells))){
            
            for (iCell in cells){
                  
                  # atleast two rows per cell id
                  if (isTRUE(dim(Channel[which(Channel[,2]==iCell),])[1]>1)){
                        
                        # contains distances per cell id as a matrix
                        SubChannel<-Channel[which(Channel[,2]==iCell),]
                  }else{
                        
                        # make matrix format if it is one row
                        SubChannel <- t(as.matrix(Channel[which(Channel[,2]==iCell),]))
                  }
                  
                  #same colour
                  if(isOneColour==1){
                        
                        # number of (probes-1) in a cell
                        lmax <- length(unique(SubChannel[,3]))
                        # total lengh of vector for distances
                        vlen <- dim(SubChannel)[1]
                        
                        if( maxProbes[1] < lmax ){
                              maxProbes[1] <- lmax
                        }
                        
                        if( maxProbes[2] < vlen ){
                              maxProbes[2] <- vlen
                        }
                        
                  }else{
                        # different colour
                        col1Probe <- length(unique(SubChannel[,3]))
                        r <- dim(SubChannel)[1]
                        col2Probe <- r/col1Probe
                        
                        if(maxProbes[1]<col1Probe){
                              maxProbes[1] <- col1Probe
                        }
                        
                        if(maxProbes[2]<col2Probe){
                              maxProbes[2] <- col2Probe
                        }
                  }            
            }
      }
      return (maxProbes)
}


###
#
# Calculate dist between two points
#
###
CalcDist <- function(x1,y1,x2,y2){
      xd = x2-x1
      yd = y2-y1
      Distance = sqrt(xd*xd + yd*yd)
      return(Distance)
}
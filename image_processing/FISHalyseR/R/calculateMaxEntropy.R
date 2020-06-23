###
#  Max Entropy Threshold
###
calculateMaxEntropy <- function(Image){
      
      if(max(Image)<=1 & min(Image)>=0){
            im = Image*255
      }
      
      size = dim(im)
      im = as.vector(im)
      hn = hist(im,breaks=c(0:256),plot=FALSE)$counts
      hn = hn / (size[1]*size[2])
      c = rep(0,256)
      c[1] = hn[1]
      for (l in 2:256){
            c[l]=c[l-1]+hn[l]   
      }
      #low and high entropy
      hl = rep(0,256);
      hh = rep(0,256);
      
      for (t in 1:256){
            #low entropy threshlod
            cl  = c[t]
            if(cl>0){
                  for(i in 1:t){
                        if (hn[i] >=0) {
                              hl[t] = hl[t]- (hn[i]/cl)*log(hn[i]/cl)
                        }
                  }
            }    
            #high entropy threshold
            ch = 1 - c[t]
            if(ch > 0){
                  for ( i in (t+1):256 ){
                        if(!is.na(hn[i])){
                              if ( hn[i]>0 ) {
                                    hh[t] = hh[t] - (hn[i]/ch)*log(hn[i]/ch);
                              }
                        }  
                  }   
            }    
      }
      # Find histogram index with maximum entropy
      h_max =hl[1]+hh[1]
      threshold = 0;
      for(t in 2:255) {
            j = hl[t] + hh[t]
            if(!is.na(j)){
                  if (j > h_max) {
                        h_max = j;
                        threshold = t
                  }
            }
      }
      threshold = threshold/255
      return (threshold)
}
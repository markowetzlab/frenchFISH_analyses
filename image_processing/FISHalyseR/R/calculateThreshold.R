###
#   Calculate Threshold
#   condition: Calculate to BW Image
###
calculateThreshold<- function(Image){
      size = dim(Image)
      hn = hist(as.vector(Image*255),breaks=c(0:256),plot=FALSE)$counts
      wB = 0
      wF = 0
      mB =0
      mF =0
      total = size[1]*size[2]
      sumB =0
      sum = 0
      between=0
      threshold1 = 0.0
      threshold2 = 0.0
      maxi =0
      for (i in 1:256){
            sum = sum + ( i * hn[i])
      }
      for (i in 1:256) {
            wB = wB + hn[i]
            if(wB == 0){
                  next
            }
            wF = total - wB
            if (wF == 0){
                  break 
            }
            sumB = sumB + ( i * hn[i])
            mB = sumB / wB;
            mF = (sum - sumB) / wF
            between = wB * wF * (mB - mF)^2;
            if ( between >= maxi ) {
                  threshold1 = i
                  if ( between > maxi ) {
                        threshold2 = i
                  }
                  maxi = between           
            }
            
      }
      return ( ( threshold1 + threshold2 ) / (2.0*255))
}
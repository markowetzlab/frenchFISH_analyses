illuCorrection = system.file("extdata", "exIllCorr.png", package="FISHalyseR")

combinedImage <- system.file("extdata", "exFish.jpg", package="FISHalyseR")
red_Og   <- system.file("extdata", "exFish_R.jpg", package="FISHalyseR")
green_Gn <- system.file("extdata", "exFish_G.jpg", package="FISHalyseR")
blue_Au  <- system.file("extdata", "exFish_B.jpg", package="FISHalyseR")

# directory where all the files will be saved
writedir = paste(getwd(),'/',sep='')

bgCorrMethod = list(2,illuCorrection)

channelColours = list(R=c(255,0,0),G=c(0,255,0),B=c(0,0,255))
channelSignals = list(red_Og,green_Gn,blue_Au)

sizecell = c(1,100)
sizeprobe= c(5,100)

#processFISH(combinedImage,writedir,bgCorrMethod,channelSignals,channelColours,sizecell,sizeprobe)

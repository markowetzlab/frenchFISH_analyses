 
 // Batch mode on
 setBatchMode(true)
 
// Specify input and output directory
input = getArgument();
output = input;

// Specify total number of slices in cropped stack.
range=10;

run("Clear Results");
print("\\Clear")

// Get all filenames in input directory
list = getFileList(input);
numFiles = list.length;


xPositions = newArray(numFiles);
yPositions = newArray(numFiles);
zPositions = newArray(numFiles);



// Loop through all filenames
for	(i = 0; i < numFiles; i++) {

	// Check if file is .tif format and not a .ome.tif
	if (indexOf(list[i] ,".tif" ) != -1 && indexOf(list[i] ,"ome" ) == -1) {

		// Pull out positions from filename
		xPositions[i] = parseInt(substring(list[i],6,9));
		yPositions[i] = parseInt(substring(list[i],11,14));
		zPositions[i] = parseInt(substring(list[i],16,19));
		
	}
	
}

// Find maxium value of each position
maxX=maxArray(xPositions);
maxY=maxArray(yPositions);
maxZ=maxArray(zPositions);

// Loop through each position
count = 0;
for	(x = 1; x <= maxX; x++) {
	for	(y = 1; y <= maxY; y++) {
		for (c = 1; c <= 4; c++) {
			present=1;
			//print("loading channel: " + c );
			//print("loading x: " + x );
			//print("loading y: " + y );
			for (z = 1; z <= maxZ; z++) {
				for	(i = 0; i < numFiles; i++) {
					
					if (xPositions[i] == x && yPositions[i] == y && zPositions[i] == z) {
									
					// load file
						open (input + list[i], c);
						present=0;
					}
								
					
				}
			}
			if(present==0) {
			// Convert all images from color channel to a stack
			run("Images to Stack", "name=" + c +  " title=[] use");
			}
				
		}
		if(present==0){

		// Move all stacks into single hyperstack and correct order
		run("Concatenate...", "  title=[Concatenated Stacks] open image1=1 image2=2 image3=3 image4=4 image5=[-- None --]");
		run("Stack to Hyperstack...", "order=xyzct channels=4 slices=" + maxZ + " frames=1 display=Grayscale");

		// Set Color for channels

		Stack.setChannel(1) 
		run("Blue"); 

		Stack.setChannel(2) 
		run("Green"); 

		Stack.setChannel(3) 
		run("Red"); 

		Stack.setChannel(4) 
		run("Yellow"); 
		

		
		//run("Clear Results");
		// run custom focus finding plugin with given range
		run("vollaths Focus","range=" + range);

		// get the index of the first slice to be cropped from the results table
		index = getResult("maxPosition", count);
		count = count + 1;

		// find max a min slice positions to be cropped
		maxIndex=index+range;
		minIndex=index+1;
		print("max index: " + maxIndex);
		print("min index: " + minIndex);
	
		// duplicate and crop hyperstack
		run("Duplicate...", "title=croppedHyperstack duplicate slices=" + minIndex + "-" + maxIndex);

		// close old stack
		close("Concatenated Stacks");

		//run maximum projection over z-stacks
		run("Grouped Z Project...", "start=1 stop=range projection=[Max Intensity] title=[Maxproj]");
	
		run("Input/Output...", "jpeg=100 gif=-1 file=.csv use_file copy_row save_column save_row");
			
		//convert
		run("RGB Color");
		run("Grouped Z Project...", "start=1 stop=4 projection=[Max Intensity]");
		run("Enhance Contrast...", "saturated=0.8 normalize");
		outputFileName = "tile_x=" + x + "_y=" + y + "_combined.jpg";
		saveAs("Jpeg", output + outputFileName);
		close();		

		run("Stack to Images");
		
		run("32-bit");
		//run("Measure");
		//mean = getResult("Mean",0);
		//max = getResult("Max",0);
		//max = max+mean;
		//setMinAndMax(mean,max);
		//print("mean=" + mean + " max=" + max);
		run("Enhance Contrast...", "saturated=0.8 normalize");
		outputFileName = "tile_x=" + x + "_y=" + y + "_c=" + 4 +".jpg";
		saveAs("Jpeg", output + outputFileName);
		close();
		
		run("32-bit");
		//run("Measure");
		//mean = getResult("Mean",0);
		//max = getResult("Max",0);
		//max = max+mean;
		//setMinAndMax(mean,max);
		run("Enhance Contrast...", "saturated=0.8 normalize");
		//print("mean=" + mean + " max=" + max);
		outputFileName = "tile_x=" + x + "_y=" + y + "_c=" + 3 +".jpg";
		saveAs("Jpeg", output + outputFileName);
		close();
		
		run("32-bit");
		//run("Measure");
		//mean = getResult("Mean",0);
		//max = getResult("Max",0);
		//max = max+mean*1.5;
		//setMinAndMax(mean*1.5,max);
		run("Enhance Contrast...", "saturated=0.8 normalize");
		//print("mean=" + mean + " max=" + max);
		outputFileName = "tile_x=" + x + "_y=" + y + "_c=" + 2 +".jpg";
		saveAs("Jpeg", output + outputFileName);
		close();
		
		//run("32-bit");
		//run("Measure");
		//mean = getResult("Mean",0);
		//max = getResult("Max",0);
		//max = max+mean;
		//setMinAndMax(mean,max);
		//run("Enhance Contrast...", "saturated=0.8 normalize");
		//print("mean=" + mean + " max=" + max);
		outputFileName = "tile_x=" + x + "_y=" + y + "_c=" + 1 +".jpg";
		saveAs("Jpeg", output + outputFileName);
		close();

		
		
		//save as .ome.tiff
		//run("Bio-Formats Exporter", "save=" + output + outputFileName + " export compression=Uncompressed");

		// close("?");
		run("Close All");
		//run("Collect Garbage");
	}
}
}



function maxArray(array) {
	
	max=0;
	
	for	(i = 0; i < array.length; i++) {
		if (array[i]>max) {
			max=array[i];
		}
	}
	return max
}

import java.util.Arrays;

import ij.IJ;
import ij.ImagePlus;
import ij.ImageStack;
import ij.Macro;
import ij.WindowManager;
import ij.measure.ResultsTable;
import ij.plugin.PlugIn;
import ij.plugin.filter.Analyzer;
import ij.process.ImageProcessor;

public class vollaths_Focus implements PlugIn {
	
	
	public void run(String arg) {
		
		// Get input options, massive pain...
		String match = "range=";
		String input = Macro.getOptions();
		String subInput = input.substring(input.indexOf(match) + match.length());
		
		// width of selection band
		int range = Integer.parseInt(subInput.substring(0, subInput.indexOf(" ")));
		
		// Load in hyperstack
		ImagePlus hyperStackPlus = WindowManager.getCurrentImage();

		ImageStack hyperStack = hyperStackPlus.getStack();
		// get hyperstack dimensions
		int numChannels = hyperStackPlus.getNChannels();
		int numSlices = hyperStackPlus.getNSlices();
		int numTimePoints = hyperStackPlus.getNFrames();

		
		int sliceIndex;
		ImageProcessor ipSlice;
		
		
		int[][] vollathF4 = new int[numSlices][1];
		int[] vollathF4Mean = new int[numSlices];
		// only use first channel
		
		for (int c = 1; c <= 1; c++) {
			for (int z = 1; z <= numSlices; z++) {
				
				// get the ImageProcessor for a given
				// (channel, slice, frame) triple
				sliceIndex = hyperStackPlus.getStackIndex(c, z, 1);
				ipSlice = hyperStack.getProcessor(sliceIndex);
				
				
				// get pixel values
				
				int w = ipSlice.getWidth(), h = ipSlice.getHeight();
				
				// calulate sums for vollaths measure
				
				float sum1 = 0; 
				for (int j = 0; j < h; j++) {
					for (int i = 0; i < w - 1; i++) {
						sum1 = sum1 + ipSlice.getf(i,j) * ipSlice.getf(i+1,j);
					}
				}
				float sum2 = 0;
				for (int j = 0; j < h; j++) {
					for (int i = 0; i < w - 2; i++) {
						sum2 = sum2 + ipSlice.getf(i,j) * ipSlice.getf(i+2,j);
					}
				}
				
				// normalise and store vollaths F4 measure for each slice
				vollathF4[z-1][c-1] = Math.round((sum1 - sum2) / (h * (w-1)));
			
			}

			
	
		}
		// calculate mean across all channels
		for (int z = 0; z < numSlices; z++) {
			vollathF4Mean[z]=mean(vollathF4[z]);
			IJ.log("z=" + z + " Measure =" + vollathF4Mean[z]);
		}
		
		// find index of first slice in band of width range with maxium total vollath F4 measure
		int[] maxValInd = maxRange(vollathF4Mean, range);
		double maxVal = (double) maxValInd[0];
		double maxIndex = (double) maxValInd[1];
		
		
		// Store in results table
		ResultsTable rt = Analyzer.getResultsTable();
		
		if (rt == null) {
		    rt = new ResultsTable();
		    Analyzer.setResultsTable(rt);
		}
		
		rt.incrementCounter();
		rt.addValue("maxValue", maxVal);
		rt.addValue("maxPosition", maxIndex);
		rt.show("Results table");
		
		System.gc();
	
	}
	
	
	private static int mean(int[] array) {
		
		// find mean value of array
		int sum = 0;
		for (int q = 0; q < array.length; q++) {
			sum += array[q];
		}
		return sum / array.length;
	}
	
	private static int sum(int[] array) {
		
		// find sum of array
		int sum = 0;
		for (int q = 0; q < array.length; q++) {
			sum += array[q];
		}
		return sum;
	}

	
	private static int[] maxRange(int[] array, int range) {
		
		// find position of maximum band for given range
		int[] max = new int [2];
		int rangeSum;
		for (int q = 0; q < array.length-range+1; q++) {
			rangeSum = sum(Arrays.copyOfRange(array, q, q + range));
			IJ.log("q=" + q + " rangesum =" + rangeSum);
			if (rangeSum > max[0]) {
				max[0] = rangeSum;
				max[1] = q;
			}
		}
		return max;
	}

	
	
}
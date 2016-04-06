number_of_slices = 41;
CellName = "072915_DD60_3P6";
Names = newArray("RFP")
SaveFolder = "/Volumes/WAILERS/UCI/MyData/TimePoints/072915/" + CellName + "/"

ntimes = nSlices / (Names.length * number_of_slices);

stack = 0;
for (i = 0; i < ntimes-1; i++) {
	for (channel = 0; channel < Names.length; channel++) {
		run("Make Substack...", "delete slices=1-" + number_of_slices);
		saveAs("Tiff",SaveFolder + Names[channel] + CellName + "-" + IJ.pad(i,3)  + ".tif");
		close();
	}
}
close();



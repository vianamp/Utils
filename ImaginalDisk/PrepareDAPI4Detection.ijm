for (disk = 3; disk <= 11; disk++) {
	setBatchMode(true);
	open("/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/July2015/UCMEXUS/Control/CA1_" + disk + ".lsm");
	run("Split Channels");
	selectWindow("C1-CA1_" + disk + ".lsm");
	close();
	selectWindow("C2-CA1_" + disk + ".lsm");
	close();
	selectWindow("C4-CA1_" + disk + ".lsm");
	close();
	selectWindow("C3-CA1_" + disk + ".lsm");
	run("Reslice [/]...", "output=1 start=Left");
	setSlice(nSlices*0.5);
	resetMinAndMax();
	run("Save", "save=/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/July2015/UCMEXUS/Control/DAPI-CA1_" + disk + ".tif");
	close();
	close();
	setBatchMode(false);
	print("Disk " + disk + " done!");
}
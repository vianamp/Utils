STACK = getImageID;

newImage("CopyIMG", "8-bit black", 100, 100, 55);

STACK8 = getImageID;

for (s=1;s<=nSlices;s++) {

	selectImage(STACK);
	setSlice(s);
	run("Duplicate...", " ");
	
	resetMinAndMax();
	run("8-bit");
	run("Select All");
	run("Copy");
	close();
	
	selectImage(STACK8);
	setSlice(s);
	run("Paste");

}
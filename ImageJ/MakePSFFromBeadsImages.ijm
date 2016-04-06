open("/Users/matheusviana/Desktop/PSF/150x/GFP-150x488laser2gain125exp100mstest2_1.tif");

r = 25;

ho = getHeight();
wo = getWidth();

run("Z Project...", "projection=[Max Intensity]");

run("Find Maxima...", "noise=1000 output=[Point Selection]"); 
getSelectionBounds(x, y, w, h);
close(); 

makeRectangle(x-r, y-r, 2*r+1, 2*r+1);
run("Crop");

vm = 0;
for (s = 1; s <= nSlices; s++) {
	setSlice(s);
	v = getPixel(r+1,r+1);
	if (v > vm) {
		vm = v;
		z = s;
	}
}

print(vm);
print(z);

//roiManager("Add");

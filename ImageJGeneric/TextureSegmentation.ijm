dx = round(getWidth / 10);
dy = round(getHeight / 10);
run("Set Measurements...", "perimeter shape redirect=None decimal=3");

rename("original");

run("Duplicate...", "duplicate");
run("Select All");
run("Clear", "stack");
run("32-bit");
rename("stack");

run("Duplicate...", " ");
run("Select All");
run("Clear", "slice");
run("32-bit");
rename("temp");

run("Duplicate...", " ");
run("Select All");
run("Clear", "stack");
run("32-bit");
rename("sum");

for (s = 1; s <= nSlices; s++) {
	selectWindow("original");
	setSlice(s);
	roiManager("Reset");
	for (x = 1; x < getWidth; x+= dx) {
		for (y = 1; y < getHeight; y+= dy) {
			//selectWindow("original");
			doWand(x, y, 20.0, "Legacy");
			run("Measure"); 
			//if (getResult("Perim.",nResults-1) > 1000) {
			if (getResult("Round",nResults-1) < 0.1) {
				roiManager("Add");
			}
		}
	}
	selectWindow("sum");
	run("Select All");
	run("Clear", "slice");
	for (roi = 0; roi < roiManager("count"); roi++) {	
		selectWindow("temp");
		run("Select All");
		run("Clear", "slice");
		run("Select None");		
		roiManager("Select",roi);
		run("Fill", "slice");
		run("Calculator Plus", "i1=temp i2=sum operation=[Add: i2 = (i1+i2) x k1 + k2] k1=1 k2=0");
	}
	selectWindow("sum");
	run("Copy");
	selectWindow("stack");
	setSlice(s);
	run("Paste");
}		
	
	

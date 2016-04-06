run("Line Width...", "line=5");
run("Colors...", "foreground=white background=black selection=yellow");


newImage("Disk", "16-bit black", getWidth(), getHeight(), nSlices);


for (roi = 0; roi < roiManager("count"); roi++) {
	roiManager("select",roi);
	run("Draw", "slice");
}

run("Gaussian Blur 3D...", "x=5 y=5 z=5");
run("Gaussian Blur...", "sigma=20 stack");

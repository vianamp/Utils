run("Split Channels");
n = nSlices;
s = getHeight();
zfactor = 10.24370456063385
newImage("Disc", "8-bit black", s, s, n);
for (roi = 0; roi < roiManager("count"); roi++) {
	roiManager("Select", roi);
	run("Fill", "slice");
}
run("Select None");
run("Scale...", "x=1.0 y=1.0 z="+zfactor+" width="+s+" height="+s+" depth="+round(zfactor*n)+" interpolation=Bilinear average process create title=Disc-1");
run("Gaussian Blur 3D...", "x=10 y=10 z=12");
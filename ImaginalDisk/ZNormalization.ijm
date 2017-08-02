Original = getImageID;

maxzint = 0;
ZProfile = newArray(nSlices);

//for (s=1;s<=nSlices;s++) {
for (s=3;s<=36;s++) {

	selectImage(Original);
	setSlice(s);
	
	getHistogram(0,Counts,256);
	getHistogram(0,Histog,256);

	nc = 0;
	for (i=0;i<256;i++) {
		nc = nc + Counts[i];
	}
	sump = 0;
	for (i=0;i<256;i++) {
		Counts[i] = Counts[i] / nc;
		sump = sump + Counts[i];
		if (sump<0.99) {
			threshold = i;
		}
	}

	nc = 0;
	avg = 0;
	for (i=threshold;i<256;i++) {
		nc = nc + Histog[i];
	}
	for (i=threshold;i<256;i++) {
		avg = avg + i * Histog[i] / nc;
	}

	print("Threshold[" + s + "] = " + threshold);
	print("Avg Intensity 1% = " + avg);

	ZProfile[s-1] = avg;
	if (avg>maxzint) {
		maxzint = avg;
	}
}

print("Max Intensity = " + maxzint);
Plot.create("Simple plot","X","Y",ZProfile);

for (s=1;s<=nSlices;s++) {
	setSlice(s);
	scale = maxzint / ZProfile[s-1];
	//if (ZProfile[s-1]>100) {
		run("Multiply...", "value=" + scale + " slice");
	//}
}

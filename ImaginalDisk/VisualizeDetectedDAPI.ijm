f = split(File.openAsString(""),"\n");
h = getHeight;
for (i = 0; i < f.length; i++) {
	r = split(f[i],"\t");
	setSlice(r[2]+1);
	makePoint(r[0]+1,h-(r[1]+1));
	roiManager("Add");
}

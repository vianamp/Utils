run("Clear", "stack");
for (roi=0; roi<roiManager("count"); roi++) {
	roiManager("select",roi);
	run("Draw", "slice");
}

//run("Duplicate...", "duplicate channels=3 slices=5");
run("Make Substack...", "  slices=5-12");
run("Z Project...", "projection=[Max Intensity]");
run("Find Maxima...", "noise=100 output=[Segmented Particles] light");
run("Analyze Particles...", "size=1-6 add");
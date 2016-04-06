// Matheus Viana - vianamp@gmail.com - 7.29.2013
// ==========================================================================

// Selecting the folder that contains the TIFF frame files plus the RoiSet.zip and
// MaxProjs.tiff files.

// Defining the size of the singl cell images:
_xy = 200;

//Pixel size and z-spacing
_scale_x = 0.061;
_scale_z = 0.200;
_scale_r = _scale_x / _scale_z;

_RootFolder = getDirectory("Choose a Directory");

//Ellipse fitting
run("Set Measurements...", "  center fit redirect=None decimal=3");

// Creating a directory where the files are saved
File.makeDirectory(_RootFolder + "cells");

setBatchMode(true);
// Prevent generation of 32bit images
run("RandomJ Options", "  adopt progress");

run("ROI Manager...");
roiManager("Reset");
roiManager("Open",_RootFolder + "RoiSet.zip");

n_cells = roiManager("count");

roiManager("Open",_RootFolder + "RoiSet_cellboundary.zip");

open("MaxProjs.tif");
MAXP = getImageID;

Dx = newArray(-1,0,1,0);
Dy = newArray(0,1,0,-1);

// For each ROI (cell)

for (roi = 0; roi < n_cells; roi++) {

	//coordinates of mito ROI on the original frame
	roiManager("Select",roi);
	getSelectionCoordinates(Xo,Yo);
	run("Copy");
	
	//name of corresponding z-stack
	_FileName = getInfo("slice.label");
	_FileName = replace(_FileName,".tif","@");
	_FileName = split(_FileName,"@");
	_FileName = _FileName[0];

	//open corresponding z-stack
	open(_FileName + ".tif");
	ORIGINAL = getImageID;

	//cell boundary ROI on the z-stack
	roiManager("Select",roi+n_cells);

	//coordinates of cell boundary ROI on the z-stack
	getSelectionCoordinates(X,Y);

	//calculate ellipse properties
	run("Clear Results");
	run("Measure");
	xcm = getResult("XM",0);
	ycm = getResult("YM",0);
	r12 = 0.5*_scale_r*getResult("Minor",0);
	rd3 = 0.5*getResult("Major",0);
	selectWindow("Results");
	run("Close"); 

	//Inflexion point according to the cell boundary ROI on the original z-stack
	std_min = 65535;
	run("Enlarge...", "enlarge=5");
	//Z = newArray(nSlices);
	for (s = 8; s <= nSlices-8; s++) {
		setSlice(s);
		getStatistics(area, mean, min, max, std);
		//Z[s-1] = std;
		if (std < std_min) {
			so = s;
			std_min = std;
		}
	}
	//Plot.create("Simple plot","X","Y",Z);
	
	//create a new image
	newImage("CELL","16-bit Black",_xy,_xy,nSlices);
	CELL = getImageID;

	//coordinates of mito ROI on new image
	run("Paste");
	run("Clear", "slice");
	getSelectionCoordinates(Xf,Yf);

	//calculate the displacement vector
	dx = Xf[0] - Xo[0];
	dy = Yf[0] - Yo[0];
	xcm = xcm + dx;
	ycm = ycm + dy;

	setSlice(so);
	_file = File.open(_RootFolder + "cells/" + _FileName + "_" + IJ.pad(roi,3) + "_ellipsoid.txt");
	for (p = 0; p < X.length; p++) {
		setPixel(X[p]+dx,Y[p]+dy,255);
		print(_file,(X[p]+dx) + " " + _xy-(Y[p]+dy) + " " + (so));
	}
	sb = round(so-r12);
	if (sb < 1) {
		sb = 1;
	}
	st = round(so+r12);
	if (st > nSlices) {
		st = nSlices;
	}	
	setSlice(sb);
	setPixel(xcm,ycm,255);
	for (p = 0; p < 4; p++) {
		print(_file, (xcm+Dx[p]) + " " + _xy-(ycm+Dy[p]) + " " + (so-r12));
	}
	setSlice(st);
	setPixel(xcm,ycm,255);
	for (p = 0; p < 4; p++) {
		print(_file, (xcm+Dx[p]) + " " + _xy-(ycm+Dy[p]) + " " + (so+r12));
	}
		
	File.close(_file);

	//print("xcm= "+xcm+",ycm= "+ycm+",zcm= "+so+",r12= "+r12+",rd3= "+rd3);

	save(_RootFolder + "cells/" + _FileName + "_" + IJ.pad(roi,3) + "_ellipsoid.tif");

	selectImage(CELL); close();
	selectImage(ORIGINAL); close();
}

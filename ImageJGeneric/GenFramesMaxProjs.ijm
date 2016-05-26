// Matheus Viana - vianamp@gmail.com - 7.29.2013
// ==========================================================================

// This macro must be used to generate a stack of max projection from a set
// of microscope frames. In general, the max projection stack is then used
// to drawn ROIs around the cells that are going to be further analysed. 

// Selecting the folder that contains the TIFF frame files

_RootFolder = getDirectory("Choose a Directory");

setBatchMode(true);

item = 0;
ntiff = 0;
_List = getFileList(_RootFolder);
while (item < _List.length)  {
	if ( endsWith(_List[item],".tif") ) {
		if (ntiff==0) {
			open(_List[item]);
			w = getWidth();
			h = getHeight();
			close();
		}
		ntiff++;
	}
	item++;
}
if (ntiff== 0) {
	showMessage("No TIFF files were found.");
} else {
	print("Number of TIFF files: " + ntiff);
}

// Generating the max projection stack
std = 0;
norm_to_8 = 0;
orthogonal = 1;

if (norm_to_8) {
	newImage("MaxProjs", "8-bit black", w, h, ntiff);
} else {
	if (orthogonal) {
		newImage("MaxProjs", "16-bit black", w, h+100, ntiff);
	} else {
		newImage("MaxProjs", "16-bit black", w, h, ntiff);
	}
}
MAXP = getImageID;

item = 0; im = 0;
while (item < _List.length)  {
	showProgress(item/(_List.length-1));
	if ( endsWith(_List[item],".tif") ) {
		im++;
		open(_List[item]);	
		ORIGINAL = getImageID;
		
		_FileName = split(_List[item],"."); 
		_FileName = _FileName[0];
		print(_FileName);
		if (std) {
			run("Z Project...", "start=1 stop=" + nSlices + " projection=[Standard Deviation]");
			//run("Invert");
		} else {
			run("Z Project...", "start=1 stop=" + nSlices + " projection=[Max Intensity]");
		}
		if (norm_to_8) {
			resetMinAndMax();
			run("8-bit");
		}
		run("Copy");
		close();

		selectImage(MAXP);
		setSlice(im);
		makeRectangle(0,0,w,h);
		run("Paste");
		setMetadata("Label",_FileName);

		if (orthogonal) {
			selectImage(ORIGINAL);
			nz = nSlices;
			run("Reslice [/]...", "output=1.000 start=Top avoid");
			run("Z Project...", "start=1 stop=" + nSlices + " projection=[Max Intensity]");
			run("Copy");
			close();
			close();
			selectImage(MAXP);
			makeRectangle(0,h+100-nz,w,nz);
			run("Paste");
		}
		
		selectImage(ORIGINAL);
		close();
	}
	item++;
}

run("Select None");
resetMinAndMax();

// Saving max projection stack
run("Save", "save=" + _RootFolder + "MaxProjs.tif");

setBatchMode(false);
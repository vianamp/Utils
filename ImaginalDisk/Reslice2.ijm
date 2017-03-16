_RootFolder = getDirectory("Choose a Directory");

setBatchMode(true);

_ectopic_fold = true;

_reverse_z = false;
_flip_x = false;

_FileList = getFileList(_RootFolder);

i = 0;
while (i < _FileList.length)  {

	if ( endsWith(_FileList[i],".lsm") ) {

		_Prefix = split(_FileList[i],"."); 
		_Prefix = _Prefix[0];

		open(_FileList[i]);
		ORIGINAL = getImageID;
		
		// Reslicing both channels
		// ------------------------------------------------
	
		run("Duplicate...", "title=ToProcess duplicate channels=1");
		DUPC1 = getImageID;
		if (_reverse_z) {
			run("Reverse");
		}
		if(_flip_x) {
			run("Flip Horizontally", "stack");
		}
		run("Reslice [/]...", "output=1.0 start=Left");
		w = getWidth;
		h = getHeight;
		n = nSlices;
		RESC1 = getImageID;
		setSlice(nSlices*0.5);
		resetMinAndMax();
		run("Save", "save=" + _RootFolder + "/" + _Prefix + "-EDU.tif");
		selectImage(DUPC1);		
		close();

		selectImage(ORIGINAL);
		run("Duplicate...", "title=ToProcess duplicate channels=2");
		DUPC2 = getImageID;
		if (_reverse_z) {
			run("Reverse");
		}
		if(_flip_x) {
			run("Flip Horizontally", "stack");
		}
		run("Reslice [/]...", "output=1.0 start=Left");
		RESC2 = getImageID;
		setSlice(nSlices*0.5);
		resetMinAndMax();
		run("Save", "save=" + _RootFolder + "/" + _Prefix + "-DAPI.tif");
		selectImage(DUPC2);
		close();

		if (_ectopic_fold) {

			selectImage(ORIGINAL);
			run("Duplicate...", "title=ToProcess duplicate channels=1");
			DUPC3 = getImageID;
			if (_reverse_z) {
				run("Reverse");
			}
			if(_flip_x) {
				run("Flip Horizontally", "stack");
			}
			run("Reslice [/]...", "output=1.0 start=Left");
			RESC3 = getImageID;
			setSlice(nSlices*0.5);
			resetMinAndMax();
			run("Save", "save=" + _RootFolder + "/" + _Prefix + "-GFP.tif");
			selectImage(DUPC3);
			close();

		}

		selectImage(ORIGINAL);
		close();

		// Combining channels and ROI for validation image
		// ------------------------------------------------

		selectImage(RESC1);
		roiManager("Reset");
		roiManager("Open", _RootFolder + "/" + _Prefix + ".zip");
		roiManager("select",0.5*roiManager("count"));
		resetMinAndMax();
		run("Draw", "slice");
		selectImage(RESC2);
		roiManager("select",0.5*roiManager("count"));
		resetMinAndMax();
		run("Draw", "slice");
		if (_ectopic_fold) {
			run("Merge Channels...", "c1="+_Prefix + "-GFP.tif c2="+_Prefix + "-DAPI.tif");
		} else {
			run("Merge Channels...", "c1="+_Prefix + "-EDU.tif c2="+_Prefix + "-DAPI.tif");
		}
		selectWindow("RGB");
		roiManager("select",0.5*roiManager("count"));
		saveAs("PNG", _RootFolder + "/Preview-" + _Prefix + ".png");
		close();
		
		// Creating smooth disk based on hand-trace contour
		// ------------------------------------------------

		newImage("Smooth", "16-bit black", w, h, n);

		//run("Select All");
		//run("Clear","stack");
		//run("8-bit");
		//run("16-bit");
		
		for (roi = 0; roi < roiManager("count"); roi++) {
			roiManager("select",roi);
			run("Draw", "slice");
		}

		run("Multiply...", "value=255 stack");
		run("Gaussian Blur 3D...", "x=5 y=5 z=5");
		run("Gaussian Blur...", "sigma=20 stack");

		saveAs("Tiff", _RootFolder + "/" + _Prefix + ".tif");
		
		close();
	}
	
	i++;
}

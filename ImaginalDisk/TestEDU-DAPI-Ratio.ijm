_RootFolder = getDirectory("Choose a Directory");

//setBatchMode(true);

_FileList = getFileList(_RootFolder);

run("Set Measurements...", "mean redirect=None decimal=3");

i = 0;
while (i < _FileList.length)  {

	if ( endsWith(_FileList[i],".lsm") ) {

		_Prefix = split(_FileList[i],"."); 
		_Prefix = _Prefix[0];

		open(_FileList[i]);
		ORIGINAL = getImageID;
			
		run("Duplicate...", "title=ToProcess duplicate channels=1");
		DUPC1 = getImageID;

		r=5;
		roiManager("Reset");
		for (n = 1; n <= nSlices; n++) {
			if (random() > 0.5) {
				setSlice(n);
				run("Select None");
				run("Find Maxima...", "noise=500 output=[Point Selection]");
				getSelectionCoordinates(X,Y);
				for (j = 0; j < X.length; j++) {
					if (random() > 0.9) {
						makeOval(X[j]-r,Y[j]-r,2*r,2*r);
						roiManager("Add");
					}
				}
			}
		}
		roiManager("Measure");

		selectImage(DUPC1);
		close();

		selectImage(ORIGINAL);
		run("Duplicate...", "title=ToProcess duplicate channels=2");
		DUPC2 = getImageID;
		roiManager("Measure");
		close();
		
		selectImage(ORIGINAL);
		close();

		saveAs("Results", _RootFolder + "/" + _Prefix + "-Ratio.txt");
		selectWindow("Results"); 
		run("Close"); 

		print(_Prefix);
	}
	
	i++;
}
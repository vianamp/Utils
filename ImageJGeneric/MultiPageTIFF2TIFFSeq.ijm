// Matheus Viana, 11.20.2013
// --------------------------------------

//setBatchMode(true);
_RootFolder = getDirectory("Choose a Directory");

i = 0;
_ItemsList = getFileList(_RootFolder);

while (i < _ItemsList.length)  {
	
	if ( endsWith(_ItemsList[i],"/") ) {

		_FolderName = split(_ItemsList[i],"/"); 

		print(_FolderName[0]);

		_ItemsList2 = getFileList(_RootFolder+_FolderName[0]);
	
		_StackFullPath = _RootFolder + _ItemsList[i] + "*.tif";

		print(_StackFullPath);

		run("Image Sequence...", "open=" + _StackFullPath + " number=200 starting=1 increment=1 scale=100 file=im sort");

		run("16-bit");
		setSlice(0.5*nSlices);
		resetMinAndMax();
	
		_SaveFullPath = _RootFolder + _FolderName[0] + ".tif";
	
		run("Save", "save=" + _SaveFullPath);
	
		close();

	}

	i = i + 1;

}
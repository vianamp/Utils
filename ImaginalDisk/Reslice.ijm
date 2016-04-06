_RootFolder = getDirectory("Choose a Directory");

_FileList = getFileList(_RootFolder);

i = 0;
while (i < _FileList.length)  {

	if ( endsWith(_FileList[i],".lsm") ) {

		_Prefix = split(_FileList[i],"."); 
		_Prefix = _Prefix[0];

		open(_FileList[i]);
	
		run("Duplicate...", "title=ToProcess duplicate channels=1");
		run("Reslice [/]...", "output=1.0 start=Left");
		setSlice(nSlices*0.5);
		resetMinAndMax();
		run("Save", "save=" + _RootFolder + "/" + _Prefix + "-EDU.tif");
		close();
		close();
		
		run("Duplicate...", "title=ToProcess duplicate channels=2");
		run("Reslice [/]...", "output=1.0 start=Left");
		setSlice(nSlices*0.5);
		resetMinAndMax();
		run("Save", "save=" + _RootFolder + "/" + _Prefix + "-DAPI.tif");
		close();
		close();

		close();
	}
	
	i++;
}
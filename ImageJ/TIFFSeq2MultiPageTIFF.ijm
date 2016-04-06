// Matheus Viana - vianamp@gmail.com - 2.3.2014
// ==========================================================================

_GFPc = false;
_RFPc = true;
_BF_c = true;
_DAPI_c = false;
_Cy5c = false;
_mCherry = false

_RootFolder = getDirectory("Choose a Directory");

setBatchMode(true);

i = 0;
_ItemsList = getFileList(_RootFolder);

while (i < _ItemsList.length)  {
	
	if ( endsWith(_ItemsList[i],"/") ) {

		_FolderName = split(_ItemsList[i],"/"); 

		print(_FolderName[0]);

		_ItemsList2 = getFileList(_RootFolder+_FolderName[0]);

		_continue = false;
		for (j = 0; j < _ItemsList2.length; j++) {
			if (indexOf(_ItemsList2[j],"BF") > 0) {
				_continue = true;
			}
		}

		if ( _continue ) {
	
			_StackFullPath = _RootFolder + _ItemsList[i] + "*.tif";

			print(_StackFullPath);

			if (_RFPc) {

				run("Image Sequence...", "open=" + _StackFullPath + " number=200 starting=1 increment=1 scale=100 file=RFP sort");
	
				_SaveFullPath = _RootFolder + "RFP-" + _FolderName[0] + ".tif";
	
				run("Save", "save=" + _SaveFullPath);
	
				close();

			}

			if (_GFPc) {

				run("Image Sequence...", "open=" + _StackFullPath + " number=200 starting=1 increment=1 scale=100 file=GFP sort");
	
				//_SaveFullPath = _RootFolder + "GFP-" + _FolderName[0] + ".tif";
				_SaveFullPath = _RootFolder + "Bead-" + i + ".tif";
	
				run("Save", "save=" + _SaveFullPath);

	
				close();

			}
			
			if (_BF_c) {

				run("Image Sequence...", "open=" + _StackFullPath + " number=200 starting=1 increment=1 scale=100 file=BF sort");
	
				_SaveFullPath = _RootFolder + "BF-" + _FolderName[0] + ".tif";
	
				run("Save", "save=" + _SaveFullPath);
	
				close();

			}

			if (_DAPI_c) {

				run("Image Sequence...", "open=" + _StackFullPath + " number=200 starting=1 increment=1 scale=100 file=DAPI sort");
	
				_SaveFullPath = _RootFolder + "DAPI-" + _FolderName[0] + ".tif";
	
				run("Save", "save=" + _SaveFullPath);
	
				close();

			}

			if (_Cy5c) {

				run("Image Sequence...", "open=" + _StackFullPath + " number=200 starting=1 increment=1 scale=100 file=Cy5 sort");
	
				_SaveFullPath = _RootFolder + "Cy5-" + _FolderName[0] + ".tif";
	
				run("Save", "save=" + _SaveFullPath);
	
				close();

			}			

			if (_mCherry) {

				run("Image Sequence...", "open=" + _StackFullPath + " number=200 starting=1 increment=1 scale=100 file=mCherry sort");
	
				_SaveFullPath = _RootFolder + "mCherry-" + _FolderName[0] + ".tif";
	
				run("Save", "save=" + _SaveFullPath);
	
				close();

			}
			
		}

	}
	i++;
}

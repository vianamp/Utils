// Matheus Viana - vianamp@gmail.com - 2.3.2014
// ==========================================================================

_RootFolder = getDirectory("Choose a Directory");

lx = 28;

run("Set Measurements...", "mean standard modal skewness kurtosis redirect=None decimal=3");

File.makeDirectory(_RootFolder + "crops");

setBatchMode(true);

i = 0;
_FileList = getFileList(_RootFolder);
while (i < _FileList.length)  {

	if ( endsWith(_FileList[i],".jpg") ) {

		print(_FileList[i]);

		roiManager("Reset");

		open(_FileList[i]);

		Lx = getWidth() / 10;

		_FileName = replace(_FileList[i],".jpg","@");
		_FileName = split(_FileName,"@");
		_FileName = _FileName[0];

		run("8-bit");
		run("Duplicate..."," ");
		run("Find Edges");

		valid = 0;
		tries = 0;
		while (valid < 50 && tries < 1000) {

			xo = random()*(getWidth()-Lx);
			yo = random()*(getHeight()-Lx);
			makeRectangle(xo,yo,Lx,Lx);

			getStatistics(area, mean, min, max, std);
		
			if (std>50) {
				roiManager("Add");
				valid++;
			}
			tries++;
		}		
		close();

		if (tries < 1000) {

			for (roi = 0; roi < roiManager("count"); roi++) {
				roiManager("Select",roi);
				run("Scale...", "x=- y=- width="+lx+" height="+lx+" interpolation=Bilinear average create");
				run("Save", "save=" + _RootFolder + "/crops/" + _FileName + "-"+roi+".png");
				close();
			}
			
		}	
			
		close();

		print(tries);

	}
	i++;
}

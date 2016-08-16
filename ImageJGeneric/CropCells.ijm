function shuffle(array) { 
  n = array.length;
  while (n > 1) { 
    k = randomInt(n);
    n--;
    temp = array[n];
    array[n] = array[k]; 
    array[k] = temp; 
  } 
} 

function randomInt(n) { 
  return n * random(); 
} 

_RootFolder = getDirectory("Choose a Directory");

ext = "tif";
Lx = 100;

setBatchMode(true);

_List = getFileList(_RootFolder);

valid = 0;
for (item = 0; item < _List.length; item++) {
	if ( endsWith(_List[item],ext) ) {
		open(_List[item]);
		if (getWidth()>Lx && getHeight()>Lx) {
			valid++;			
		}
		close();
	}
}

nrep = 2;
newImage("Stack", "RGB black", Lx, Lx, nrep*valid);
STACK = getImageID;

S = newArray(nrep*valid);
for (i = 0; i < nrep*valid; i++) {
	S[i] = i + 1;
}
shuffle(S);

valid = 0;
for (item = 0; item < _List.length; item++) {
	if ( endsWith(_List[item],ext) ) {
		for (w = 0; w < nrep; w++) {
			open(_List[item]);
			if (getWidth()>Lx && getHeight()>Lx) {
				avg_pix = 1E5;
				for (r = 0; r < 5; r++) {
					xo = random()*(getWidth()-Lx);
					yo = random()*(getHeight()-Lx);
					makeRectangle(xo,yo,Lx,Lx);
					getStatistics(area, mean, min, max, std);
					if (mean < avg_pix) {
						avg_pix = mean;
						_x = xo;
						_y = yo;
					}
				}
				makeRectangle(_x,_y,Lx,Lx);
				run("Copy");
				close();
				selectImage(STACK);
				print(S[valid]);
				setSlice(S[valid]);
				run("Paste");
				valid++;
			} else {
				close();
			}
		}
	}
}

save(_RootFolder + "/../" + "Montage.tif");

setBatchMode(false);

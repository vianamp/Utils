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

setBatchMode(true);

_List = getFileList(_RootFolder);

valid = 0;
for (item = 0; item < _List.length; item++) {
	if ( endsWith(_List[item],".jpg") ) {
		open(_List[item]);
		if (getWidth()>100 && getHeight()>100) {
			valid++;			
		}
		close();
	}
}

newImage("Stack", "RGB black", 100, 100, valid);
STACK = getImageID;

S = newArray(valid);
for (i = 0; i < valid; i++) {
	S[i] = i + 1;
}
shuffle(S);

valid = 0;
for (item = 0; item < _List.length; item++) {
	if ( endsWith(_List[item],".jpg") ) {
		open(_List[item]);
		if (getWidth()>100 && getHeight()>100) {
			xo = random()*(getWidth()-100);
			yo = random()*(getHeight()-100);
			makeRectangle(xo,yo,100,100);
			run("Copy");
			close();
			selectImage(STACK);
			setSlice(S[valid]);
			run("Paste");
			valid++;
		} else {
			close();
		}
	}
}

save(_RootFolder + "/../" + "Montage.tif");

setBatchMode(false);


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

ext = "jpg";
Lx = 200;

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

newImage("Stack", "RGB black", Lx, Lx, valid);
STACK = getImageID;

S = newArray(valid);
for (i = 0; i < valid; i++) {
	S[i] = i + 1;
}
shuffle(S);

valid = 0;
for (item = 0; item < _List.length; item++) {
	if ( endsWith(_List[item],ext) ) {
		open(_List[item]);
		if (getWidth()>Lx && getHeight()>Lx) {
			xo = random()*(getWidth()-Lx);
			yo = random()*(getHeight()-Lx);
			makeRectangle(xo,yo,Lx,Lx);
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


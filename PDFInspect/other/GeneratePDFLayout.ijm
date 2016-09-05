function GetNewLayout(W,H,offset,div) {

	fig = 0;
	roiManager("Reset");
	
	for (i = 0; i < 2; i++) {
		ndiv = div[0] + round((div[1]-div[0])*random());
		d = H / ndiv;
		for (j = 0; j < ndiv; j++) {
			x = 0.5*W*i;
			y = j*d;
			w = 0.5*W;
			h = d;
			if (random() < 0.25) {
				fig = fig + 1;
				makeRectangle(x,y,w,h);
				x = x + offset;
				y = y + offset;
				w = w - 2*offset;
				h = h - 2*offset;
				q = 1 + round(1*random());
				p = 1 + round(2*random());
				for (jj = 0; jj < q; jj++) {
					for (ii = 0; ii < p; ii++) {
						xx = x + ii * w / p;
						yy = y + jj * h / q;
						ww = w / p;
						hh = h / q;
						makeRectangle(xx,yy,ww,hh);
						run("Enlarge...", "enlarge=-5");
						roiManager("Add");
						roiManager("Select",roiManager("count")-1);
						roiManager("Rename", fig);
					}
				}			
			}
		}
	}
	
	return fig;
}

W = 600;
H = 800;

offset = 10;

div = newArray(2,5);

for (page = 0; page < 100; page++) {

	do {
		
		nfigs = GetNewLayout(W,H,offset,div);
		
	} while(nfigs < 2);
	
	for (roi = 0; roi < roiManager("count"); roi++) {
		
		roiManager("Select",roi);
	
		Roi.getBounds(x,y,w,h);
		print(page,Roi.getName(),x,y,w,h);
		
	}

}

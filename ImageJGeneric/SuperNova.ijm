rmax = 65
rmin = 10
_xy = 0.056;
_dz = 0.200;
nsigmas = 100;
cell_wall_rad = 5;
number_of_points = 50;
drmax = nsigmas*cell_wall_rad*cell_wall_rad/number_of_points;
run("Line Width...", "line=3");
ZIndex = newArray(0,-2,-1,1,2);
R = newArray(ZIndex.length*number_of_points);
T = newArray(ZIndex.length*number_of_points);
Z = newArray(ZIndex.length*number_of_points);
for (roi = 0; roi < roiManager("count"); roi++) {
	b = 0;
	roiManager("Select", roi);
	getSelectionCoordinates(x,y);
	x = x[0];
	y = y[0];
	tot_so = 0;
	npt_so = 1;
	zo = getSliceNumber();
	for (dz = 0; dz < ZIndex.length; dz++) {

		zfac = round(0.5*(tot_so/npt_so)*(_xy/_dz));
		z = zo + ZIndex[dz] * zfac;
		setSlice(z);

		run("Duplicate...", "title=Temp4Frangi.tif");
		run("Frangi Vesselness (imglib, experimental)", "number=6 minimum=2 maximum=4");
		
		t = 0;
		sprev = 0;
		while (t <= 2*3.1415) {
			p = x + rmax*cos(t);
			q = y + rmax*sin(t);
			makeLine(x,y,p,q);
			F = getProfile();
			
			avgI_bkgrd = 0;
			stdI_bkgrd = 0;
			for (s=0;s<rmin;s++) {
				avgI_bkgrd = avgI_bkgrd + F[s];
				stdI_bkgrd = stdI_bkgrd + F[s]*F[s];
			}
			
			avgI_bkgrd = avgI_bkgrd / rmin;
			stdI_bkgrd = sqrt(stdI_bkgrd/rmin - avgI_bkgrd*avgI_bkgrd);
			
			print("bkgrd="+avgI_bkgrd+"+/-"+stdI_bkgrd);
			
			s=0;
			while ((F[s]<avgI_bkgrd+nsigmas*stdI_bkgrd)&&(s<F.length-1)) {s++;}
			if (s<F.length) {
				S = newArray(2*cell_wall_rad+1);
				Y = newArray(2*cell_wall_rad+1);
				for (i = 0; i < 2*cell_wall_rad+1; i++) {
					S[i] = i - cell_wall_rad;
					if (s < F.length-i) {
						Y[i] = F[s+i];
					} else {
						Y[i] = avgI_bkgrd;
					}
					print(S[i]+" "+Y[i]);
				}
				
				valid = 1;
				Fit.doFit("Gaussian",S,Y);
				//Fit.plot();
				
				print("<s>="+d2s(Fit.p(2),6));
				
				s = s + cell_wall_rad + d2s(Fit.p(2),6);
				
				p = x + s*cos(t);
				q = y + s*sin(t);
				if (sprev > 0) {
					if ( abs(sprev-s) > drmax ) {
						valid = 0;
					}
				}
				if (valid) {
					R[b] = s;
					T[b] = t;
					setPixel(x+s*cos(t),y+s*sin(t),65535);
					Z[b] = z;
					b = b + 1;
					if (dz==0) {
						tot_so = tot_so + s;
						npt_so = npt_so + 1;
					}
					sprev = s;
				}
			}
			t = t + 2*3.1415/(number_of_points-1);
		}

		close();
		close();
		
	}
	newImage("Ell", "8-bit black", 512, 512, 53);
	for (p = 0; p < b-1; p++) {
		setSlice(Z[p]);
		setPixel(x+R[p]*cos(T[p]),y+R[p]*sin(T[p]),255);
	}
	save("/Users/viana/Dropbox/RafelskiLab/Data4Maja/101715/ComparativeAnalysis/results/Cell_" + IJ.pad(roi,3) + "_ellipsoid.tif");	
	close();
}



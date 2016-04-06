_free_shape = true;

_debug = false;

_RootFolder = getDirectory("Choose a Directory");

File.makeDirectory(_RootFolder + "SegmentedVacuoles");

if (!_debug) {
	setBatchMode(true);
}

open("Cells.tif");
roiManager("Reset");
roiManager("Open",_RootFolder + "Contours.zip");

//AUXILIAR VECTORS
DX = newArray(0,1,0,-1);
DY = newArray(-1,0,1,0);

for (roi = 0; roi < roiManager("count"); roi++) {

	roiManager("Select",roi);

	run("Duplicate...", " ");

	if (_debug) {	
		print("Cleaning outside...");
	}

	run("Clear Outside");
	
	//IMAGE PARAMETERS
	ImageW = getWidth();
	ImageH = getHeight();

	if (_debug) {	
		print("Expanding canvas...");
	}
	
	run("Canvas Size...", "width=" + ImageW+50 + " height=" + ImageH+50 + " position=Center zero");
	run("Select None");
	//run("Invert");
	run("Median...", "radius=1");

	//PROPERTIES OF THE CELL
	getStatistics(area, vmean_cell, vmin, vmax, vstd);

	// DETECTING PEAKS OF INTENSITY. IT DEPENDS ON THE PARAMETER "NOISE".
	// THE VALUE BELLOW MIGHT NOT WORK FOR ALL THE IMAGES. HAVE TO TEST.
	run("Find Maxima...", "noise=400 output=[Point Selection] exclude");
	
	//COORDINATES OF DETECTED PEAKS
	getSelectionCoordinates(X, Y);
	
	//EUCLIDEAN DISTANCE BETWEEN PEAKS
	Npoints = X.length;
	DistanceMatrix = newArray(Npoints*Npoints);

	if (_debug) {	
		print("#Peaks = "+Npoints);
	}
	
	for (i = 0; i < Npoints; i++) {
		xi = X[i];
		yi = Y[i];
		for (j = i + 1; j < Npoints; j++) {
			xj = X[j];
			yj = Y[j];
			DistanceMatrix[i+j*Npoints] = sqrt(pow(xi-xj,2)+pow(yi-yj,2));
			DistanceMatrix[j+i*Npoints] = sqrt(pow(xi-xj,2)+pow(yi-yj,2));
		}
	}
	
	//DISTANCE BETWEEN EACH PEAK AND ITS 1ST NEIGHBOUR
	InfluenceRadius = newArray(Npoints);
	
	for (i = 0; i < Npoints; i++) {
		dmin = ImageH;
		for (j = 0; j < Npoints; j++) {
			if (i != j) {
				d = DistanceMatrix[i+j*Npoints];
				if (d < dmin) {
					dmin = d;
				}
			}
		}
		InfluenceRadius[i] = dmin;
	}
	vac = 0;
	if (_debug) {
		roi = roiManager("count") + 1;
		vac = round(random()*(Npoints-1));
		Npoints = vac + 1;
	}
	for (i = vac; i < Npoints; i++) {
		ri = InfluenceRadius[i];
		
		if (ri > 3.0) {
			Pmin = newArray(4);
			Vmin = newArray(4);
			makeOval(X[i]-ri,Y[i]-ri,2*ri,2*ri);
			run("Duplicate...", " ");
			getStatistics(area, vmean_vac, vmin, vmax, vstd);
			for (j = 0; j < 4; j++) {
				Vmin[j] = vmean_vac;
			}
			for (j = 0; j < ri; j++) {
				for (k = 0; k < 4; k++) {
					x = ri+j*DX[k];
					y = ri+j*DY[k];
					if ((x>=0) && (y>=0) && (x<ImageW) && (y<ImageH)) {
						if ( getPixel(x,y) < Vmin[k] ) {
							Pmin[k] = j;
							Vmin[k] = getPixel(x,y);
							//setPixel(x,y,65535);
						}
					}
				}
			}

			//FINDING THE PIXEL WITH LOWEST INTENSITY AROUND THE INTENSITY PEAK
			rmin = ri;
			for (j = 0; j < 4; j++) {
				if ( (Pmin[j] > 0) && (Pmin[j] < rmin) ) {
					rmin = Pmin[j];
				}
			}

			if (_debug) {
				print("1");	
				print("i = "+i+" I[i] = "+getPixel(ri,ri)+" rmin = "+rmin);
			}
			
			if (rmin > 0) {
			
				makeOval(ri-rmin,ri-rmin,2*rmin,2*rmin);

				if (_debug) {
					print("2");
					print(ri+" "+rmin+" ");
				}
						
				if (rmin >=6) {

					run("Make Band...", "band=1");

					if (_debug) {
						print("3");
					}			
					
					getStatistics(area, vmean, vmin, vmax, vstd);

					if (_debug) {
						print(vmean);
					}

					run("Select None");

					if (getPixel(round(ri),round(ri))/vmin > 3.8) {
						rmin = rmin - 1;
					}

				}

				if (_debug) {
					print("5");
				}

				if (_free_shape==true) {
					
					makeOval(ri-rmin,ri-rmin,2*rmin,2*rmin);

					if (_debug) {
						print("6");
					}

					run("Clear Outside");
					if (rmin <= 2) {
						run("Median...", "radius=1");
					}

					getStatistics(area, vmean, vmin, vmax, vstd);

					if (_debug) {
						print("vmean = "+vmean);
					}

					setAutoThreshold("IsoData dark");
					run("Convert to Mask");

					if (_debug) {
						print("(ri,ri) = "+getPixel(round(ri),round(ri)));
					}

					if ( (vmean > 0) && (getPixel(round(ri),round(ri)) > 0) ) {
					
						run("Select None");
						doWand(round(ri),round(ri));
				
						if (_debug) {
							print("7");
						}

						getSelectionCoordinates(x_,y_);
		
						if (_debug) {
							print("8");
						} else {
							close();
						
							for (j = 0; j < x_.length; j++) {
								x_[j] = x_[j] - InfluenceRadius[i] + X[i];
								y_[j] = y_[j] - InfluenceRadius[i] + Y[i];
							}	
							makeSelection("polygon",x_,y_);
							run("Fit Ellipse");
							run("Add Selection...");
						
						}
						
					} else {

						close();
						
					}

				} else {

					if (!_debug) {
						close();
					}
					makeOval(ri-rmin-InfluenceRadius[i]+X[i],ri-rmin-InfluenceRadius[i]+Y[i],2*rmin,2*rmin);
					run("Add Selection...");

				}

			} else {
				close();

			}

		}
	}

	run("Save", "save=" + _RootFolder + "SegmentedVacuoles/Cell" + IJ.pad(roi,3) + ".tif");

	if (!_debug) {
		close();
	}

}

setBatchMode(false);
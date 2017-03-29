#!/usr/bin/env python
import os
import vtk
import math
import numpy
from paraview.simple import *
import paraview.servermanager

paraview.simple._DisableFirstRenderCameraReset()

#
# Load data
#

RootFolder = '/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/EctopicExperiment_new/Temp/29C39H/Experimental'

File = 'CA_8_39h29C_Exp_B8'

Vol = TIFFSeriesReader(FileNames=[os.path.join(RootFolder,File+'-GFP.tif')])
Dsk = LegacyVTKReader(FileNames=[os.path.join(RootFolder,File+'-Disk.vtk')])

renderView1 = GetActiveViewOrCreate('RenderView')

#
# 3D View Volume
#

Vol.UseCustomDataSpacing = 1
Vol.CustomDataSpacing = [1.0, 1.0, 7.58]
VolDisplay = Show(Vol, renderView1)
VolDisplay.SetRepresentationType('Volume')

#
# 3D View Disk
#

DskDisplay = Show(Dsk, renderView1)
DskDisplay.Opacity = 0.90

renderView1.ResetCamera()

#
# Clip
#

L = Dsk.GetDataInformation().GetBounds()

Rx = 0.5*(L[1]-L[0])
Ry = 0.5*(L[3]-L[2])
Rz = 0.5*(L[5]-L[4])

Xo = L[0]
Yo = L[2]
Zo = L[4]

Xm = Xo + Rx
Ym = Yo + Ry
Zm = Zo + Rz

Clip = Clip(Input=Dsk)
Clip.ClipType = 'Box'
Clip.Scalars = [None, '']
Clip.InsideOut = 1

Clip.ClipType.Bounds = [Xm-0.5*Rx,Xm+0.5*Rx,Ym-Ry,Ym+Ry,Zm-0.25*Rz,Zm+0.25*Rz]

Show3DWidgets(proxy=Clip)

renderView1.ResetCamera()

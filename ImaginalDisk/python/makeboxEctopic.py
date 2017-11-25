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

#RootFolder = '/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/NoFoldExperiment-TimeVaryingData/18C/Control'

#File = 'CA_9_18C_Ctrl_A1'

FilePath = raw_input("prompt")

show_vol = True
try:
    Vol = TIFFSeriesReader(FileNames=[FilePath+'-GFP.tif'])
except:
    show_vol = False
    pass

Dsk = LegacyVTKReader(FileNames=[FilePath+'-Disk.vtk'])

renderView1 = GetActiveViewOrCreate('RenderView')

#
# 3D View Volume
#

if show_vol:
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
Clip.Scalars = ['POINTS', '']
Clip.InsideOut = 1

Show3DWidgets(proxy=Clip.ClipType)

Clip.ClipType.Bounds = [Xm-0.33*Rx,Xm+0.33*Rx,Ym-Ry,Ym+Ry,Zm,Zm+0.5*Rz]

clip1Display = Show(Clip, renderView1)

renderView1.Update()

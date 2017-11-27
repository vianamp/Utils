#!/usr/bin/env python
import os
import vtk
import glob
import math
import numpy
from paraview.simple import *
import paraview.servermanager

paraview.simple._DisableFirstRenderCameraReset()

renderView1 = GetActiveViewOrCreate('RenderView')

FilePath = raw_input("prompt")

#
# Get list of files
#

Files = glob.glob(FilePath+'/*-DiskDec.vtk')

print 'Number of files: ' + str(len(Files))

#
# Convert each file found
#

for fname in Files:

    DskDec = LegacyVTKReader(FileNames=[fname])

    DskDisplay = Show(DskDec, renderView1)
    DskDisplay.Opacity = 0.90

    SaveData(fname, proxy=DskDec)

    print fname

renderView1.ResetCamera()

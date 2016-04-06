#!/usr/bin/env python
import os
import vtk
import math
import numpy
import paraview.servermanager

#Active Render
renderView1 = GetActiveViewOrCreate('RenderView')

#Active source
S = GetActiveSource()
Path = os.path.dirname(GetActiveSource().FileNames[0])
File = os.path.splitext(os.path.basename(GetActiveSource().FileNames[0]))[0]

#Transform
T1 = Transform(Input=S)
T1.Transform.Scale = [1.0, 1.0, 10.0]
Hide3DWidgets(proxy=T1)

#Contour
C1 = Contour(Input=T1)
C1.ContourBy = ['POINTS', 'Tiff Scalars']
C1.Isosurfaces = [1200.0]

#Display
Show(C1, renderView1)
renderView1.ResetCamera()

#Save
TempPath = Path + '/' + File + '-Disk.vtk'
SaveData(TempPath, proxy=C1)

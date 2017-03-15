#!/usr/bin/env python
import os
import vtk
import math
import numpy
import paraview.servermanager

fold_on_right_side = 0

#Active Render
renderView1 = GetActiveViewOrCreate('RenderView')

#Active source
S = GetActiveSource()

#Source file name
FileName = os.path.basename(GetActiveSource().FileNames[0])
FileName = os.path.splitext(FileName)[0]

#Source Path
Path = os.path.dirname(GetActiveSource().FileNames[0])

#Creating clipping boundaries
L = S.GetDataInformation().GetBounds()
Lx = L[1]-L[0]
Ly = L[3]-L[2]
Lz = L[5]-L[4]

#Creating clipping box
clip1 = Clip(Input=S)
clip1.ClipType = 'Box'
clip1.Scalars = ['POINTS', '']
clip1.ClipType.Bounds = [L[0]+0.25*Lx,L[0]+0.75*Lx,L[2],L[3],L[4]+0.3*Lz,L[4]+0.6*Lz]
clip1.InsideOut = 1
clip1Display = Show(clip1, renderView1)

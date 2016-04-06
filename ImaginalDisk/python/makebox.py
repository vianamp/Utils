#!/usr/bin/env python
import os
import vtk
import math
import numpy
import paraview.servermanager

fold_on_right_side = 1

#Active Render
renderView1 = GetActiveViewOrCreate('RenderView')

#Active source
S = GetActiveSource()

#Source file name
FileName = os.path.basename(GetActiveSource().FileNames[0])
FileName = os.path.splitext(FileName)[0]

#Source Path
Path = os.path.dirname(GetActiveSource().FileNames[0])

#Scaling up the z-component
#T = Transform(Input=S)
#T.Transform = 'Transform'
#T.Transform.Scale = [1.0, 1.0, 10.0]

#Showing T on screen
#TDisplay = Show(T, renderView1)
#TDisplay.ColorArrayName = [None, '']
#Hide(S, renderView1)

#changing source here
#SetActiveSource(T)
#S = GetActiveSource()

#Creating clipping boundaries
L = S.GetDataInformation().GetBounds()
Lx = L[1]-L[0]
Ly = L[3]-L[2]
Lz = L[5]-L[4]
#B1 = Box(Center=[L[0]-100,L[2],L[4]+0.5*Lz],XLength=100,YLength=5,ZLength=0.5*Lz)
#B2 = Box(Center=[L[1]+100,L[2],L[4]+0.5*Lz],XLength=100,YLength=5,ZLength=0.5*Lz)

#Creating clipping box
clip1 = Clip(Input=S)
clip1.ClipType = 'Box'
clip1.Scalars = ['POINTS', '']
if fold_on_right_side:
    clip1.ClipType.Bounds = [L[0]+Lx/2,L[1]+5,L[2],L[3],L[4]+0.25*Lz,L[4]+0.75*Lz]
else:
    clip1.ClipType.Bounds = [L[0]-5,L[0]+Lx/2,L[2],L[3],L[4]+0.25*Lz,L[4]+0.75*Lz]
clip1.InsideOut = 1
#clip1Display = Show(clip1, renderView1)
#clip1Display.DiffuseColor = [1,0,0]
#SetActiveSource(clip1)
#Hide(S, renderView1)

#Show(B1)
#Show(B2)

#Extracting surface
extractSurface1 = ExtractSurface(Input=clip1)

#Show surface
#extractSurface1Display = Show(extractSurface1, renderView1)
#extractSurface1Display.ColorArrayName = [None, '']
#Hide(S, renderView1)

#Cleaning
clean1 = Clean(Input=extractSurface1)

#Show
#clean1Display = Show(clean1, renderView1)
#clean1Display.ColorArrayName = [None, '']
#Hide(S, renderView1)

#renderView1.ResetCamera()

#Getting PolyData points
Points = servermanager.Fetch(clean1).GetPoints()

#Finding ids of extreme points
zmax = 0
zmin = Lz
ymin = Ly
ymin1 = Ly
ymin2 = Ly
if fold_on_right_side:
    for m in range(0,Points.GetNumberOfPoints()):
        r = Points.GetPoint(m)
        if r[0] > L[1] - 0.2*Lx:
            if r[1] < ymin:
                k = m
                ymin = r[1]
            if (r[0] > 0.75*L[1]) and (r[2] < (L[4]+0.25*Lz+0.5)) and (r[1] < ymin1):
                i = m
                ymin1 = r[1]
            if (r[0] > 0.75*L[1]) and (r[2] > (L[4]+0.75*Lz-0.5)) and (r[1] < ymin2):
                j = m
                ymin2 = r[1]
else:
    for m in range(0,Points.GetNumberOfPoints()):
        r = Points.GetPoint(m)
        if r[0] < L[0] + 0.2*Lx:
            if r[1] < ymin:
                k = m
                ymin = r[1]
            if (r[2] < (L[4]+0.25*Lz+0.5)) and (r[1] < ymin1):
                i = m
                ymin1 = r[1]
            if (r[2] > (L[4]+0.75*Lz-0.5)) and (r[1] < ymin2):
                j = m
                ymin2 = r[1]

print i
print j
print k

TempPath = Path + '/Temp.vtk'
SaveData(TempPath, proxy=clean1)

FileName = FileName + "Dec"
cmd = "/Users/mviana/Dropbox/GitHub/SurfaceTrim/build/SurfaceTrim.app/Contents/MacOS/SurfaceTrim -path %s -file Temp -save %s -nodes %d %d %d" %(Path,FileName,i,k,j)

os.system(cmd)

TempPath = Path + '/' + FileName + '.vtk'
Dec = OpenDataFile(TempPath)

Normals1 = GenerateSurfaceNormals(Input=Dec,ComputeCellNormals=1)

Triangulate1 = Triangulate(Normals1)

Surface = servermanager.Fetch(Triangulate1)

Cells = Surface.GetCellData()
Vectors = Cells.GetArray(0)

SurfaceDisplay = Show(Triangulate1, renderView1)
SurfaceDisplay.ColorArrayName = [None, '']
Hide(S, renderView1)

renderView1.ResetCamera()

area_fold = 0
area_flat = 0
for c in range(0,Vectors.GetNumberOfTuples()):
    area = vtk.vtkTriangle.ComputeArea(Surface.GetCell(c))
    if Vectors.GetTuple(c)[1] > 0.5:
        area_flat = area_flat + area
    else:
        area_fold = area_fold + area

print FileName
print 'Area flat = %f, Area fold = %f' %(area_flat,area_fold)

#213856, 295116
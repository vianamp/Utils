import os
import vtk
import math
import numpy
import paraview.servermanager

S = GetActiveSource()

FileName = os.path.basename(GetActiveSource().FileNames[0])
FileName = os.path.splitext(FileName)[0]

Normals = GenerateSurfaceNormals(Input=S,ComputeCellNormals=1)

Triangulate1 = Triangulate(Normals)

Surface = servermanager.Fetch(Triangulate1)

Points = Surface.GetPoints()

Cells = Surface.GetCellData()

Vectors = Cells.GetArray(0)

L = Triangulate1.GetDataInformation().GetBounds()
Lx = L[1]-L[0]
Ly = L[3]-L[2]
Lz = L[5]-L[4]

clip1 = Clip(Input=Triangulate1)
clip1.ClipType = 'Box'
clip1.Scalars = ['POINTS', '']
clip1.ClipType.Bounds = [L[0],L[1],L[2],L[3],L[4]+0.95*Lz/2,L[5]-0.95*Lz/2]
clip1.InsideOut = 1
# clip1Display = Show(clip1, renderView1)
# clip1Display.DiffuseColor = [1,0,0]
# SetActiveSource(clip1)
# Hide(S, renderView1)

area_fold = 0
area_flat = 0
for c in range(0,Vectors.GetNumberOfTuples()):
    area = vtk.vtkTriangle.ComputeArea(Surface.GetCell(c))
    if Vectors.GetTuple(c)[1] > 0.5:
        area_flat = area_flat + area
    else:
        area_fold = area_fold + area

ext_flat = area_flat/(0.05*Lz)
ext_fold = area_fold/(0.05*Lz)

print '%s, Fold Extension = %f' %(FileName,ext_fold / (ext_fold + ext_flat))

Sources = GetSources()
S1Name = Sources.keys()[0][0]

S = GetActiveSource()
Delete(S)

S = FindSource('Triangulate1')
Delete(S)

S = FindSource('GenerateSurfaceNormals1')
Delete(S)

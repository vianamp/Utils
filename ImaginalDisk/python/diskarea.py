#!/usr/bin/env python
import os
import vtk
import math
import numpy
import paraview.servermanager

#Source
Source = GetActiveSource()

#Source file name
FileName = os.path.basename(Source.FileNames[0])
FileName = os.path.splitext(FileName)[0]

Normals1 = GenerateSurfaceNormals(Input=Source,ComputeCellNormals=1)

Triangulate1 = Triangulate(Normals1)

Surface = servermanager.Fetch(Triangulate1)

Cells = Surface.GetCellData()

Vectors = Cells.GetArray('Normals')

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



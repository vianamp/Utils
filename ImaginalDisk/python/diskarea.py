#!/usr/bin/env python
import os
import vtk
import math
import numpy
import paraview.servermanager

Surface = servermanager.Fetch(GetActiveSource())

Cells = Surface.GetCellData()
Vectors = Cells.GetArray(1)

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


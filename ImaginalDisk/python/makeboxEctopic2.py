#!/usr/bin/env python
import os
import vtk
import math
import numpy
from paraview.simple import *
import paraview.servermanager

#RootFolder = '/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/NoFoldExperiment-TimeVaryingData/18C/Control'

#File = 'CA_9_18C_Ctrl_A1'

FilePath = raw_input("prompt")

S = ExtractSurface(Input=GetActiveSource())

T = Triangulate(Input=S)

conn = vtk.vtkPolyDataConnectivityFilter()
conn.SetInputData(servermanager.Fetch(T))
conn.SetExtractionModeToSpecifiedRegions()
conn.AddSpecifiedRegion(1)
conn.Update()

S = conn.GetOutput()

writer = vtk.vtkPolyDataWriter()
writer.SetFileName(FilePath+'-DiskDec.vtk')
writer.SetInputData(S)
writer.Write()

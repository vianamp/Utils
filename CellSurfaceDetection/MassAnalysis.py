import os, vtk, numpy

Sources = GetSources()
M = vtk.vtkMassProperties()
Path = os.path.dirname(GetActiveSource().FileNames[0])

fsave = open("%s/results.txt"%(Path), 'w')
fsave.write("Id\tScale\tVolumeError\tSurfaceAreaError\tShapeFactorError\n")

id = 0
for source in range(0,len(Sources)):
	id = id + 1;
	Name = Sources.keys()[source][0]
	S = FindSource(Name)

	for scale in numpy.arange(0.5,1.0,0.01):
		T = Transform(Input=S)
		T.Transform = 'Transform'
		T.Transform.Scale = [1.0, 1.0, scale]

		M.SetInputData(servermanager.Fetch(T))
		vol = 1-67.6662275252377/M.GetVolume()
		sar = 1-80.6665132609091/M.GetSurfaceArea()
		spf = 1-1.00226044794527/M.GetNormalizedShapeIndex()

		fsave.write("%d \t %1.5f \t %1.5f \t %1.5f \t %1.5f\n" %(id,scale,vol,sar,spf))

		Delete(T)
		del T

fsave.close()
print "[done]"

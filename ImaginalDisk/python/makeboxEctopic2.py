RootFolder = '/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/EctopicExperiment_new/Temp/29C39H/Experimental'

File = 'CA_8_39h29C_Exp_B8'

S = ExtractSurface(Input=GetActiveSource())

T = Triangulate(Input=S)

conn = vtk.vtkPolyDataConnectivityFilter()
conn.SetInputData(servermanager.Fetch(S))
conn.SetExtractionMode(3)
conn.AddSpecifiedRegion(0)
conn.Update()

S = conn.GetOutput()

writer = vtk.vtkPolyDataWriter()
writer.SetFileName(os.path.join(RootFolder,File+'-DiskDec.vtk'))
writer.SetInputData(S)
writer.Write()

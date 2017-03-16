#### import the simple module from the paraview
from paraview.simple import *
#### disable automatic camera reset on 'Show'
paraview.simple._DisableFirstRenderCameraReset()

# create a new 'Legacy VTK Reader'
cA_1_39h29C_Exp_A1Diskvtk = LegacyVTKReader(FileNames=['/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/EctopicExperiment_new/Temp/29C39H/Experimental/CA_1_39h29C_Exp_A1-Disk.vtk'])

# create a new 'TIFF Series Reader'
cA_1_39h29C_Exp_A1GFPtif = TIFFSeriesReader(FileNames=['/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/EctopicExperiment_new/Temp/29C39H/Experimental/CA_1_39h29C_Exp_A1-GFP.tif'])

# Properties modified on cA_1_39h29C_Exp_A1GFPtif
cA_1_39h29C_Exp_A1GFPtif.UseCustomDataSpacing = 1
cA_1_39h29C_Exp_A1GFPtif.CustomDataSpacing = [1.0, 1.0, 7.58]

# get active view
renderView1 = GetActiveViewOrCreate('RenderView')
# uncomment following to set a specific view size
# renderView1.ViewSize = [901, 1350]

# show data in view
cA_1_39h29C_Exp_A1GFPtifDisplay = Show(cA_1_39h29C_Exp_A1GFPtif, renderView1)
# trace defaults for the display properties.
cA_1_39h29C_Exp_A1GFPtifDisplay.Representation = 'Outline'
cA_1_39h29C_Exp_A1GFPtifDisplay.ColorArrayName = ['POINTS', '']
cA_1_39h29C_Exp_A1GFPtifDisplay.DiffuseColor = [1.0, 0.5000076295109483, 0.0]
cA_1_39h29C_Exp_A1GFPtifDisplay.BackfaceDiffuseColor = [1.0, 0.5000076295109483, 0.0]
cA_1_39h29C_Exp_A1GFPtifDisplay.GlyphType = 'Arrow'
cA_1_39h29C_Exp_A1GFPtifDisplay.ScalarOpacityUnitDistance = 3.8356160625670923
cA_1_39h29C_Exp_A1GFPtifDisplay.Slice = 66

# reset view to fit data
renderView1.ResetCamera()

# show data in view
cA_1_39h29C_Exp_A1DiskvtkDisplay = Show(cA_1_39h29C_Exp_A1Diskvtk, renderView1)
# trace defaults for the display properties.
cA_1_39h29C_Exp_A1DiskvtkDisplay.ColorArrayName = [None, '']
cA_1_39h29C_Exp_A1DiskvtkDisplay.DiffuseColor = [1.0, 0.5000076295109483, 0.0]
cA_1_39h29C_Exp_A1DiskvtkDisplay.BackfaceDiffuseColor = [1.0, 0.5000076295109483, 0.0]
cA_1_39h29C_Exp_A1DiskvtkDisplay.GlyphType = 'Arrow'
cA_1_39h29C_Exp_A1DiskvtkDisplay.SetScaleArray = [None, '']
cA_1_39h29C_Exp_A1DiskvtkDisplay.ScaleTransferFunction = 'PiecewiseFunction'
cA_1_39h29C_Exp_A1DiskvtkDisplay.OpacityArray = [None, '']
cA_1_39h29C_Exp_A1DiskvtkDisplay.OpacityTransferFunction = 'PiecewiseFunction'

# set active source
SetActiveSource(cA_1_39h29C_Exp_A1Diskvtk)

# set active source
SetActiveSource(cA_1_39h29C_Exp_A1GFPtif)

# set scalar coloring
ColorBy(cA_1_39h29C_Exp_A1GFPtifDisplay, ('POINTS', 'Tiff Scalars'))

# rescale color and/or opacity maps used to include current data range
cA_1_39h29C_Exp_A1GFPtifDisplay.RescaleTransferFunctionToDataRange(True)

# change representation type
cA_1_39h29C_Exp_A1GFPtifDisplay.SetRepresentationType('Volume')

# get color transfer function/color map for 'TiffScalars'
tiffScalarsLUT = GetColorTransferFunction('TiffScalars')
tiffScalarsLUT.RGBPoints = [22.0, 0.231373, 0.298039, 0.752941, 1100.5, 0.865003, 0.865003, 0.865003, 2179.0, 0.705882, 0.0156863, 0.14902]
tiffScalarsLUT.ScalarRangeInitialized = 1.0

# get opacity transfer function/opacity map for 'TiffScalars'
tiffScalarsPWF = GetOpacityTransferFunction('TiffScalars')
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]
tiffScalarsPWF.ScalarRangeInitialized = 1

# reset view to fit data
renderView1.ResetCamera()

# set active source
SetActiveSource(cA_1_39h29C_Exp_A1Diskvtk)

# Properties modified on cA_1_39h29C_Exp_A1DiskvtkDisplay
cA_1_39h29C_Exp_A1DiskvtkDisplay.Opacity = 0.8

# reset view to fit data
renderView1.ResetCamera()

# reset view to fit data
renderView1.ResetCamera()

# set active source
SetActiveSource(cA_1_39h29C_Exp_A1GFPtif)

# Apply a preset using its name. Note this may not work as expected when presets have duplicate names.
tiffScalarsLUT.ApplyPreset('Black-Body Radiation', True)

# Properties modified on tiffScalarsPWF
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 890.3130493164062, 0.38750001788139343, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]

# Properties modified on tiffScalarsPWF
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 897.2044677734375, 0.38750001788139343, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]

# Properties modified on tiffScalarsPWF
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 1290.0126953125, 0.08125000447034836, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]

# Properties modified on tiffScalarsPWF
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 1296.9041748046875, 0.08125000447034836, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]

# Properties modified on tiffScalarsPWF
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 1303.7955322265625, 0.08125000447034836, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]

# Properties modified on tiffScalarsPWF
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 1310.6868896484375, 0.08125000447034836, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]

# Properties modified on tiffScalarsPWF
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 1317.5782470703125, 0.08125000447034836, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]

# Properties modified on tiffScalarsPWF
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 1324.4696044921875, 0.08125000447034836, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]

# Properties modified on tiffScalarsPWF
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 1345.143798828125, 0.08749999850988388, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]

# Properties modified on tiffScalarsPWF
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 1407.1661376953125, 0.11250000447034836, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]

# Properties modified on tiffScalarsPWF
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 1441.6229248046875, 0.11874999850988388, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]

# Properties modified on tiffScalarsPWF
tiffScalarsPWF.Points = [22.0, 0.0, 0.5, 0.0, 1448.5142822265625, 0.11874999850988388, 0.5, 0.0, 2179.0, 1.0, 0.5, 0.0]

#### saving camera placements for all active views

# current camera placement for renderView1
renderView1.CameraPosition = [511.5, 4489.224731764045, 504.07]
renderView1.CameraFocalPoint = [511.5, 221.0, 504.07]
renderView1.CameraViewUp = [0.0, 0.0, 1.0]
renderView1.CameraParallelScale = 1125.8070359326314

#### uncomment the following to render all views
# RenderAllViews()
# alternatively, if you want to write images, you can use SaveScreenshot(...).
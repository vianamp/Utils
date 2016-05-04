import os, sys
from PIL import Image

folder = sys.argv[1]

flname = sys.argv[2]

os.system("pdfimages -p -q -png \"" + folder + "/" + flname + "\" \"" + folder + "/" + os.path.splitext(flname)[0] + "\"")

os.system("find " + folder + " -name \"*.png\" -size -50k -exec rm -f {} \;")


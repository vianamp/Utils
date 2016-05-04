import os, sys
from PIL import Image

root_folder = sys.argv[1]

for i in os.listdir(root_folder):
    if i.endswith(".pdf"): 
        print(i)

        os.system("pdfimages -p -q -png \"" + root_folder + "/" + i + "\" \"" + root_folder + "/" + os.path.splitext(i)[0] + "\"")

os.system("find " + root_folder + " -name \"*.png\" -size -3k -exec rm -f {} \;")


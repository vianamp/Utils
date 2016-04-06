import os
from PIL import Image

source_folder = "seismicarxiv"
destin_folder = "figs"

for i in os.listdir(os.getcwd()+"/"+source_folder):
    if i.endswith(".pdf"): 
        print(i)

        cmd = "pdfimages -p -q \"" + source_folder + "/" + i + "\" \"" + destin_folder + "/" + os.path.splitext(i)[0] + "\""

        os.system(cmd)

os.system("rm " + destin_folder + "/*.pbm")
os.system("find . -name \"" + destin_folder + "/*.ppm\" -size -3k -delete")

for i in os.listdir(os.getcwd()+"/"+destin_folder):
	print(i)
	if i.endswith(".ppm"):
		im = Image.open(destin_folder+"/"+i)
		im.save(destin_folder+"/"+os.path.splitext(i)[0]+".jpg")

os.system("rm " + destin_folder + "/*.ppm")
os.system("find . -name \"" + destin_folder + "/*.jpg\" -size -3k -delete")


TODO: find . -name "*.jpg" -size -3k -exec rm -f {} \;
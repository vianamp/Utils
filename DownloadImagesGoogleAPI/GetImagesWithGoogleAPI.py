import os
import urllib
from PIL import Image
from apiclient.discovery import build

APIKeyFile = open('api_key.txt','r')

APIKeyFileContent = APIKeyFile.read().splitlines()

APIKeyFile.close()

APIdeveloperKey = APIKeyFileContent[0]

APIcx = APIKeyFileContent[1]

service = build("customsearch", "v1",developerKey=APIdeveloperKey)

curr_idx = 1

FileName = []

for query in range(10):
    
    res = service.cse().list(
        q='beagle dog',
        cx=APIcx,
        searchType='image',
        imgType='clipart',
        start=curr_idx,
        num=10,
    ).execute()

    for item in res['items']:
        try:
            urllib.urlretrieve(item["link"],os.path.basename(item['link']))
            print(str(curr_idx) + '--' + item['title'])
            FileName.append(os.path.basename(item['link']))
        except:
            pass
        curr_idx = curr_idx + 1

curr_idx = 1
os.mkdir('results')
for fname in FileName:
    try:
        im = Image.open(fname)
        im.convert('RGB').save('results/a%05d'%curr_idx+'.jpg')
        curr_idx = curr_idx + 1 
    except:
        pass
    try:
        os.remove(fname)
    except:
        pass
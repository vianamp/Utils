import os, sys, json
from alchemyapi import AlchemyAPI

alchemyapi = AlchemyAPI()

fname = sys.argv[1]

with open(fname,'r') as f:
	Text = f.readlines()

text_file = open(fname,'w')

for fig in range(len(Text)):
	response = alchemyapi.keywords("text",Text[fig])
	if response['status'] == 'OK':
	    for keyword in response['keywords']:
	        text_file.write(str(fig)+'\t'+str(keyword['text'].encode('utf-8'))+'\t'+str(keyword['relevance'])+'\n')
	else:
	    print('Error in keyword extaction call: ', response['statusInfo'])

text_file.close()

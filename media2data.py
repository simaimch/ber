import os
import sys
import re
import io 
import json

from PIL import Image, ExifTags

from iptcinfo3 import IPTCInfo

import logging
iptcinfo_logger = logging.getLogger('iptcinfo')
iptcinfo_logger.setLevel(logging.ERROR)

conversionsRegex = [
		{"regex":"color_(\S+)","index":"color"},
		{"regex":"shoe_height_(\d\d?)cm","index":"height"},
		{"regex":"shoe_plateau_(\d\d?)cm","index":"plateau"},
		{"regex":"shoe_type_(\S+)","index":"subtype"}
	]

autotranslate = [
		{"search":"shoe","index":"type","value":"shoes"},
		{"search":"shoe","index":"shopKWs","value":["shoe"]},
		{"search":"shoe","index":"price","value":1990},
		{"search":"shoe_extra_lockable","index":"lockable","value":True}
	]

autoappend = [
		{"index":"texture","value":"res://{0}"}
	]

def mediaFolder2Data(path):
	entries = {}
	
	filelist = os.listdir(path)
	filelist.sort()
	
	for filename in filelist:
		entry = {}
		filePath = path+filename
		filnameParts = filename.split(".")
		filenameBase = filnameParts[0].lower()
		if os.path.isdir(filePath):
			continue
		
		if len(filnameParts) == 2 and filnameParts[1].lower() == "jpg":
			info = IPTCInfo(filePath)

			info['keywords'] = [x.decode('ascii') for x in info['keywords']]
			
			#entries[filenameBase] = info['keywords']
			for keyword in info['keywords']:
				for reg in conversionsRegex:
					reg_match = re.search(reg['regex'], keyword, re.IGNORECASE)

					if reg_match:
						entry[reg['index']] = reg_match.group(1)
						
			for at in autotranslate:
				if at["search"] in info['keywords']:
					entry[at["index"]] = at["value"]
			
			for ap in autoappend:
				entry[ap["index"]] = ap["value"].format(filePath)
			
			entries[filenameBase] = entry
			
	return entries
	
	
data = mediaFolder2Data('media/texture/items/shoes/set1/')

with open('test.json','w') as outfile:
	#json.dump(data,outfile)
	outfile.write(json.dumps(data, indent=4, sort_keys=True))



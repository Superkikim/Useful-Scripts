#!/bin/env python

# Execute: 

# Script: get_calm_app_json.py <calm application name>

import requests, json, urllib3, sys
from requests.auth import HTTPBasicAuth
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Parsing argument
try:
    appname=sys.argv[1] # Keep it one word with no special caracters
except Exception as error:
    print('Error parsing argument: %s' % error)
    exit(1)

url = "https://<prism_central_ip:9440/api/nutanix/v3/apps/list"

data = {
        "filter": "name==" + appname
}

myResponse = requests.post(url,json=data,auth=HTTPBasicAuth('<prism_central_user>','<prism_central_password>'), verify=False)

if(myResponse.ok):

    jData = json.loads(myResponse.content)

    print("The response contains {0} properties".format(len(jData)))
    print("\n")
    for key in jData:
        formatted_json = json.dumps(jData[key], indent=4)
        print str(key) + " : " + formatted_json
else:
    myResponse.raise_for_status()

sys.exit(0)

# Name: 		    get_clusterip_from_vm_uuid.py
# Script type:	Python
# Description:	Get the Cluster IP from the virtual machine UUID after it has been created
# Author:       Akim Sissaoui


import requests, json, urllib3, sys
from requests.auth import HTTPBasicAuth
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

argument="@@{platform.metadata.uuid}@@"
pc_user="@@{pc_user}@@"
pc_password="@@{pc_password}@@"

# Get cluster UUID
try:
    url = "https://localhost:9440/api/nutanix/v3/vms/" + argument

    myResponse = requests.get(url,auth=HTTPBasicAuth(pc_user,pc_password), verify=False)

    if(myResponse.ok):

        jData = json.loads(myResponse.content)
        uuid = (jData["status"]["cluster_reference"]["uuid"])

    else:
        myResponse.raise_for_status()

except Exception as error:
    print('Error while getting UUID: %s' % (error))
    sys.exit(1)


# Get cluster IP
try:
    url = "https://localhost:9440/api/nutanix/v3/clusters/" + uuid

    myResponse = requests.get(url,auth=HTTPBasicAuth(pc_user,pc_password), verify=False)

    if(myResponse.ok):

        jData = json.loads(myResponse.content)
        extip = (jData["spec"]["resources"]["network"]["external_ip"])

    else:
        myResponse.raise_for_status()

except Exception as error:
    print('Error while getting UUID: %s' % (error))
    sys.exit(1)

clusterip=extip

sys.exit(0)


import httplib
import os

DEVICE_MAPPING_URI = '/latest/meta-data/block-device-mapping/'

def detect_devs():
    dev_list = [ x for x in os.listdir('/sys/block')
                 if x.startswith('xvd') or x.startswith('sd') ]
    return dev_list

def _metadata_call(url):
    try:
        conn = httplib.HTTPConnection("169.254.169.254", 80, timeout=1)
	conn.request('GET', url)
	response = conn.getresponse()
	if response.status != 200:
	    return
	
	return response.read()
    except:
	return

def _get_block_devices():
    block_device_grain = { 'ephemeral': [], 'ebs': [] }
    detected_devs = detect_devs()

    for mapping in _metadata_call(DEVICE_MAPPING_URI).split('\n'):
        device = _metadata_call(DEVICE_MAPPING_URI + mapping)

        if mapping.startswith('ephemeral'):
	    for dev in detected_devs:
		if dev[-1] == device[-1]:
		    block_device_grain['ephemeral'].append(dev)
	
	elif mapping.startswith('ebs'):
	    for dev in detected_devs:
		if dev[-1] == device[-1]:
		    block_device_grain['ebs'].append(dev)
    return block_device_grain

    
def main():
    grains = {}
    grains['block_devices'] = _get_block_devices()
    return grains

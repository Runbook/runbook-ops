#!/usr/bin/env python
#####################################################################
#### monitor.py | Runbook Monitor Wrapper
#### -------------------------
#### This script can be used to integrate your own monitoring systems with Runbook
#### by wrapping your existing scripts. When executed this script will read the YAML
#### configuration file and execute the defined scripts. When the script is executed
#### this wrapper will read the exit code and send an appropriate webhook request to
#### Runbook.
#### -------------------------
#### Exit Codes:
#### 
#### When the sub shell returns with a 0 exit code the monitor will send a "Healty" webhook
#### call to Runbook. If the sub shell returns with any other exit code the monitor
#### will send a "Failed" webhook call.
#### -------------------------
#### Sample Config:
####
#### You can find a sample configurations in config/
#### -------------------------
#### Benjamin Cane | @madflojo
#####################################################################

#### Modules
#########################

## Base
import json
import sys
import getopt
import subprocess
import os

## Non-Base but needed
try:
    import requests
except:
    print "This application requires the requests python module. Please install it to continue"
    sys.exit(2)

try:
    import yaml
except:
    print "This application requires the pyYAML python module. Please install it to continue"
    sys.exit(2)



#### Core Functions
#########################

def usage(cmd):
    ''' Print usage summary '''
    print("Usage: %s -c config_file [--debug]") % cmd

def main(arguments):
    ''' Grab command line args and assign them properly '''
    ## Grab the cmdline args from sys.argv
    try:
        opts, args = getopt.getopt(arguments[1:], "c:di", ["config=", "debug", "insecure"])
    except getopt.GetoptError as err:
        usage(arguments[0])
        sys.exit(2)

    ## Set default config items
    config = None
    debug = False
    insecure = False

    ## Go through opts and set given arguments
    for opt, arg in opts:
        if opt == "-c" or opt == "--config": 
            config = arg
        elif opt == "-d" or opt == "--debug":
            debug = True
        elif opt == "-i" or opt == "--insecure":
            insecure = True
        else:
            usage(arguments[0])
            sys.exit(2)

    ## Make sure we can get a config file else exit
    if config:
        return config, debug, insecure
    else:
        usage(sys.argv[0])
        sys.exit(2)



#### Main Execution
#########################

def crAPI(url, check_key, action):
    ''' Call Runbook API to change or update the monitors status '''

    ## Generate json message
    data = { 'check_key': check_key,
                     'action': action }
    payload = json.dumps(data)

    ## Set headers
    headers = {'content-type': 'application/json'}

    ## If insecure set verify to False
    if insecure:
        verify = False
    else:
        verify = True

    if debug:
        print "-" * 25
        print("Sending %s to %s") % (payload, url)

    ## Perform Request
    try:
        req = requests.post(url, data=payload, headers=headers, verify=verify)
    except requests.exceptions.SSLError:
        ## If we get an SSL Error we should exit
        print("[Reactor Wrapper] Error communicating with Runbook, got SSL certificate error")
        print("Exiting...")
        sys.exit(2)

    ## If debug print the status code and reply data
    if debug:
        print "-" * 25
        print("[Monitor Wrapper Debug] Sent Request to Runbook and got return code: %r") % req.status_code
        print "-" * 25
        print(req.text)
        print "-" * 25

    ## Verify we got a 200
    if req.status_code == 200:
        ## Verify our request was successful
        if "success" in req.text:
            print("[Monitor Wrapper] Sent %s action to Runbook") % action
            return True
        else:
            print("[Monitor Wrapper] Error sending %s action to Runbook") % action
            return False
    else:
        print("[Monitor Wrapper] Could not send %s action to Runbook") % action
        print req.text
        return False

#### Main Execution
#########################

if __name__ == '__main__':
    ## Grab the provided command line arguments and get what we need
    configfile, debug, insecure = main(sys.argv)

    ## Verify supplied file exists and load the config
    if os.path.isfile(configfile):
        fh = open(configfile, "r")
        config = yaml.load(fh.read())
        fh.close()
    else:
        print("Error: File not found - %s") % configfile
        usage(sys.argv[0])
        sys.exit(1)

    ## Run a for loop for each monitor specified
    for key in config['monitors'].keys():
        ## Set monitor to monitor opject
        monitor = config['monitors'][key]
        print("[Monitor Wrapper] Starting to check monitor: %s") % key

        ## Verify Needed Configs are Here
        run = True
        
        ## url is required
        if monitor['url'] is None:
            run = False
            print("[Monitor Wrapper] Skipping monitor as it doesn't have a url defined: %s") % key

        ## check_key is required
        if monitor['check_key'] is None:
            run = False
            print("[Monitor Wrapper] Skipping monitor as it doesn't have a check_key defined: %s") % key

        ## cmd is required
        if "cmd" in monitor:
            cmd = monitor['cmd']
        else:
            run = False
            print("[Monitor Wrapper] Skipping monitor as it doesn't have a command: %s") % key

        ## args is optional but should be set to something
        if "args" in monitor:
            args = " " + monitor['args']
        else:
            args = "" 

        ## If all checks out let's execute
        if run:
            ## Try running the command
            try:
                print "-" * 25
                print "Monitor Output:"
                ## Commands should be run in a subshell for best portability
                code = subprocess.call(cmd + args, shell=True)
                print "-" * 25
                print("[Monitor Wrapper] Executed cmd %s and got return code %r") % ( cmd + " " + args, code )
                ## If the process is killed we may get a negative return code
                if code < 0:
                    print("[Monitor Wrapper] Execution Error: Child was terminated by signal - %d") % code
                ## Anything above 0 is failed
                elif code > 0:
                    print("[Monitor Wrapper] Monitor returned failed: %s") % key
                    crAPI(monitor['url'], monitor['check_key'], "failed")
                ## Only zero is healthy
                else:
                    print("[Monitor Wrapper] Monitor returned healthy: %s") % key
                    crAPI(monitor['url'], monitor['check_key'], "healthy")
            ## If we get an os error print the error
            except OSError as e:
                print("[Monitor Wrapper] Execution error: %r") % e

        print "#" * 50
        print ""

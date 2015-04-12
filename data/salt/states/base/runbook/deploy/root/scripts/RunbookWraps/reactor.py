#!/usr/bin/env python
#####################################################################
#### reactor.py | Runbook Local Reactor
#### -------------------------
#### This wrapper can be used to execute reactions locally when monitors fail. The agent
#### will query a Runbook webhook endpoint for the defined monitors. If those monitors
#### are in a "failed" status the wrapper will execute the scripts defined in the YAML
#### config file.
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
    ## Insecure option is not presented as it should never be used


def main(arguments):
    ''' Grab command line args and assign them properly '''
    ## Grab args from sys.argv
    try:
        opts, args = getopt.getopt(arguments[1:], "c:di", ["config=", "debug", "insecure"])
    except getopt.GetoptError as err:
        usage(arguments[0])
        sys.exit(2)

    ## Define defaults
    config = None
    debug = False
    insecure = False

    ## Go through opts and set given args
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

    ## Verify we got a config or exit
    if config:
        return config, debug, insecure
    else:
        usage(sys.argv[0])
        sys.exit(2)



#### Main Functions
#########################

def crAPI(url, check_key):
    ''' Call Runbook API to change or update the monitors status '''

    ## Create json data
    data = { 'check_key': check_key,
                     'action': "status" }
    payload = json.dumps(data)

    ## Set headers
    headers = {'content-type': 'application/json'}

    ## If insecure set verify to false
    if insecure:
        verify = False
    else:
        verify = True

    if debug:
        print "-" * 25
        print("Sending %s to %s") % (payload, url)

    ## Perform request
    try:
        req = requests.post(url, data=payload, headers=headers, verify=verify)
    except requests.exceptions.SSLError:
        print("[Reactor Wrapper] Error communicating with Runbook, got SSL certificate error")
        print("Exiting...")
        sys.exit(2)

    ## If debug print the status code
    if debug:
        print "-" * 25
        print("[Reactor Wrapper Debug] Sent Request to Runbook and got return code: %r") % req.status_code
        print "-" * 25
        print(req.text)
        print "-" * 25

    ## Verify we got a 200 return code
    if req.status_code == 200:
        ## Verify we got a success message
        if "success" in req.text:
            ## Put reply into reply dict
            reply = json.loads(req.text)
            ## Check for status key
            if "status" in reply:
                ## return status key and failure count
                return reply['status'], reply['failcount']
            else:
                print("[Reactor Wrapper] Didn't get a status from url: %s") % url
                return False
        else:
            print("[Reactor Wrapper] Error checking status from Runbook for url: %s") % url
            return False
    else:
        print("[Reactor Wrapper] Error checking status from Runbook for url: %s") % url
        return False



#### Main Execution
#########################

if __name__ == '__main__':
    ## Grab the provided command line arguments and get what we need
    configfile, debug, insecure = main(sys.argv)

    ## Check if config is a file and load configurations
    if os.path.isfile(configfile):
        fh = open(configfile, "r")
        config = yaml.load(fh.read())
        fh.close()
    else:
        print("Error: File not found - %s") % configfile
        usage(sys.argv[0])
        sys.exit(1)

    ## Loop through monitors
    for key in config['monitors'].keys():
        ## Set monitor to monitor object
        monitor = config['monitors'][key]
        print("[Reactor Wrapper] Starting to check monitor: %s") % key

        ## Verify Needed Configs are Here
        run = True

        ## url is required
        if monitor['url'] is None:
            run = False
            print("[Reactor Wrapper] Skipping monitor as it doesn't have a url defined: %s") % key

        ## check_key is required
        if monitor['check_key'] is None:
            run = False
            print("[Reactor Wrapper] Skipping monitor as it doesn't have a check_key defined: %s") % key

        ## If url and check_key are present make request
        if run:
            ## Perform API call
            status, failcount = crAPI(monitor['url'], monitor['check_key'])
            print("[Reactor Wrapper] Checked Monitor %s and got status %s") % (key, status)
            if "reactions" in monitor:
                for rkey in monitor['reactions'].keys():
                    reaction = monitor['reactions'][rkey]
                    print("[Reactor Wrapper] Checking if I should run reaction %r for check %r") % (rkey, key)

                    ## Verify necessary reaction configs are available
                    runreaction = True

                    ## cmd is required
                    if "cmd" in reaction:
                        cmd = reaction['cmd']
                    else:
                        runreaction = False
                        print("[Reactor Wrapper] Skipping reaction as it doesn't have a cmd defined: %s") % rkey

                    ## args are optional
                    if "args" in reaction:
                        args = " " + reaction['args']
                    else:
                        args = ""

                    ## callon is required and should be either healthy or failed
                    if reaction['callon'] != status:
                        runreaction = False
                        if debug:
                            print("[Reactor Wrapper Debug] Skipping as this reaction is defined for %s") % reaction['callon']
        
                    ## trigger is required and should be less than failcount to run            
                    if reaction['trigger'] <= failcount:
                        print("[Reactor Wrapper] failcount %d is greater than or equal to trigger %d") % (failcount, reaction['trigger'])
                    else:
                        runreaction = False
                        print("[Reactor Wrapper] Skipping reaction as we have not reached an appropriate failcount: %d") % failcount

                    ## If everything checks out run the reaction
                    if runreaction:
                        try: 
                            print "-" * 25
                            print "Execution Output:"
                            code = subprocess.call(cmd + args, shell=True)
                            print "-" * 25
                            if debug:
                                print("[Reactor Wrapper Debug] Execution exited with %d") % code
                        except OSError as e:
                            print("[Reactor Wrapper] Execution Error: %s") % e

            else:
                print("[Reactor Wrapper] Skipping monitor %s as there are no reactions defined") % key

        ## Print fancy formatting at the end of each monitor
        print "#" * 50
        print("")

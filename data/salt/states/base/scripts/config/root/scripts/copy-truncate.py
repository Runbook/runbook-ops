#!/usr/bin/python
#### This script will take a log file from cmdline
#### copy the file and then truncate the original
#### To be used with find or other commands
#### ---------------------------------------------
#### Benjamin Cane - 04/29/2013

## Import modules
import sys, getopt, os
from shutil import copy2
from subprocess import call

## Gather cmdline vars and process them
def main(argv):
    retention = 0
    gzip = 0
    try:
        opts, args = getopt.getopt(argv, "r:gh", ["retention=","gzip"])
    except getopt.GetoptError:
        print("Usage: copy-truncate.py -r [retention] -g")
        print("Usage: copy-truncate.py -retention=NUM --gzip") 
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print("Usage: copy-truncate.py -r [retention] -g")
            print("Usage: copy-truncate.py  -retention=NUM --gzip") 
            sys.exit(2)
        elif opt in ('-r', '--retention'):
            retention = int(arg)
        elif opt in ('-g', '--gzip'):        
            gzip = 1
    return retention, gzip, args 

## Define a custom copy function to not repeat tasks
def myCopy(oldfile, newfile, gzip):
    if os.path.isfile(oldfile):
        print("%s -> %s") % (oldfile, newfile)
        copy2(oldfile, newfile)
        if gzip == 1:
            try:
                call(["gzip", "-f", newfile])
            except:
                print("Could not gzip file %s") % newfile
    else:
        print("%s does not exist") % oldfile

## Initialize
if __name__ == "__main__":
    global vars
    ret, gzip, args = main(sys.argv[1:])

## For each file
for file in args:
    ## Only run if file exists
    if os.path.isfile(file):
        ## Determin Number of files to keep
        numbers = range(1,ret)
        ## Oldest to Newest
        numbers.sort(reverse=True)
        for number in numbers:
            filenum = number - 1
            ## Add .gz extention
            if gzip == 1:
                newfile = file + "." + str(number) + ".gz"
                oldfile = file + "." + str(filenum) + ".gz"
            else:
                newfile = file + "." + str(number)
                oldfile = file + "." + str(filenum)
            myCopy(oldfile, newfile, 0)
        ## Copy
        newfile = file + "." + str("0")
        myCopy(file, newfile, gzip)
        ## Truncate
        fh = open(file, "w")
        fh.close()
    else:
        print("%s does not exist") % file

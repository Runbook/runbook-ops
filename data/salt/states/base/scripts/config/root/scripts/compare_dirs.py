#!/usr/bin/python
#### This script will take two directories from cmdline
#### and compare files that exist in both
#### --------------------------------------------------
#### Benjamin Cane - 06/04/2013

############################################################
## Import Modules

import os
import sys
import filecmp
import difflib
import re
import time



############################################################
## Define Functions

def compare_file(filename, dir1, dir2, outdir):
  """ Compare files using difflib """
  ## Open files and readlines
  file1 = dir1 + "/" + filename
  file2 = dir2 + "/" + filename
  f1 = open(file1, "r")
  f2 = open(file2, "r")
  text1 = f1.readlines(2)
  text2 = f2.readlines(2)

  ## Open output file
  outfile = outdir + "/" + filename
  create_outdir(outfile)
  outfh = open(outfile, "w")

  ## Diff text1 and text2 and print output to outfile
  for output in difflib.context_diff(text1, text2, fromfile=file1, tofile=file2):
    outfh.write(output)

  ## Close Files
  f1.close()
  f2.close()
  outfh.close()


def gather_dirs(dir1, dir2):
  """ Gather a list of unique directories from dir1 and dir2 """
  dirlist = []
  ## Strings for removing dir1 and dir2 from oswalk output
  s1 = "^" + dir1 + "/"
  s2 = "^" + dir2 + "/"

  ## Use os.walk() to find all directories and files
  for root, dlist, flist in os.walk(dir1):

    for d in dlist:
      directory = root + "/" + d
      ## Remove base directory from string
      directory = re.sub(s1, "", directory)

      ## Check if in dirlist already
      if not directory in dirlist:
        dirlist.append(directory)

  ## Use os.walk() to find all directories and files
  for root, dlist, flist in os.walk(dir2):

    for d in dlist:
      directory = root + "/" + d
      ## Remove base directory from string
      directory = re.sub(s2, "", directory)

      ## Check if in dirlist already
      if not directory in dirlist:
        dirlist.append(directory)

  ## Sort list before returning
  dirlist.sort()
  return dirlist


def compare_dir(directory, dir1, dir2):
  difflist = []
  leftlist = []
  rightlist = []
  directory1 = dir1 + "/" + directory
  directory2 = dir2 + "/" + directory

  ## Check if directories exist then run dircmp
  if check_isdir(directory1, directory2):
    compare = filecmp.dircmp(directory1, directory2)

    ## Generate list of common differing files
    for name in compare.diff_files:
      f = directory + "/" + name
      difflist.append(f)

    ## Generate list of files + dirs only in dir1
    for name in compare.left_only:
      leftlist.append(directory + "/" + name)

    ## Generate list of files + dirs only in dir2
    for name in compare.right_only:
      rightlist.append(directory + "/" + name)

  else:
    ## Check if directory1 exists
    if os.path.isdir(directory1):
      leftlist.append(directory)
    ## Or if directory2 exists
    elif os.path.isdir(directory2):
      rightlist.append(directory)
    else:
      print("I don't know how %s got here...") % directory

  return difflist, leftlist, rightlist


def check_isdir(dir1, dir2):
  """ Check if 2 directories exist """
  if not os.path.isdir(dir1):
    return False
  elif not os.path.isdir(dir2):
    return False
  else:
    return True


def create_outdir(filename):
  """ Create directory path on disk from filename """
  ## Get path
  path = "/".join(filename.split("/")[:-1])
  if os.path.isdir(path) is False:
    ## Create Path
    os.makedirs(path)


def summary_file(mylist, output):
  """ Create a summary_file for provided list"""
  filename = output + "." + time.strftime("%m.%d.%Y-%X-%Z.txt")
  fh = open(filename, "w")
  for item in mylist:
    fh.write(item + "\n")
  fh.close
  print("Created Summary file: %s") % filename



############################################################
## Validate and Gather cmdline vars

## Validate
if len(sys.argv) != 4:
  print('Invalid Arguments: %s dir1 dir2 outdir') % str(sys.argv[0])
  sys.exit(2)

## Set Vars
dir1, dir2, outdir = sys.argv[1:]



############################################################
## Start executing

## Check if directories exist first
if check_isdir(dir1, dir2):
  filelist = []
  rightlist = []
  leftlist = []

  ## Gather a list of directories in dir1 and dir2
  dirlist = gather_dirs(dir1, dir2)

  ## For each directory see whats diff and unique
  for directory in dirlist:
    flist, llist, rlist = compare_dir(directory, dir1, dir2)
    for f in flist:
      filelist.append(f)
    for l in llist:
      leftlist.append(l)
    for r in rlist:
      rightlist.append(r)

  ## For each differing file create a diff file
  for f in filelist:
    compare_file(f, dir1, dir2, outdir)

  ## Start screen output
  print("Comparision Finished Please check the contents of %s") % outdir
  print("-" * 25)

  ## Create a list of differing files
  difffile = outdir + "/" + "diff-files"
  summary_file(filelist, difffile)

  ## Create a list of files in dir2 only
  leftfile = outdir + "/" + "leftonly"
  summary_file(leftlist, leftfile)

  ## Create a list of files in dir2 only
  rightfile = outdir + "/" + "rightonly"
  summary_file(rightlist, rightfile)

  print("-" * 25)
  ## Print Quick Summary to Screen
  print("Number of differing files: %s") % len(filelist)
  print("Number of files only in %s: %s") % (dir1, len(leftlist))
  print("Number of files only in %s: %s") % (dir2, len(rightlist))

else:
  print("Let's try again with valid directories?")
  print("One of your arguments was not a directory")
  sys.exit(2)
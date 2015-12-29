# Runbook

## What is Runbook

[Runbook](https://runbook.io) is an open source monitoring service that allows you to perform automated "reactions" when issues are detected. Giving you the ability to automatically resolve DevOps alerts with zero human interaction.

Simply put, Runbook is what you would get if Nagios and IFTTT had a baby.

## Documentation

Developer and User docs can be found in the [docs](docs/) directory and on [ReadTheDocs](https://runbook.readthedocs.org).

## This Repo

This repository contains configurations and scripts necessary for running Runbooks production environment. If you are looking for the code that runs Runbook check out our main [repository](https://github.com/asm-products/cloudroutes-service).

This repo is designed to be self sufficent development environment, all sensitive information has been scrubbed and is kept in a secret repository.

**Important Files:**
* `data/salt` - Saltstack states/pillars/reactor configurations
* `Vagrantfile` - Vagrant file for launching a development environment
* `server.yml` - YAML configuration file containing development vagrant servers

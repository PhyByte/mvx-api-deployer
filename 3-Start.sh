#!/bin/bash

# Load variables from configuration File
source config.cfg

# Import scripts for the different scripts
source scripts/0-common.sh
source scripts/5-manage-services.sh

# Start all services
ObsSquad_Start
EsIndexer_Start
EsKibana_Start
MxApi_Start
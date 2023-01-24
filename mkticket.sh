#!/bin/bash

# call signture check
if [ $# -ne 1 ]; then
    echo "Usage: $(basename $0) <project_name>"
    exit 1
fi

# paths
TICKETS_ROOT=/home/fherter/Tickets
TICKET_FOLDER="${TICKETS_ROOT}/$1"

# check if folder already exists
if [ -d ${TICKET_FOLDER} ]; then
    echo "folder '${TICKET_FOLDER}' already exists.. doing nothing"
    exit 1
fi

mkdir -p ${TICKET_FOLDER}/{Data,Images,Output,Process/Scripts,Process/OPF}

# write config script
CONFIG_FILE=${TICKET_FOLDER}/Process/Scripts/config.txt

echo \
"[pipeline]
fill_occlusion_holes = 1/0

[stitching]
oblique = dense
blending_algorithm = full/fast/deghost
use_gpu = yes/no

[images]
opfProject = ${TICKET_FOLDER}/Process/OPF/project.json

[output]
filename = ${TICKET_FOLDER}/Output/out.tif

[dsm]
files_pattern = ${TICKET_FOLDER}/Process/DSM/<FILENAMES_USING_{row}_{col}>.tiff" > ${CONFIG_FILE}

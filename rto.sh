#!/bin/bash

#run test_ortho (rto)

#---------------------------------------------------------------------constants
ID_LENGTH=2

#--------------------------------------------------------------helper functions
get_current_max_id() {
    max=0
    for f in $(ls ../Output | grep '^[0-9]'); do
        tmp=$(echo $f | sed 's/\(^[0-9]*\).*/\1/') #first number in string
        if [[ -n "${tmp// }" && $tmp -gt $max  ]]; then # if tmp without ' ' is empty, see [1]
                max=$tmp
        fi
    done
    echo $max
}

add_padding() {
    result=$1
    let padding_length=$ID_LENGTH-${#1}
    for i in {0..$padding_length}; do
        result="0${result}"
    done
    echo $result
}

get_next_id() {
    let "result = $(get_current_max_id) + 1"
    echo $(add_padding $result)
}

make_seconds_human_readible() {
    local T=$1
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    (( $D > 0 )) && printf '%dd ' $D
    (( $H > 0 )) && printf '%dh ' $H
    (( $M > 0 )) && printf '%dm ' $M
    printf '%ds' $S
}

seconds_since_last_touch() {
    seconds_last_touched=$(date -r ${1} +%s)
    seconds_now=$(date +%s)
    ((seconds_since_last_touched = seconds_now - seconds_last_touched))
    echo $seconds_since_last_touched
}

make_red() {
    red='\033[0;31m'
    no_color='\033[0m'
    echo -e "${red}${1}${no_color}"

    #RED='\033[0;31m'
    #NC='\033[0m' # No Color
    #echo -e "I ${RED}love${NC} Stack Overflow"
}

#-----------------------------------------------------------------sanity checks
# config exists
if [[ ! -f config.txt ]]; then
    echo "config.txt missing!"
    exit 1
fi

# binary exists
binary=/home/fherter/Code/pix4d-rag/build-fastmap-Release/bin/test_ortho
if [[ -f $binary ]]
then
    echo "bin: '"$binary"'"
    seconds=$(seconds_since_last_touch ${binary})

    if [[ seconds -gt $((1*60)) ]] # alert if binary is stale
    then
        read -p "age: $(make_red "$(make_seconds_human_readible ${seconds})") " -n 1 -r
    else
        read -p "age: $(make_seconds_human_readible ${seconds}) " -n 1 -r
    fi
else
    echo could not find binary: $binary
    exit 1
fi

echo $seconds

#-------------------------------------------------------------------identifiers
experiment_name=$(echo $* | tr -s ' ' | sed 's/ /_/g')
next_id=$(get_next_id)
folder_name=${next_id}_${experiment_name}
output_folder=../Output/${folder_name} # synchronized with path in config.txt
ortho_name=${folder_name}_ortho

#------------------------------------------------------------------------set-up

mkdir $output_folder

# create config
config=$(cat config.txt)
config=$(echo "${config}" | sed "s/<OUTFOLDER>/${folder_name}/")
config=$(echo "${config}" | sed "s/<ORTHO>/${ortho_name}/")
config_name=${next_id}_config.txt
config_path=$output_folder/${config_name}
echo "$config" >> $config_path

log_name=${next_id}_log.txt
log_path=${output_folder}/${log_name}

#--------------------------------------------------------------------here we go
${binary} -f $config_path | tee $log_path

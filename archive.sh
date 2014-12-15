#!/bin/bash
# A script to generate an entry for a meetup with all the required resources.

set -e

####################
# Helper functions #
####################

function _guess_short_name () {
    if [ ! -z "${PWL_AUTHORS}" ]
    then
        PWL_SHORTNAME=$(echo ${PWL_AUTHORS}| \
                               awk -F "," '{print $NF}'| \
                               awk -F " " '{print $NF}'| \
                               tr '[:upper:]' '[:lower:]')
    fi
}

#################################
# Meetup info related functions #
#################################

function get_date (){
    SUNDAY=$(date --date="last sunday"  +'%Y-%m-%d')
    read -p "Enter the date of the meetup: " -e -i ${SUNDAY} DATE
}

function get_meetup_url () {
    read -ep "Enter the meetup url: " PWL_MEETUP_URL
}

################################
# Paper info related functions #
################################

function get_paper_title (){
    read -ep "Enter the title of the paper: " PWL_TITLE
}

function get_paper_authors (){
    read -ep "Enter authors (comma separated) list for the paper: " PWL_AUTHORS
}

function get_paper_shortname (){
    _guess_short_name
    read -ep "Enter a shortname for the paper: " -i ${PWL_SHORTNAME} PWL_SHORTNAME
}

function get_paper_url () {
    read -ep "Enter the url/file path to get the paper: " -i "file://${PWD}" PWL_URL
}

function get_paper () {
    EXT=`echo "${PWL_URL}"|awk -F "." '{print $NF}'`
    PWL_PAPER_FNAME="${PWL_SHORTNAME}.${EXT}"
    curl $PWL_URL -o "$1/${PWL_SHORTNAME}.${EXT}"
}

###############################
# Presenter related functions #
###############################

function get_presenter_name (){
    read -ep "Enter presenter's name: " PWL_PRESENTER_NAME
    PWL_PRESENTER_FIRST_NAME=$(echo ${PWL_PRESENTER_NAME}|awk -F " " '{print $1}'|tr '[:upper:]' '[:lower:]')
}

function get_presenter_url () {
    read -ep "Enter a url for the presenter: " -i "http://" PWL_PRESENTER_URL
}

function get_slides_url () {
    read -ep "Enter the url/file path for the slides: " -i "file://${PWD}" PWL_SLIDES_URL
}

function get_slides () {
    EXT=`echo "${PWL_SLIDES_URL}"|awk -F "." '{print $NF}'`
    PWL_SLIDES_FNAME="${PWL_SHORTNAME}-slides.${EXT}"
    curl $PWL_SLIDES_URL -o "$1/${PWL_SHORTNAME}-slides.${EXT}"
}


function create_readme () {
    eval "echo \"$(cat ./template_README.md)\"" > "${PWL_DIR}/README.md"
}

# Get meetup info
get_date
get_meetup_url

# Get paper info
get_paper_title
get_paper_authors
get_paper_shortname
get_paper_url

# Get presenter info
get_presenter_name
get_presenter_url
get_slides_url

# Create directory for meetup and get paper, slides
PWL_DIR="${DATE}-${PWL_SHORTNAME}-${PWL_PRESENTER_FIRST_NAME}"
mkdir -p "${PWL_DIR}"
get_paper "${PWL_DIR}"
get_slides "${PWL_DIR}"

# Create README
create_readme

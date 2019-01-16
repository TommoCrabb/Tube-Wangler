#!/usr/bin/env bash

# VARIABLES
date=$( date +%F_%T )
logging=0
verbose=0
feedRgx='^(https?://www.youtube.com/feeds/videos.xml\?channel_id=[-_[:alnum:]]{24})[[:blank:]]+([^[:blank:]]+)[[:blank:]]+(.+)$'
videoRgx='^https?://www.youtube.com/watch\?v=([-_[:alnum:]]{11}) .*$'
feedFilter='^http'
e=""

# VARIABLES (FILES)
feed_file="feeds"
xslt_file="stylesheet.xslt"
hist_file="history"
log_file="${date}.log"
err_file="${date}.err"

function log() {
	(( ${verbose} == 1 )) && echo "${1}"
	(( ${logging} == 1 )) && echo "${1}" >> "${log_file}"
}

function error() { 
	echo "${1}" | tee -a "${err_file}"
}

function help() {
cat << EOF
OPTIONS
-l :Enable logging 
-v :Verbose mode 
-p :Print the feeds file and exit 
-s PATTERN :Search the feeds file for regexp PATTERN 
-d PATTERN :Only process feeds that match regexp PATTERN
-e Inverts pattern matching. Must come before -s or -d
-f FILE :Supply a custom feeds file. Useful for having a second go at feeds that failed to download
-h :Help
EOF
}

########### 
# OPTIONS #
###########

while getopts "hlvpef:d:s:" option ; do
	case "${option}" in
		l) logging=1 ;;
		v) verbose=1 ;;
		h) help ; exit ;;
		p) cat "${feed_file}" ; exit ;;
		s) grep -iE ${e} -e "^http.*${OPTARG}" "${feed_file}" ; exit ;;
		d) feedFilter="^http.*${OPTARG}" ;;
		e) e="-v" ;;
		f) feed_file="${OPTARG}" ;;
		*) echo "Unrecognised option. Use -h for help." ; exit ;;
	esac
done

###############
# SCRIPT BODY #
###############

echo "### ${date} ###" >> "${hist_file}"
mapfile -t feeds < <( grep -iE ${e} -e "${feedFilter}" "${feed_file}" )
for feed in "${feeds[@]}" ; do
	[[ "${feed}" =~ ${feedRgx} ]] || { log "Failed to match: ${feed}" ; continue ; }
	feedUrl="${BASH_REMATCH[1]}"
	feedQuality="${BASH_REMATCH[2]}"
	feedTitle="${BASH_REMATCH[3]}"
	mapfile -t videos < <( { wget -O - "${feedUrl}" || error "FAILED TO DOWNLOAD: ${feed}" ; } | { xsltproc "${xslt_file}" - || error "FAILED TO PARSE: ${feed}" ; } )
		for video in "${videos[@]}" ; do
			[[ "${video}" =~ ${videoRgx} ]] || { error "FAILED TO MATCH: ${video}" ; continue ; }
			! grep -qF -e "${BASH_REMATCH[1]}" "${hist_file}" &&  echo "${video}" | tee -a "${date}_${feedQuality}" "${hist_file}"
		done
done 

###########################
# PRINT LOG & ERROR FILES #
###########################

[[ -f "${log_file}" ]] && echo -e "\n===\nLOG\n===\n" && cat "${log_file}"
[[ -f "${err_file}" ]] && echo -e "\n======\nERRORS\n======\n" && cat "${err_file}"

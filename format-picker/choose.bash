#!/usr/bin/env bash

function sift() {
	local x y
	for x in "${@}" ; do
		if [[ "${avail[$x]+1}" ]] ; then
			selec+=( "${avail[$x]}" )
			break
		fi
	done
}

function skip() {
	local x y
	for y in "${full[@]}" ; do echo "${y}" >> "${skip_file}" ; done
}

function ask() {
	local x y
	select x in "${selec[@]}" ; do
		if [[ "${x}" =~ ${fRgx} ]] ; then
			case "${BASH_REMATCH[2]}" in
				mp4) format="${BASH_REMATCH[1]}+140" ;;
				webm) format="${BASH_REMATCH[1]}+251" ;;
				*) echo "Error selecting audio" ; exit ;;
			esac
			echo "${id} # ${format} # ${comment}" >> "${out}"
		else
			skip
		fi 
		break
	done
}


date=$( date )
config="opts-youtube.conf"
input="${1}"
out="${input}_commands"
skip_file="${out}_skipped"
q="${1}"
declare -A avail # selec
declare -a selec full
qRgx='^.*_(720p|1080p)_.*$'
fRgx='^([0-9]{2,3})[[:space:]]+(webm|mp4)[[:space:]]+(.*)$'
iRgx='^\[info\] Available formats for ([-_[:alnum:]]{11}):$'
hRgx='^(https://www.youtube.com/watch\?v=[-_[:alnum:]]{11}) # (.*)$'

[[ "${q}" =~ ${qRgx} ]]
case "${BASH_REMATCH[1]}" in
	"720p") mp4=( 136 ) ; vp9=( 247 ) ;;
	"1080p") mp4=( 299 298 137 136 ) ; vp9=( 303 302 248 247 ) ;;
	*) all=1 ;;
esac

mapfile -t map < "${input}"
for line in "${map[@]}" ; do
	full+=( "${line}" )
	if [[ "${line}" == "<" ]] ; then 
		echo -e "=====================\n${header}\nEnter anything else to skip."
		sift "${mp4[@]}"
		sift "${vp9[@]}"
		[[ "${#selec[@]}" == 0 ]] && skip || ask
		avail=() 
		selec=()
		full=()
	elif [[ "${line}" =~ ${fRgx} ]] ; then avail["${BASH_REMATCH[1]}"]="${BASH_REMATCH[0]}"
	elif [[ "${line}" =~ ${iRgx} ]] ; then id="${BASH_REMATCH[1]}"
	elif [[ "${line}" =~ ${hRgx} ]] ; then header="${BASH_REMATCH[0]}" ; url="${BASH_REMATCH[1]}" ; comment="${BASH_REMATCH[2]}"
	fi
done 

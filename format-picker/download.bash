#!/usr/bin/env bash


input="${1}"
rgx='^([-_[:alnum:]]{11}) # ([0-9]{2,3}\+[0-9]{2,3}) # (.*)$'
mapfile -t ungot < "${input}" 

while true ; do
	[[ "${#ungot[@]}" == 0 ]] && break 
	for x in "${!ungot[@]}" ; do
		echo -e "============"
		if [[ "${ungot[$x]}" =~ ${rgx} ]] ; then
			echo -e "MATCH\n${ungot[$x]}"
			id="${BASH_REMATCH[1]}"
			format="${BASH_REMATCH[1]}"
			comment="${BASH_REMATCH[1]}"
			if ./youtube-dl --config-location opts-youtube.conf -f "${format}" -- "https://www.youtube.com/watch?v={$id}" ; then
				sed -r "s/^${id}/# ${id}/" -i "${input}"
				unset ungot[$x]
			fi
		else
			echo -e "NO MATCH\n${ungot[$x]}"
			unset ungot[$x]
		fi
	done
done

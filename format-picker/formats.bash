#!/usr/bin/env bash

ytdl="../youtube-dl"
in="${1}"
out="${in}_formats"
fail="${out}_failed"

while read line ; do

	"${ytdl}" -F "${line}" | tee -a "${out}"
	if [[ "${PIPESTATUS[0]}" == 0 ]] ; then
		echo -e "${line}\n<" | tee -a "${out}"
	else
		echo "${line}" | tee -a "${fail}"
	fi

done < "${in}"

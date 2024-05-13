#!/bin/sh
#
# MK-RPM-FILES --Mung a list of files for use as a RPM "files" section.
#
version="VERSION"
while read file; do
    case "$file" in
#    (*man[0-9]*) echo "%doc $file.gz";;
    (*man[0-9]*) echo "%doc $file";;
    (*.txt)	echo "%doc $file";;
    (*.pdf)	echo "%doc $file";;

    (*/etc/cron.hourly/*)	echo "$file";;
    (*/etc/cron.daily/*)	echo "$file";;
    (*/etc/cron.weekly/*)	echo "$file";;
    (*/etc/cron.monthly/*)	echo "$file";;

    (*/etc/*)	echo "%config $file";;
    (*.conf)	echo "%config $file";;
    (*.cfg)	echo "%config $file";;
    (*.ini)	echo "%config $file";;

    (*.py)	echo "${file}"; echo "${file}o"; echo "${file}c";;
    (*)		echo "$file";;
    esac
done

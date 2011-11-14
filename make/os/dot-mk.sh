#!/bin/sh
#
# DOT-MK.SH	--Create the fallback ".mk" file for the OS directory
#
date=$(date)
os_list=$(echo *.mk| sed -e s/.mk//g)
cat <<EOF
#
# .MK --Fallback make definitions for OS customisation.
#
# Remarks:
# Do not edit this file! 
# it was automatically generated on $date
#
\$(info "OS" must have one of the following values:)
\$(info $os_list)
\$(error The variable "OS" is not defined. )
EOF
#!/bin/bash

CURDIR=`pwd`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TODAY=`date +"%Y%m%d"`
TODAY_SEARCH=$TODAY"T000000"
TOMORROW_SEARCH=`date +"%Y%m%dT000000" --date="next day"`

/bin/bash $DIR/get_vevents.sh report $TODAY_SEARCH $TOMORROW_SEARCH | awk -v pattern="SUMMARY:.+$TODAY" -v dir=$DIR '$0 ~ pattern {print $3,tolower($5);}'

#!/bin/bash

### This shell script is used to create new events in caldav on our owncloud server after a machine booking on our grr server

set -x


usage="$0 machineNumber bookuser starttime endtime 'description'"

if [ "$#" -lt 4 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ];then
    echo $usage
    exit 1
else

    machine=$1
    bookuser=$2
    starttime=$3
    endtime=$4
    DESCRIPTION=${5}
    # need to remove "\n"
    # source: https://stackoverflow.com/questions/1251999/how-can-i-replace-a-newline-n-using-sed
    DESCRIPTION=`echo "${DESCRIPTION}" |sed ':a;N;$!ba;s/\n/ /g'`
    CURDIR=`pwd`
    DIR=$( dirname "${BASH_SOURCE[0]}" )
    cd $DIR

    source .client_config

    random1=`</dev/urandom tr -dc '1-9a-z' | head -c8; echo ""`
    random2=`</dev/urandom tr -dc '1-9a-z' | head -c4; echo ""`
    random3=`</dev/urandom tr -dc '1-9a-z' | head -c4; echo ""`
    random4=`</dev/urandom tr -dc '1-9a-z' | head -c4; echo ""`
    random5=`</dev/urandom tr -dc '1-9a-z' | head -c12; echo ""`

    #cUID=`</dev/urandom tr -dc '1-9a-z' | head -c10; echo ""`

    # ics example 8cbf7d9e-6g68-43b9-zb3c-073a8e6b8f46.ics
    cUID=$random1-$random2-$random3-$random4-$random5
    ics=$cUID.ics

    NOW=`date +%Y%m%dT%H%M%S`

    template=template.ics

    cp $DIR/template.ics $ics

    sed -i "s|reservation machine|reservation machine $machine par $bookuser a partir de $starttime|g" $ics
    sed -i "s|20160225T083000|$starttime|g" $ics
    sed -i "s|20160225T090000|$endtime|g" $ics
    sed -i "s|99g999gggg|$cUID|g" $ics
    sed -i "s|20160224T172807|$NOW|g" $ics
    sed -i "s|20160224T172807|$NOW|g" $ics
    sed -i "s|to_replace|$DESCRIPTION|g" $ics

    curl -k --user $user -X PUT -H "Content-Type: text/calendar; charset=utf-8" --data-binary @./$ics --url $caldav_url/$ics

    cd $CURDIR

fi

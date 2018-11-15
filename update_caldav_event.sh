#!/bin/bash

### This shell script is used to update new events in caldav on our owncloud server after a machine booking on our grr server

usage="$0 machineNumber bookuser starttime"

if [ "$#" -ne 3 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ];then
    echo $usage
    exit 1
else

    machine=$1
    bookuser=$2
    starttime=$3

    CURDIR=`pwd`
    DIR=$( dirname "${BASH_SOURCE[0]}" )
    cd $DIR

    source .client_config

    for f in *ics;do
        if [ "$f" != "template.ics" ]
        then
            line="$( grep 'SUMMARY:' $f )" 
            linearray=( $line )
            dat="$( grep 'DTSTART\;TZID=Europe/Paris:' $f )"
            da=${dat:26}
            ma=${linearray[2]}
            us=${linearray[4]}

            if [ $machine = $ma ]; then
                if [ $bookuser = $us ]; then
                    if [ $starttime = $da ]; then
                        curl -k --user $user -X DELETE -H $f --url $caldav_url/$f
                        cp $DIR/$f $DIR/archives/$f 
                        rm -f $f
                        exit 0                        
                    fi 
                fi
            fi

        fi 
    done

    cd $CURDIR 

fi

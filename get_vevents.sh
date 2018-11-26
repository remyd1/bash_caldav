#!/bin/bash

CURDIR=`pwd`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


source $DIR/.client_config

usage="$0 report [START DATE (YYMMDD)] [END DATE (YYMMDD)] \n
       or \n $0 propfind \n
       or \n $0 get [ics] \n"

if [[ $# -lt 1 ]]; then
       echo -e $usage
       exit 1
fi

if [[ $1 == "propfind" ]]; then
    if [[ -n $user ]]; then
        request="curl --silent -k --user $user -X PROPFIND "
    else
        request="curl --silent -X PROPFIND "
    fi
    request=$request" --header 'Depth: 1'
      --header 'Prefer: return-minimal'
      --header 'Content-Type: application/xml; charset=utf-8'
      --url $caldav_url"
elif [[ $1 == "get" ]]; then
    ics=$2
    url=$caldav_url/$ics
    if [[ -n $user ]]; then
        request="curl --silent -k --user $user -X GET "
    else
        request="curl --silent -X GET "
    fi
    request=$request" --header 'Depth: 1'
      --header 'Prefer: return-minimal'
      --header 'Content-Type: application/xml; charset=utf-8'
      --data-binary '<C:calendar-query xmlns:D=\"DAV:\" xmlns:C=\"urn:ietf:params:xml:ns:caldav\">'
      --url $url"
elif [[ $1 == "report" ]]; then
    #START=$2"T000000Z"
    if [[ $2 != "basic" ]]; then
        req_type_basic=false
        START=$2
    else
        req_type_basic=true
    fi

    if [[ -n $user ]]; then
        request="curl --silent -k --user $user -X REPORT "
    else
        request="curl --silent -X REPORT "
    fi

    request=$request" --header 'Depth: 1'"
    request=$request" --header 'Prefer: return-minimal'"
    request=$request" --header 'Content-Type: application/xml; charset=utf-8'"
    #request=$request" --header 'Content-Length: 0'"
    request=$request" --data-binary '<C:calendar-query xmlns:D=\"DAV:\" xmlns:C=\"urn:ietf:params:xml:ns:caldav\">"
    if [[ $req_type_basic == true ]]; then
        prop='    <D:prop>
        <D:getetag />
        <C:calendar-data />
    </D:prop>'
        filter='    <C:filter>
        <C:comp-filter name="VCALENDAR" />
    </C:filter>'
    else
        prop='
        <D:prop>
          <D:getetag/>
            <C:calendar-data>
              <C:comp name="VCALENDAR">
                <C:prop name="VERSION"/>
                <C:comp name="VEVENT">
                  <C:prop name="SUMMARY"/>
                  <C:prop name="UID"/>
                  <C:prop name="DTSTART"/>
                  <C:prop name="DTEND"/>
                  <C:prop name="DURATION"/>
                  <C:prop name="RRULE"/>
                  <C:prop name="RDATE"/>
                  <C:prop name="EXRULE"/>
                  <C:prop name="EXDATE"/>
                  <C:prop name="RECURRENCE-ID"/>'
        prop=$prop'
              </C:comp>
              <C:comp name="VTIMEZONE" />
            </C:comp>
          </C:calendar-data>
        </D:prop>'
        filter='
    <C:filter>
      <C:comp-filter name="VCALENDAR">
        <C:comp-filter name="VEVENT">
          <C:time-range start="'$START
        if [[ -n $3 ]]; then
            #END=$3"T000000Z"
            END=$3
            filter=$filter'" end="'$END'"/>'
        else
            filter=$filter'" />'
        fi
        filter=$filter"
        </C:comp-filter>
      </C:comp-filter>
    </C:filter>"
    fi
    request=$request$prop$filter
    request=$request"</C:calendar-query>'"
    request=$request" --url $caldav_url"
fi



echo "##########################################"
echo "Request"
echo "##########################################"

echo $request

echo "##########################################"
echo "Results"
echo "##########################################"

eval $request

cd $CURDIR

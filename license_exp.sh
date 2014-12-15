#!/bin/bash

ADDR=""
SCRIPT="From: license_notify@update.com"
SUBJ=""
BODY="This is a automated script to notify the status of licenses in used."
EMAIL=""
INPUT=./exp_dates.csv
OLDIFS=$IFS
IFS=","

CURRENTDATE="$(date +%Y%m%d)"
FUTURE30="$(date "+%Y%m%d" -d "+30 days")"
FUTURE60="$(date "+%Y%m%d" -d "+60 days")"
FUTURE90="$(date "+%Y%m%d" -d "+90 days")"

function printhelp {
    echo "Syntax: script broadcast_address@example.com"
    exit 1
}

function send_notice {
    EMAIL="$ADDR\n$SCRIPT\n$SUBJ\n$BODY\n"
    echo -e $EMAIL | /usr/sbin/sendmail -t
    echo -e Email sent to $SCRIPT
}

# Quit if no arguments
if [ $# -eq 0 ]
then
    printhelp
else
    for ARG in "$@"
    do
        # Store email address
        if [[ $ARG =~ ^[a-zA-Z0-9_+%=-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$ ]]
        then
            ADDR="To: $ARG"
        fi
    done
fi

# Check exp date & Populate email
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read product exp_date
do
    if [ "$exp_date" -gt "$FUTURE90" ]
    then
        echo -e "$product has over 90 days left on license."
    elif [ "$exp_date" -gt "$FUTURE60" ]
    then
            SUBJ="Subject: Warning! $product expires in 90 days or less."
        send_notice
    elif [ "$exp_date" -gt "$FUTURE30" ]
    then
            SUBJ="Subject: Warning! $product expires in 60 days or less."
        send_notice
    elif [ "$exp_date" -gt "$CURRENTDATE" ]
    then
            SUBJ="Subject: Warning! $product expires in 30 days or less."
        send_notice
    else
            SUBJ="Subject: Warning! $product is now expired."
        send_notice
    fi
done < $INPUT
IFS=$OLDIFS
exit 1

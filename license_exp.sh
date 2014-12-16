#!/bin/bash

ADDR="To: blake.mcneal@fundtehc.com"
SCRIPT="From: license_notify@update.com"
SUBJ="Licenses: Less Then 90 Days Left"
BODY="This is a automated script to notify the status of licenses in used."
EMAIL=""
INPUT=./exp_dates.csv
OUTPUT=./body.txt
OLDIFS=$IFS
IFS=","

CURRENTDATE="$(date +%Y%m%d)"
FUTURE30="$(date "+%Y%m%d" -d "+30 days")"
FUTURE60="$(date "+%Y%m%d" -d "+60 days")"
FUTURE90="$(date "+%Y%m%d" -d "+90 days")"

function send_notice {
    while read line
        do BODY="$BODY\n$line"
    done < "body.txt"
    EMAIL="$ADDR\n$SCRIPT\n$SUBJ\n$BODY\n"
    echo -e $EMAIL | /usr/sbin/sendmail -t
    echo -e Email sent to $ADDR
}

# Check exp date & Populate email
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read product exp_date
do
    if [ "$exp_date" -gt "$FUTURE90" ]
    then
        echo -e "$product has over 90 days left on license." >> $OUTPUT
    elif [ "$exp_date" -gt "$FUTURE60" ]
    then
        echo -e "Warning! $product expires in 90 days or less." >> $OUTPUT
        
    elif [ "$exp_date" -gt "$FUTURE30" ]
    then
        echo -e "Warning! $product expires in 60 days or less." >> $OUTPUT
       
    elif [ "$exp_date" -gt "$CURRENTDATE" ]
    then
        echo -e "Warning! $product expires in 30 days or less." >> $OUTPUT
       
    else
        echo -e "Warning! $product is now expired." >> $OUTPUT
        
    fi
done < $INPUT
send_notice
IFS=$OLDIFS
exit 1

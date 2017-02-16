#!/bin/bash

# HOW TO TEST

# su - icinga -s /bin/bash -c '/usr/bin/env SLACK_WEBHOOK_URL=<YOUR_SLACK_WEBHOOK_INTEGRATION_URL> SLACK_CHANNEL=<YOUR_SLACK_ALERT_CHANNEL> /etc/icinga2/scripts/slack-host-notification.sh --HOSTSTATE DOWN --HOSTOUTPUT testhostoutput --HOST_NAME testhostname --HOSTDISPLAYNAME testhostdisplayname --NOTIFICATIONAUTHORNAME testauthor --NOTIFICATIONCOMMENT "Testing notifications" --NOTIFICATIONTYPE Test'

# Get arguments from cmd
TEMP=`getopt -o a --long HOSTADDRESS:,HOSTALIAS:,HOSTDISPLAYNAME:,HOST_NAME:,HOSTOUTPUT:,HOSTSTATE:,NOTIFICATIONAUTHORNAME:,NOTIFICATIONCOMMENT:,NOTIFICATIONTYPE:,SLACK_BOTNAME:,SLACK_CHANNEL:,SLACK_WEBHOOK_URL:,USEREMAIL: -n '/etc/icinga2/scripts/slack-host-notification.sh' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"
#echo "$TEMP"

while true ; do
    echo "$1"
    echo "$2"
    case "$1" in
        --HOSTADDRESS ) HOSTADDRESS="$2"; shift 2 ;;
        --HOSTALIAS ) HOSTALIAS="$2"; shift 2 ;;
        --HOSTDISPLAYNAME ) HOSTDISPLAYNAME="$2"; shift 2 ;;
        --HOST_NAME ) HOST_NAME="$2"; shift 2 ;;
        --HOSTOUTPUT ) HOSTOUTPUT="$2"; shift 2 ;;
        --HOSTSTATE ) HOSTSTATE="$2"; shift 2 ;;
        --NOTIFICATIONAUTHORNAME ) NOTIFICATIONAUTHORNAME="$2" ; shift 2 ;;
        --NOTIFICATIONCOMMENT ) NOTIFICATIONCOMMENT="$2" ; shift 2 ;;
        --NOTIFICATIONTYPE ) NOTIFICATIONTYPE="$2" ; shift 2 ;;
        --SLACK_BOTNAME ) SLACK_BOTNAME="$2" ; shift 2 ;;
        --SLACK_CHANNEL ) SLACK_CHANNEL="$2" ; shift 2 ;;
        --SLACK_WEBHOOK_URL ) SLACK_WEBHOOK_URL="$2" ; shift 2 ;;
        --USEREMAIL ) USEREMAIL="$2" ; shift 2 ;;
        --) shift ; break ;;
        *) echo "Error..." ; break ;;
    esac
done



# Get some variables from env for testing
if [ -z "$ICINGA_HOSTNAME" ]
then
        ICINGA_HOSTNAME=$HOSTNAME
fi

if [ -z "$SLACK_WEBHOOK_URL" ]
then
        SLACK_WEBHOOK_URL="<YOUR_SLACK_WEBHOOK_INTEGRATION_URL>"
fi

if [ -z "$SLACK_CHANNEL" ]
then
        SLACK_CHANNEL="<YOUR_SLACK_ALERT_CHANNEL>"
fi

if [ -z "$SLACK_BOTNAME" ]
then
        SLACK_BOTNAME="Icinga 2 Slack Notifier"
fi

if [ -z "$SLACK_ICON_URL" ]
then
        SLACK_ICON_URL="https://exchange.icinga.com/gravatar?username=exchange&size=200"
fi

if [ -z "$NOTIFICATIONAUTHORNAME" ]
then
        NOTIFICATIONAUTHORNAME="Icinga 2"
fi

if [ -z "$NOTIFICATIONCOMMENT" ]
then
        NOTIFICATIONCOMMENT="-"
fi

if [ -z "$NOTIFICATIONTYPE" ]
then
        NOTIFICATIONTYPE="-"
fi



#Set the message icon based on ICINGA host state
if [ "$HOSTSTATE" = "DOWN" ]
then
    ICON=":bangbang:"
elif [ "$HOSTSTATE" = "UP" ]
then
    ICON=":white_check_mark:"
else
    ICON=":bell:"
fi



#Send message to Slack
PAYLOAD="payload={\"channel\": \"${SLACK_CHANNEL}\", \"icon_url\": \"${SLACK_ICON_URL}\",  \"username\": \"${SLACK_BOTNAME}\", \"text\": \"${ICON} ${HOSTSTATE} (${NOTIFICATIONTYPE}): <https://${ICINGA_HOSTNAME}/icingaweb2/monitoring/host/show?host=${HOST_NAME}|${HOSTDISPLAYNAME}> returned '${HOSTOUTPUT}'. ${NOTIFICATIONAUTHORNAME}: '${NOTIFICATIONCOMMENT}' (${NOTIFICATIONTYPE}) \"}"

curl --connect-timeout 30 --max-time 60 -s -S -X POST --data-urlencode "${PAYLOAD}" "${SLACK_WEBHOOK_URL}"

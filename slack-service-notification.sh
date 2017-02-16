#!/bin/bash

# HOW TO TEST

# su - icinga -s /bin/bash -c '/usr/bin/env SLACK_WEBHOOK_URL=<YOUR_SLACK_WEBHOOK_INTEGRATION_URL> SLACK_CHANNEL=<YOUR_SLACK_ALERT_CHANNEL> /etc/icinga2/scripts/slack-service-notification.sh --SERVICEDISPLAYNAME testservicedisplayname --SERVICEDESC testservicedesc --SERVICEOUTPUT testserviceoutput --SERVICESTATE OK --HOSTDISPLAYNAME testhostdisplayname --NOTIFICATIONAUTHORNAME testauthor --NOTIFICATIONCOMMENT "Testing notifications" --NOTIFICATIONTYPE Test'

# Get arguments from cmd
TEMP=`getopt -o a --long HOSTADDRESS:,HOSTALIAS:,HOSTDISPLAYNAME:,HOSTNAME:,NOTIFICATIONAUTHORNAME:,NOTIFICATIONCOMMENT:,NOTIFICATIONTYPE:,SERVICEDESC:,SERVICEDISPLAYNAME:,SERVICEOUTPUT:,SERVICESTATE:,SLACK_BOTNAME:,SLACK_CHANNEL:,SLACK_WEBHOOK_URL:,USEREMAIL: -n '/etc/icinga2/scripts/slack-service-notification.sh' -- "$@"`

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
        --HOSTNAME ) HOSTNAME="$2"; shift 2 ;;
        --NOTIFICATIONAUTHORNAME ) NOTIFICATIONAUTHORNAME="$2" ; shift 2 ;;
        --NOTIFICATIONCOMMENT ) NOTIFICATIONCOMMENT="$2" ; shift 2 ;;
        --NOTIFICATIONTYPE ) NOTIFICATIONTYPE="$2" ; shift 2 ;;
        --SERVICEDESC ) SERVICEDESC="$2" ; shift 2 ;;
        --SERVICEDISPLAYNAME ) SERVICEDISPLAYNAME="$2" ; shift 2 ;;
        --SERVICEOUTPUT ) SERVICEOUTPUT="$2" ; shift 2 ;;
        --SERVICESTATE ) SERVICESTATE="$2" ; shift 2 ;;
        --SLACK_BOTNAME ) SLACK_BOTNAME="$2" ; shift 2 ;;
        --SLACK_CHANNEL ) SLACK_CHANNEL="$2" ; shift 2 ;;
        --SLACK_WEBHOOK_URL ) SLACK_WEBHOOK_URL="$2" ; shift 2 ;;
        --USEREMAIL ) USEREMAIL="$2" ; shift 2 ;;
        --) shift ; break ;;
        *) echo "Error..." ; break ;;
    esac
done

ICINGA_HOSTNAME="<YOUR_ICINGAWEB2_HOSTNAME>"
SLACK_WEBHOOK_URL="<YOUR_SLACK_WEBHOOK_INTEGRATION_URL>"
SLACK_CHANNEL="<YOUR_SLACK_ALERT_CHANNEL>"
SLACK_BOTNAME="Icinga 2 Slack Notifier"

#Set the message icon based on ICINGA service state
if [ "$SERVICESTATE" = "CRITICAL" ]
then
    ICON=":bomb:"
elif [ "$SERVICESTATE" = "WARNING" ]
then
    ICON=":warning:"
elif [ "$SERVICESTATE" = "OK" ]
then
    ICON=":beer:"
elif [ "$SERVICESTATE" = "UNKNOWN" ]
then
    ICON=":question:"
else
    ICON=":white_medium_square:"
fi

#Send message to Slack
PAYLOAD="payload={\"channel\": \"${SLACK_CHANNEL}\", \"username\": \"${SLACK_BOTNAME}\", \"text\": \"${ICON} HOST: <http://${ICINGA_HOSTNAME}/icingaweb2/monitoring/host/services?host=${HOSTNAME}|${HOSTDISPLAYNAME}>   SERVICE: <http://${ICINGA_HOSTNAME}/icingaweb2/monitoring/service/show?host=${HOSTNAME}&service=${SERVICEDESC}|${SERVICEDISPLAYNAME}>  STATE: ${SERVICESTATE}\"}"

curl --connect-timeout 30 --max-time 60 -s -S -X POST --data-urlencode "${PAYLOAD}" "${SLACK_WEBHOOK_URL}"

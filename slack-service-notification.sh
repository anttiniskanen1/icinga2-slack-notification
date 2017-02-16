#!/bin/bash

# HOW TO TEST

# su - icinga -s /bin/bash -c '/usr/bin/env SLACK_WEBHOOK_URL=<YOUR_SLACK_WEBHOOK_INTEGRATION_URL> SLACK_CHANNEL=<YOUR_SLACK_ALERT_CHANNEL> /etc/icinga2/scripts/slack-service-notification.sh --SERVICEDISPLAYNAME testservicedisplayname --SERVICEDESC testservicedesc --SERVICEOUTPUT testserviceoutput --SERVICESTATE OK --HOSTDISPLAYNAME testhostdisplayname --NOTIFICATIONAUTHORNAME testauthor --NOTIFICATIONCOMMENT "Testing notifications" --NOTIFICATIONTYPE Test'

# Get arguments from cmd
TEMP=`getopt -o a --long HOSTADDRESS:,HOSTALIAS:,HOSTDISPLAYNAME:,HOST_NAME:,NOTIFICATIONAUTHORNAME:,NOTIFICATIONCOMMENT:,NOTIFICATIONTYPE:,SERVICEDESC:,SERVICEDISPLAYNAME:,SERVICEOUTPUT:,SERVICESTATE:,SLACK_BOTNAME:,SLACK_CHANNEL:,SLACK_WEBHOOK_URL:,USEREMAIL: -n '/etc/icinga2/scripts/slack-service-notification.sh' -- "$@"`

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



#Set the message icon based on ICINGA service state
if [ "$SERVICESTATE" = "CRITICAL" ]
then
    ICON=":bangbang:"
elif [ "$SERVICESTATE" = "WARNING" ]
then
    ICON=":warning:"
elif [ "$SERVICESTATE" = "OK" ]
then
    ICON=":white_check_mark:"
elif [ "$SERVICESTATE" = "UNKNOWN" ]
then
    ICON=":grey_question:"
else
    ICON=":bell:"
fi



#Send message to Slack
PAYLOAD="payload={\"channel\": \"${SLACK_CHANNEL}\", \"icon_url\": \"${SLACK_ICON_URL}\",  \"username\": \"${SLACK_BOTNAME}\", \"text\": \"${ICON} ${SERVICESTATE} (${NOTIFICATIONTYPE}): <https://${ICINGA_HOSTNAME}/icingaweb2/monitoring/service/show?host=${HOST_NAME}&service=${SERVICEDESC}|${SERVICEDISPLAYNAME}> on <https://${ICINGA_HOSTNAME}/icingaweb2/monitoring/host/services?host=${HOST_NAME}|${HOSTDISPLAYNAME}> returned '${SERVICEOUTPUT}'. ${NOTIFICATIONAUTHORNAME}: '${NOTIFICATIONCOMMENT}' (${NOTIFICATIONTYPE}) \"}"

curl --connect-timeout 30 --max-time 60 -s -S -X POST --data-urlencode "${PAYLOAD}" "${SLACK_WEBHOOK_URL}"

#!/bin/bash

# HOW TO TEST

# su - icinga -s /bin/bash -c '/usr/bin/env SLACK_WEBHOOK_URL=<YOUR_SLACK_WEBHOOK_INTEGRATION_URL> SLACK_CHANNEL=<YOUR_SLACK_ALERT_CHANNEL> /etc/icinga2/scripts/slack-service-notification.sh --SERVICEDISPLAYNAME testservicedisplayname --SERVICEDESC testservicedesc --SERVICEOUTPUT testserviceoutput --SERVICESTATE OK --HOSTDISPLAYNAME testhostdisplayname --NOTIFICATIONAUTHORNAME testauthor --NOTIFICATIONCOMMENT "Testing notifications" --NOTIFICATIONTYPE Test'

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

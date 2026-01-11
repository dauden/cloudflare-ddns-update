#!/usr/bin/env bash
# Update DNS for your domain from cloudflare
source config.sh

if ! hash curl 2>/dev/null; then
	echo "ERROR: cURL is missing."
	exit 1
fi

RECORDS=
RECORD=
RECORD_ID=
PAYLOAD_RECORD=""
LAST_IP=
CURRENT_IP=
UPDATE_RESULT=

findRecordsByName() {
  local TARGET_NAME="$1"
  # Filter JSON using jq
  RECORD=$(echo "$RECORDS" | jq --arg name "$TARGET_NAME" '.result[] | select(.name == $name)')
  if [ "$RECORD" = "" ]; then
      echo "Error: Record ${TARGET_NAME} not found."
      exit 2
  fi
}

getRecords() {
  RECORDS=$(curl "${HOST}${API_VERSION}/${ZONE_ID}/dns_records" \
    --silent \
    -H 'Content-Type: application/json' \
    --header "X-Auth-Email: ${ACCOUNT}" \
    --header "X-Auth-Key: ${API_KEY}"
  )
  if [ "$RECORDS" = "" ]; then
      echo "Error: Unable to retrieve current records."
      exit 2
  fi
}

getCurrentIp() {
  CURRENT_IP=$(curl --silent ipinfo.io/ip)
}

replaceIP() {
  local NEW_IP="$1"
  PAYLOAD_RECORD=$(echo "$RECORD" | jq --arg new_content "$NEW_IP" '
    .content = $new_content
  ')
}

updateRecord() {
  UPDATE_RESULT=$(curl --silent "${HOST}${API_VERSION}/${ZONE_ID}/dns_records/${RECORD_ID}" \
    -X PATCH \
    -H 'Content-Type: application/json' \
    -H "X-Auth-Email: ${ACCOUNT}" \
    -H "X-Auth-Key: ${API_KEY}" \
    -d "$PAYLOAD_RECORD"
    )
  if echo "$UPDATE_RESULT" | jq -e '.success == true and (.errors | length == 0)' > /dev/null; then
      echo "Operation successful"
      echo "$CURRENT_IP" > $LAST_IP_FILE
      exit 0
  else
      echo "Operation failed"
      exit 1
  fi
}

getLastIp() {
  LAST_IP=$(echo "$RECORD" | jq -r '.content')
  if [ "$LAST_IP" = "" ]; then
      echo "Error: Current IP not found from ${RECORD_NAME} zone."
      exit 2
  fi
}

getRecordId() {
  RECORD_ID=$(echo "$RECORD" | jq -r '.id')
  if [ "$RECORD_ID" = "" ]; then
      echo "Error: ID can not found form ${RECORD_NAME} zone."
      exit 2
  fi
}

updateRecordMetadata() {
    if [ "$LAST_IP" == "" ]; then
        getLastIp
    fi
    if [ "$LAST_IP" == "$CURRENT_IP1" ];
    then
      echo "Not updating DNS host ${HOST} for Record ${RECORD_NAME} of Zone Id ${ZONE_ID}: IP address unchanged"
      exit 0;
    fi
    replaceIP $CURRENT_IP
    getRecordId
    updateRecord
}

# Get last known IP address that was stored locally
if [ -f "$LAST_IP_FILE" ]; then
	LAST_IP=`head -n 1 $LAST_IP_FILE`
fi
echo "Last IP is: $LAST_IP"

getCurrentIp
echo "Current public IP detected is: $CURRENT_IP"

if [ "$LAST_IP" != "$CURRENT_IP" ];
then
  getRecords
  for RECORD_NAME in $RECORD_NAMES; do
    findRecordsByName $RECORD_NAME
    updateRecordMetadata
  done
else
  echo "Not updating DNS host ${HOST} for Record ${RECORD_NAME} of Zone id ${ZONE_ID}: IP address unchanged"
  exit 0;
fi

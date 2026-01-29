# Required changed before deploy
declare API_KEY="xxxxxxx"
declare ACCOUNT="xxxxx@gmail.com"
declare ZONE_ID="xxxxxxx"
declare DOMAIN="codingland.com"
declare RECORD_NAMES="abc, xyz"

# Options changed before deploy
declare HOST="https://api.cloudflare.com"
declare API_VERSION="/client/v4/zones"
declare LAST_IP_FILE="/tmp/dns_last_ip_$DOMAIN"
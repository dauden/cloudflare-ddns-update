# Required changed before deploy
declare API_KEY="your_copied_cloudflare_api_key"
declare ACCOUNT="your_email"
declare ZONE_ID="your_domain_zone_id"
declare RECORD_NAMES="your_domain_zone_0_name your_domain_zone_1_name"

# Options changed before deploy
declare HOST="https://api.cloudflare.com"
declare API_VERSION="/client/v4/zones"
declare LAST_IP_FILE="/tmp/dns_last_ip_$ZONE_ID"
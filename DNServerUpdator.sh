#!/bin/bash
# if you wanted to run it continuously make a crontab
#chmod +x /path/to/DNServerUpdator.sh
#crontab -e

#   ADD:    */5 * * * * /path/to/DNServerUpdator.sh


# Configuration Make sure you edit it
DOMAIN="<YourIP>.duckdns.org"
TOKEN="TOKEN given by duckdns"
IPV4_FILE="/tmp/last_ipv4.txt"
IPV6_FILE="/tmp/last_ipv6.txt"
WEBHOOK_URL="Make a webhook url to send updated ip as well just incase"

# Get current public IPv4 and IPv6 addresses
CURRENT_IPV4=$(curl -s https://api.ipify.org)
CURRENT_IPV6=$(curl -s https://api6.ipify.org)

# Load the last known IPv4 and IPv6 addresses or initialize the files
if [ -f "$IPV4_FILE" ]; then
    LAST_IPV4=$(cat "$IPV4_FILE")
else
    LAST_IPV4=""
    echo "$CURRENT_IPV4" > "$IPV4_FILE"
fi

if [ -f "$IPV6_FILE" ]; then
    LAST_IPV6=$(cat "$IPV6_FILE")
else
    LAST_IPV6=""
    echo "$CURRENT_IPV6" > "$IPV6_FILE"
fi

# Update DuckDNS with the current IPs
DUCKDNS_UPDATE_URL="https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=$CURRENT_IPV4&ipv6=$CURRENT_IPV6"
curl -s "$DUCKDNS_UPDATE_URL" > /dev/null

# Check for IPv4 changes and notify if necessary
if [ "$CURRENT_IPV4" != "$LAST_IPV4" ]; then
    echo "$CURRENT_IPV4" > "$IPV4_FILE"
    curl -H "Content-Type: application/json" \
         -d "{\"content\": \"Your current public IPv4 has changed: $CURRENT_IPV4\"}" \
         "$WEBHOOK_URL" > /dev/null
    echo "IPv4 address changed: $CURRENT_IPV4"
else
    echo "IPv4 address unchanged."
fi

# Check for IPv6 changes and notify if necessary
if [ "$CURRENT_IPV6" != "$LAST_IPV6" ]; then
    echo "$CURRENT_IPV6" > "$IPV6_FILE"
    curl -H "Content-Type: application/json" \
         -d "{\"content\": \"Your current public IPv6 has changed: $CURRENT_IPV6\"}" \
         "$WEBHOOK_URL" > /dev/null
    echo "IPv6 address changed: $CURRENT_IPV6"
else
    echo "IPv6 address unchanged."
fi

# Final message if no IP changes detected
if [ "$CURRENT_IPV4" == "$LAST_IPV4" ] && [ "$CURRENT_IPV6" == "$LAST_IPV6" ]; then
    echo "No IP changes detected."
fi

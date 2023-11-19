#!/bin/bash

CLOUDFLARE_IPS_URL=https://www.cloudflare.com/ips-v4/
CLOUDFLARE_IP_REGEX="^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$"

# Download IP list
cloudflare_ips=$(curl -s "$CLOUDFLARE_IPS_URL")

# Check content
if [ -z "$cloudflare_ips" ]
then
    echo "Fetched an empty response from URL: '$CLOUDFLARE_IPS_URL'"
    echo "Didn't update Cloudflare IPs"
    exit 1
fi

# Check each line individually
while IFS= read -r line; do
    if ! [[ $line =~ $CLOUDFLARE_IP_REGEX ]]; then
        echo "Invalid Cloudflare IP format detected: '$line'"
	echo "Didn't update Cloudflare IPs"
        exit 1
    fi
done <<< "$cloudflare_ips"

# Update file
(echo "$cloudflare_ips" | sed "s|^|allow |g" | sed "s|\$|;|g" && echo "deny all;") > /etc/nginx/cloudflare-ips-only.conf
echo "Succesfully updated Cloudflare IPs"

# Reload Nginx
echo "Now reloading Nginx..."
/etc/init.d/nginx reload

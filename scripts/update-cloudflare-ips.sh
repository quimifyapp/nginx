#!/bin/bash

CLOUDFLARE_IPS_URL=https://www.cloudflare.com/ips-v4/
CLOUDFLARE_IPS_ONLY_FILE=/etc/nginx/cloudflare-ips-only.conf
CLOUDFLARE_IP_REGEX="^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$"

# Download IP list
cloudflare_ips=$(curl -s "$CLOUDFLARE_IPS_URL")

# Check content
if [ -z "$cloudflare_ips" ]
then
	echo
	echo "Fetched an empty response from URL: "$CLOUDFLARE_IPS_URL""
	echo "Didn't update Cloudflare IPs"
	echo
	exit 1
fi

# Check each line individually
while IFS= read -r line; do
	if ! [[ $line =~ $CLOUDFLARE_IP_REGEX ]]; then
		echo
		echo "Invalid Cloudflare IP detected in line: "$line""
		echo "Didn't update Cloudflare IPs"
		echo
		exit 1
	fi
done <<< "$cloudflare_ips"

# Update file
(echo "$cloudflare_ips" | sed "s|^|allow |g" | sed "s|\$|;|g" && echo "deny all;") > "$CLOUDFLARE_IPS_ONLY_FILE"

# Show file
echo
echo "Succesfully updated Cloudflare IPs"
echo
echo "Contents of "$CLOUDFLARE_IPS_ONLY_FILE":"
echo
cat "$CLOUDFLARE_IPS_ONLY_FILE"
echo

# Reload Nginx
echo "Now reloading Nginx..."
/etc/init.d/nginx reload
echo

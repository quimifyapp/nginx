#!/bin/bash

CLOUDFLARE_IPS_ONLY_FILE=/etc/nginx/cloudflare-ips-only.conf

CLOUDFLARE_IPS_V4_URL=https://www.cloudflare.com/ips-v4
CLOUDFLARE_IPS_V6_URL=https://www.cloudflare.com/ips-v6

CLOUDFLARE_IP_V4_REGEX="^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$"
CLOUDFLARE_IP_V6_REGEX="^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))\/[0-9]{1,2}$"

# Download IP V4 list
cloudflare_ips_v4=$(curl -s "$CLOUDFLARE_IPS_V4_URL")

echo "$cloudflare_ips_v4"

# Check content
if [ -z "$cloudflare_ips_v4" ]
then
	echo
	echo "Fetched an empty response from URL: '"$CLOUDFLARE_IPS_URL"'"
	echo "Didn't update Cloudflare IPs"
	echo
	exit 1
fi

# Check each line individually
while IFS= read -r line; do
	if ! [[ $line =~ $CLOUDFLARE_IP_V4_REGEX ]]; then
		echo
		echo "Invalid Cloudflare IP V4 detected in line: '"$line"'"
		echo "Didn't update Cloudflare IPs"
		echo
		exit 1
	fi
done <<< "$cloudflare_ips_v4"

# Download IP V6 list
cloudflare_ips_v6=$(curl -s "$CLOUDFLARE_IPS_V6_URL")

# Check content
if [ -z "$cloudflare_ips_v6" ]
then
	echo
	echo "Fetched an empty response from URL: '"$CLOUDFLARE_IPS_URL"'"
	echo "Didn't update Cloudflare IPs"
	echo
	exit 1
fi

# Check each line individually
while IFS= read -r line; do
	if ! [[ $line =~ $CLOUDFLARE_IP_V6_REGEX ]]; then
		echo
		echo "Invalid Cloudflare IP V6 detected in line: '"$line"'"
		echo "Didn't update Cloudflare IPs"
		echo
		exit 1
	fi
done <<< "$cloudflare_ips_v6"

# Update file
cloudflare_ips="$cloudflare_ips_v4"$'\n'"$cloudflare_ips_v6"
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

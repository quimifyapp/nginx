#!/bin/bash

CLOUDFLARE_IP_LIST_URL=https://www.cloudflare.com/ips-v4

cloudflare_ips=$(curl -s "$CLOUDFLARE_IP_LIST_URL")

if [ -n "$cloudflare_ips" ]
then
    (echo "$cloudflare_ips" | sed "s|^|allow |g" | sed "s|\$|;|g" && echo "deny all;") > /etc/nginx/cloudflare-ips-only.conf
    /etc/init.d/nginx reload
else
    echo "Couldn't fetch Cloudflare IPs"
fi

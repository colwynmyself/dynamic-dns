#!/usr/bin/env bash

api_key="EDIT_ME"
zone="${1}"
record="${2}"
dns_record_name="${record}.${zone}"

zone_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${zone}" \
  -H "Authorization: Bearer ${api_key}" \
  -H "Content-Type: application/json" | jq -r '.result | .[0] | .id')
my_ip=$(curl -s https://canhazip.com)

dns_record_res=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=A&name=${dns_record_name}" \
  -H "Authorization: Bearer ${api_key}" \
  -H "Content-Type: application/json")

# This assumes the record exists already. I'm being lazy
dns_record_id=$(echo "${dns_record_res}" | jq -r '.result | .[0] | .id')

# Swallow the output
x=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${dns_record_id}" \
  -H "Authorization: Bearer ${api_key}" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"${dns_record_name}\",\"content\":\"${my_ip}\",\"ttl\":120,\"proxied\":false}")

echo "Editing zone ${zone} (${zone_id}). ${dns_record_name} (${dns_record_id}) -> ${my_ip}"

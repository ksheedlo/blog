#!/bin/bash

set -e

get_content_type () {
  file="$1"
  if [ ${file: -4} == ".css" ]
  then
    echo "text/css"
  elif [ ${file: -4} == ".svg" ]
  then
    echo "image/svg+xml"
  else
    file -b -I "_site/$file"
  fi
}

TMPFILE=$(mktemp /tmp/upload.XXXXXX)
curl -s -d "$(cat ~/cloudfiles.creds.json)" \
    -H 'Content-Type: application/json' \
    'https://identity.api.rackspacecloud.com/v2.0/tokens' \
    >$TMPFILE

ACCESS_TOKEN=$(jq -r '.access.token.id' <$TMPFILE)
DFW_ENDPOINT=$(jq -r '.access.serviceCatalog[] | if .name == "cloudFiles" then .endpoints else [] end | .[] | if .region == "DFW" then [.publicURL] else [] end | .[]' \
    <$TMPFILE)
rm $TMPFILE

echo "Using DFW endpoint:" "$DFW_ENDPOINT"

for file in $(find _site -type f | sed 's|^_site/||')
do
  content_type=$(get_content_type "$file")
  curl -s -X PUT "$DFW_ENDPOINT/such-bloge-many-artical/$file" \
    -H "X-Auth-Token: $ACCESS_TOKEN" \
    -H "Content-Type: $content_type" \
    --data-binary "@_site/$file"
  echo Uploaded $file
done

#!/usr/bin/env bash

set -euox pipefail

tentativeMetadata=$(echo '{ "command": ["get_property", "metadata"] }' | /usr/bin/nc -U /tmp/mpv-socket)

sleep 4

USERNAME="" # CHANGE ME
PASSWORD="" # CHANGE ME
APIKEY="3176eb0bd0ff5d1c8f15d94e3b3c98a8"      # Change if the script stops working
APISECRET="2918fac730f44f543d2568f9976ec276"   # Change if the script stops working

lfmUrl="https://ws.audioscrobbler.com/2.0"

metaDataRaw=$(echo '{ "command": ["get_property", "metadata"] }' | /usr/bin/nc -U /tmp/mpv-socket)
durationRaw=$(echo '{ "command": ["get_property", "duration"] }' | /usr/bin/nc -U /tmp/mpv-socket)

if [[ "$tentativeMetadata" != "$metaDataRaw" ]]; then
  echo "Track skipped, not scrobbling" >&2
  exit 1
fi

mediaTitle=$(echo "$metaDataRaw" | jq -r '.data.Title // .data.title // .data.TITLE // empty')
mediaArtist=$(echo "$metaDataRaw" | jq -r '.data.Artist // .data.artist // .data.ARTIST // empty')
mediaAlbum=$(echo "$metaDataRaw" | jq -r '.data.Album // .data.album // .data.ALBUM // empty')
mediaAlbumArtist=$(echo "$metaDataRaw" | jq -r '.data.album_artist // .data.Album_artist // .data.ALBUM_ARTIST // .data.albumArtist // .data.albumartist // empty')

mediaDuration=$(echo "$durationRaw" | jq -r '.data // empty')
mediaTimestamp=$(date +%s)

if [[ -z "$mediaTitle" ]]; then
  echo "Couldn't find a title for this track in metadata, not scrobbling" >&2
  exit 1
fi
if [[ -z "$mediaArtist" ]]; then
  echo "Couldn't find an artist for this track in metadata, not scrobbling" >&2
  exit 1
fi
if [[ -z "$mediaDuration" ]]; then
  echo "Couldn't get track duration" >&2
  exit 1
fi

authString="api_key${APIKEY}methodauth.getMobileSessionpassword${PASSWORD}username${USERNAME}${APISECRET}"
authSig=$(echo -n "$authString" | md5sum | awk '{print $1}')

authOutput=$(curl -s -X POST \
  --data-urlencode "method=auth.getMobileSession" \
  --data-urlencode "username=${USERNAME}" \
  --data-urlencode "password=${PASSWORD}" \
  --data-urlencode "api_key=${APIKEY}" \
  --data-urlencode "api_sig=${authSig}" \
  "$lfmUrl")

sessionKey=$(echo "$authOutput" | sed -n 's:.*<key>\(.*\)</key>.*:\1:p')

if [[ -z "$sessionKey" ]]; then
  echo "Failed auth, make sure you entered your login details correctly" >&2
  exit 1
fi

scrobbleString="api_key${APIKEY}artist${mediaArtist}methodtrack.scrobblesk${sessionKey}timestamp${mediaTimestamp}track${mediaTitle}${APISECRET}"
if [[ -n "$mediaAlbumArtist" ]]; then
  scrobbleString="albumArtist${mediaAlbumArtist}${scrobbleString}"
fi
if [[ -n "$mediaAlbum" ]]; then
  scrobbleString="album${mediaAlbum}${scrobbleString}"
fi
scrobbleSig=$(echo -n "$scrobbleString" | md5sum | awk '{print $1}')

curl -X POST \
  --data-urlencode "method=track.scrobble" \
  --data-urlencode "artist=${mediaArtist}" \
  --data-urlencode "track=${mediaTitle}" \
  --data-urlencode "timestamp=${mediaTimestamp}" \
  --data-urlencode "api_key=${APIKEY}" \
  --data-urlencode "api_sig=${scrobbleSig}" \
  --data-urlencode "sk=${sessionKey}" \
  ${mediaAlbum:+--data-urlencode "album=${mediaAlbum}"} \
  ${mediaAlbumArtist:+--data-urlencode "albumArtist=${mediaAlbumArtist}"} \
  "$lfmUrl"

exit 0
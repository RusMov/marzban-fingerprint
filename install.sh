#!/usr/bin/env bash

set -e

CONFIG_FILE="/code/app/xray/config.py"

VALUES=(chrome firefox safari ios android edge)

echo "Marzban Fingerprint Installer"
echo "============================="

CONTAINER=$(docker ps --format '{{.Names}}' | grep marzban | head -n1)

if [ -z "$CONTAINER" ]; then
  echo "Marzban container not found"
  exit 1
fi

echo "Container: $CONTAINER"
echo ""

echo "Choose fingerprint:"
select FP in "${VALUES[@]}"; do
  if [ -n "$FP" ]; then
    break
  fi
done

echo "Setting fp=$FP"

docker exec "$CONTAINER" sh -c \
"sed -i \"s/settings\\['fp'\\] = '.*'/settings['fp'] = '$FP'/g\" $CONFIG_FILE"

echo ""
echo "Restarting container marzban-marzban-1..."
docker restart marzban-marzban-1

echo ""
echo "Checking current fingerprint value:"
docker exec marzban-marzban-1 sh -c \
"grep -n \"settings\\['fp'\\]\" $CONFIG_FILE || true"

echo ""
echo "Done. Current fp should be: $FP"

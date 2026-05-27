cat > install.sh << 'EOF'
#!/usr/bin/env bash

set -e

CONFIG_FILE="/code/app/xray/config.py"

VALUES=(
  chrome
  firefox
  safari
  ios
  android
  edge
)

echo "================================="
echo " Marzban Fingerprint Installer "
echo "================================="
echo

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] Docker не установлен"
  exit 1
fi

CONTAINER=$(docker ps --format '{{.Names}}' | grep marzban | head -n1)

if [ -z "$CONTAINER" ]; then
  echo "[ERROR] Контейнер Marzban не найден"
  exit 1
fi

echo "Найден контейнер: $CONTAINER"
echo

echo "Выберите fingerprint:"
echo

for i in "${!VALUES[@]}"; do
  echo "$((i+1))) ${VALUES[$i]}"
done

echo
read -rp "Введите номер: " CHOICE

INDEX=$((CHOICE-1))
FP=${VALUES[$INDEX]}

if [ -z "$FP" ]; then
  echo "[ERROR] Неверный выбор"
  exit 1
fi

echo
echo "Устанавливаем fp=$FP"

docker exec "$CONTAINER" sh -c "sed -i \"s/settings\\['fp'\\] = '.*'/settings['fp'] = '$FP'/g\" $CONFIG_FILE"

echo
echo "Проверка:"
docker exec "$CONTAINER" sh -c "grep -n \"settings\\['fp'\\]\" $CONFIG_FILE"

echo
echo "Перезапуск контейнера..."
docker restart "$CONTAINER" >/dev/null

echo
echo "================================="
echo " Готово"
echo "================================="
echo "Текущий fingerprint: $FP"
EOF

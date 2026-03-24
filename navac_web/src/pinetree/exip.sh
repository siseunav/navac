#!/bin/bash

LOG_FILE=./exip.log

[ -f "$LOG_FILE" ] || touch "$LOG_FILE"

echo "📡 외부 접속 IP 감시 시작" >> "$LOG_FILE"

while true
do
  echo "-----------------------------" >> "$LOG_FILE"

  MOSCOW_TIME=$(TZ=Europe/Moscow date "+%Y-%m-%d %H:%M:%S")
  GMT_TIME=$(TZ=UTC date "+%Y-%m-%d %H:%M:%S")

  echo "MOSCOW TIME: $MOSCOW_TIME" >> "$LOG_FILE"
  echo "GMT TIME   : $GMT_TIME" >> "$LOG_FILE"

  echo "[INCOMING CONNECTION]" >> "$LOG_FILE"

  ss -tn state established 2>/dev/null | tail -n +2 | awk '{print $5}' | cut -d: -f1 | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -vE '^(127\.|10\.|192\.168\.)' | sort | uniq -c | while read COUNT IP
  do
    GEO=$(curl -s --max-time 2 ipinfo.io/$IP)

    echo "🌐 CLIENT IP: $IP (접속 ${COUNT}회)" >> "$LOG_FILE"
    echo "📍 GEO: $GEO" >> "$LOG_FILE"
    echo "-----------------------------" >> "$LOG_FILE"
  done

  sleep 1
done

#!/bin/bash

LOG_FILE=./appD.log

PORTS=(80 8080 3306)

CHECK_TARGETS=(
  # 🌍 글로벌 주요 사이트
  "google.com:80"
  "google.com:443"
  "youtube.com:443"
  "facebook.com:443"
  "amazon.com:443"

  # 🇰🇷 국내 주요 사이트
  "naver.com:80"
  "naver.com:443"
  "daum.net:443"
  "kakao.com:443"

  # ☁️ 클라우드
  "aws.amazon.com:443"
  "azure.microsoft.com:443"

  # 🌐 DNS (UDP 체크)
  "8.8.8.8:53"
  "8.8.4.4:53"
  "1.1.1.1:53"
  "1.0.0.1:53"
  "168.126.63.1:53"
  "168.126.63.2:53"
  "94.140.14.14:53"
  "9.9.9.9:53"
  "94.140.14.140:53"
  "94.140.14.141:53"
  "76.76.19.19:53"
  "76.223.122.150:53"
  "208.67.222.222:53"
  "208.67.220.220:53"
  "164.124.101.2:53"
  "203.248.252.2:53"
  "210.220.163.82:53"
  "219.250.36.130:53"

  # 📡 기타
  "github.com:443"
  "stackoverflow.com:443"
)

[ -f "$LOG_FILE" ] || touch "$LOG_FILE"

echo "📡 통합 감시 시작 (속도 포함)" >> "$LOG_FILE"

while true
do
  echo "-----------------------------" >> "$LOG_FILE"

  MOSCOW_TIME=$(TZ=Europe/Moscow date "+%Y-%m-%d %H:%M:%S")
  GMT_TIME=$(TZ=UTC date "+%Y-%m-%d %H:%M:%S")

  echo "MOSCOW TIME: $MOSCOW_TIME" >> "$LOG_FILE"
  echo "GMT TIME   : $GMT_TIME" >> "$LOG_FILE"

  # 🔥 로그 용량 제한 (5MB)
  if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt 5000000 ]; then
    echo "⚠️ LOG RESET (SIZE LIMIT)" > "$LOG_FILE"
  fi

  echo "[LOCAL PORT]" >> "$LOG_FILE"

  for PORT in "${PORTS[@]}"
  do
    if ss -tuln | grep -q ":$PORT "
    then
      echo "✅ LOCAL PORT $PORT : OPEN" >> "$LOG_FILE"
    else
      echo "🚨 LOCAL PORT $PORT : CLOSED !!!" >> "$LOG_FILE"
    fi
  done

  echo "[DNS + PORT CHECK]" >> "$LOG_FILE"

  for TARGET in "${CHECK_TARGETS[@]}"
  do
    HOST=$(echo "$TARGET" | cut -d: -f1)
    PORT=$(echo "$TARGET" | cut -d: -f2)

    if [ "$PORT" == "53" ]; then
      # 🔥 DNS (UDP + 속도)
      RESULT=$(dig @"$HOST" google.com +time=1 +tries=1 2>/dev/null | grep "Query time")

      if [ -n "$RESULT" ]; then
        TIME=$(echo "$RESULT" | awk '{print $4}')
        echo "✅ $HOST:$PORT : OK (${TIME} ms)" >> "$LOG_FILE"
      else
        echo "🚨 $HOST:$PORT : FAIL" >> "$LOG_FILE"
      fi

    else
      # 🔥 TCP (속도 측정)
      START=$(date +%s%3N)

      timeout 1 bash -c "echo > /dev/tcp/$HOST/$PORT" 2>/dev/null

      if [ $? -eq 0 ]; then
        END=$(date +%s%3N)
        TIME=$((END - START))
        echo "✅ $HOST:$PORT : OK (${TIME} ms)" >> "$LOG_FILE"
      else
        echo "🚨 $HOST:$PORT : FAIL" >> "$LOG_FILE"
      fi
    fi
  done

  sleep 5
done

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
    # 📡 기타
    "github.com:443"
    "stackoverflow.com:443"

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
    "76.76.19.19:22"
    "76.223.122.150:80"
    "208.67.222.222:53"
    "208.67.220.220:53"
    "164.124.101.2:53"
    "203.248.252.2:53"
    "210.220.163.82:53"
    "219.250.36.130:53"


)

[ -f "$LOG_FILE" ] || touch "$LOG_FILE"

log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

log "📡 통합 감시 시작 (실시간 출력)"

while true
do
  log "-----------------------------"

  MOSCOW_TIME=$(TZ=Europe/Moscow date "+%Y-%m-%d %H:%M:%S")
  GMT_TIME=$(TZ=UTC date "+%Y-%m-%d %H:%M:%S")

  log "MOSCOW TIME: $MOSCOW_TIME"
  log "GMT TIME   : $GMT_TIME"

  log "[LOCAL PORT]"

  for PORT in "${PORTS[@]}"
  do
    if ss -tuln | grep -q ":$PORT "
    then
      log "✅ LOCAL PORT $PORT : OPEN"
    else
      log "🚨 LOCAL PORT $PORT : CLOSED"
    fi
  done

  log "[DNS + PORT CHECK]"

  for TARGET in "${CHECK_TARGETS[@]}"
  do
    HOST=$(echo "$TARGET" | cut -d: -f1)
    PORT=$(echo "$TARGET" | cut -d: -f2)

    if [ "$PORT" == "53" ]; then
      RESULT=$(dig @"$HOST" google.com +time=1 +tries=1 2>/dev/null | grep "Query time")

      if [ -n "$RESULT" ]; then
        TIME=$(echo "$RESULT" | awk '{print $4}')
        log "✅ $HOST:$PORT : OK (${TIME} ms)"
      else
        log "🚨 $HOST:$PORT : FAIL"
      fi
    else
      START=$(date +%s%3N)

      timeout 1 bash -c "echo > /dev/tcp/$HOST/$PORT" 2>/dev/null

      if [ $? -eq 0 ]; then
        END=$(date +%s%3N)
        TIME=$((END - START))
        log "✅ $HOST:$PORT : OK (${TIME} ms)"
      else
        log "🚨 $HOST:$PORT : FAIL"
      fi
    fi
  done

  sleep 5
done

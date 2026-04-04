#!/bin/bash

LOG_FILE=log_watch.log

PORTS=(80 8080 3306 3300)

CHECK_TARGETS=(
  "google.com:80"
  "google.com:443"
  "youtube.com:443"
  "facebook.com:443"
  "amazon.com:443"
  "shully-f95f5.web.app:443"

  "naver.com:80"
  "naver.com:443"
  "daum.net:443"
  "kakao.com:443"

  "aws.amazon.com:443"
  "azure.microsoft.com:443"

  "8.8.8.8:53"
  "8.8.4.4:53"
  "1.1.1.1:53"
  "1.0.0.1:53"
  "168.126.63.1:53"
  "168.126.63.2:53"

  "github.com:443"
  "stackoverflow.com:443"
)

# 로그 파일 생성
[ -f "$LOG_FILE" ] || touch "$LOG_FILE"

# 🔥 출력 + 로그 동시에 처리 함수
log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

log "📡 통합 감시 시작 (REALTIME)"

while true
do
  log "\n-----------------------------"

  MOSCOW_TIME=$(TZ=Europe/Moscow date "+%Y-%m-%d %H:%M:%S")
  GMT_TIME=$(TZ=UTC date "+%Y-%m-%d %H:%M:%S")

  log "🕒 MOSCOW TIME: $MOSCOW_TIME"
  log "🌍 GMT TIME   : $GMT_TIME"

  # 🔥 로그 용량 제한 (50MB)
  if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt 50000000 ]; then
    echo "⚠️ LOG RESET (SIZE LIMIT)" > "$LOG_FILE"
  fi

  # =========================
  # LOCAL PORT CHECK
  # =========================
  log "\n[LOCAL PORT]"

  for PORT in "${PORTS[@]}"
  do
    if ss -tuln | grep -q ":$PORT "
    then
      log "✅ LOCAL PORT $PORT : OPEN"
    else
      log "🚨 LOCAL PORT $PORT : CLOSED"
    fi
  done

  # =========================
  # NETWORK CHECK
  # =========================
  log "\n[NETWORK CHECK]"

  for TARGET in "${CHECK_TARGETS[@]}"
  do
    HOST=$(echo "$TARGET" | cut -d: -f1)
    PORT=$(echo "$TARGET" | cut -d: -f2)

    # ================= DNS =================
    if [ "$PORT" == "53" ]; then
      RESULT=$(dig @"$HOST" google.com +time=1 +tries=1 2>/dev/null | grep "Query time")

      if [ -n "$RESULT" ]; then
        TIME=$(echo "$RESULT" | awk '{print $4}')
        log "✅ DNS $HOST:$PORT : ${TIME} ms"
      else
        log "🚨 DNS $HOST:$PORT : FAIL"
      fi

    # ================= HTTP/HTTPS =================
    elif [ "$PORT" == "80" ] || [ "$PORT" == "443" ]; then

      PROTO="http"
      [ "$PORT" == "443" ] && PROTO="https"

      START=$(date +%s%3N)

      STATUS=$(timeout 3 curl -k -s -o /dev/null -w "%{http_code}" "$PROTO://$HOST")

      if [[ "$STATUS" =~ ^2|3 ]]; then
        END=$(date +%s%3N)
        TIME=$((END - START))
        log "✅ $HOST:$PORT : ${TIME} ms (HTTP $STATUS)"
      else
        log "🚨 $HOST:$PORT : FAIL (HTTP $STATUS)"
      fi

    # ================= TCP =================
    else
      START=$(date +%s%3N)

      timeout 2 bash -c "echo > /dev/tcp/$HOST/$PORT" 2>/dev/null

      if [ $? -eq 0 ]; then
        END=$(date +%s%3N)
        TIME=$((END - START))
        log "✅ $HOST:$PORT : ${TIME} ms"
      else
        log "🚨 $HOST:$PORT : FAIL"
      fi
    fi
  done

  sleep 2222   # 👉 실시간 느낌 (기존 2222 → 10초)
done

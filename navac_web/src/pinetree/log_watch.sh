#!/bin/bash


LOG_FILE=./appD.log



# 포트 감시

PORTS=(80 8080 3306)



# DNS + 포트 같이 체크

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

  # ☁️ 클라우드 / 인프라
  "aws.amazon.com:443"
  "azure.microsoft.com:443"

  # 🌐 DNS 서버
  "8.8.8.8:53"
  "8.8.4.4:53"
  "1.1.1.1:53"

  # 📡 네트워크 확인용
  "github.com:443"
  "stackoverflow.com:443"
)



[ -f "$LOG_FILE" ] || touch "$LOG_FILE"



echo "📡 통합 감시 시작 (PORT + DNS+PORT)" >> $LOG_FILE



while true

do

  echo "-----------------------------" >> $LOG_FILE



  MOSCOW_TIME=$(TZ=Europe/Moscow date "+%Y-%m-%d %H:%M:%S")

  GMT_TIME=$(TZ=UTC date "+%Y-%m-%d %H:%M:%S")



  echo "MOSCOW TIME: $MOSCOW_TIME" >> $LOG_FILE

  echo "GMT TIME   : $GMT_TIME" >> $LOG_FILE



  # 🔥 로컬 포트

  echo "[LOCAL PORT]" >> $LOG_FILE

  for PORT in "${PORTS[@]}"

  do

    if ss -tuln | grep -q ":$PORT "

    then

      echo "✅ LOCAL PORT $PORT : OPEN" >> $LOG_FILE

    else

      echo "🚨 LOCAL PORT $PORT : CLOSED !!!" >> $LOG_FILE

    fi

  done



  # 🔥 DNS + 포트 체크 (외부 연결)

  echo "[DNS + PORT CHECK]" >> $LOG_FILE

  for TARGET in "${CHECK_TARGETS[@]}"

  do

    HOST=$(echo $TARGET | cut -d: -f1)

    PORT=$(echo $TARGET | cut -d: -f2)



    timeout 1 bash -c "echo > /dev/tcp/$HOST/$PORT" 2>/dev/null



    if [ $? -eq 0 ]; then

      echo "✅ $HOST:$PORT : OK" >> $LOG_FILE

    else

      echo "🚨 $HOST:$PORT : FAIL !!!" >> $LOG_FILE

    fi

  done



  sleep 5

done

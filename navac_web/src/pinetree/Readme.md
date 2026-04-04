<!--
PS C:\Workspace\NAVac\navac> start C:\Workspace\NAVac\navac\navac_web\src\pinetree\celebrity_mode_videp.html
//절대경로를 써서 하래이. 그럼 덜 헷갈린대이.우분투에서는 컨트롤엑스를 쓰래이.
explorer.exe celebrity_mode_videp.html

-->
=================================================================

//자는동안 로그를 추적해보재이.😘  
<!--
nano log_watch.sh
chmod +x log_watch.sh  
./log_watch.sh //tail 보다 좀 더 불안정하대이.tail은 실행 명령어래이. 누르고 숙면 같이 취하재이.  
touch appD.log  
tail -f appD.log  

✨추가했대이 추가설치하래이.05새벽 업뎃
sudo apt install dnsutils -y
stdbuf -oL ./log_pinetree.sh   //로그가 실시간이래이. 

-->
//자는동안 아이피도 추적해보재이.🤳  
  //nano ip.sh  
  ==================================================================================
  #!/bin/bash
  
  LOG_FILE=./ip.log
  [ -f "$LOG_FILE" ] || touch "$LOG_FILE"
  
  echo "🌐 IP + 위치 감시 시작" >> $LOG_FILE
  
  while true
  do
    echo "-----------------------------" >> $LOG_FILE
  
    MOSCOW_TIME=$(TZ=Europe/Moscow date "+%Y-%m-%d %H:%M:%S")
    GMT_TIME=$(TZ=UTC date "+%Y-%m-%d %H:%M:%S")
  
    echo "MOSCOW TIME: $MOSCOW_TIME" >> $LOG_FILE
    echo "GMT TIME   : $GMT_TIME" >> $LOG_FILE
  
    # 🔥 외부 IP (안정화)
    EXT_IP=$(curl -s ifconfig.me | tr -d '\n')
  
    # 🔥 위치 조회
    GEO_INFO=$(curl -s "http://ip-api.com/json/$EXT_IP")
  
    COUNTRY=$(echo "$GEO_INFO" | grep -oP '"country":"\K[^"]+')
    CITY=$(echo "$GEO_INFO" | grep -oP '"city":"\K[^"]+')
    ISP=$(echo "$GEO_INFO" | grep -oP '"isp":"\K[^"]+')
  
    echo "🌐 EXTERNAL IP: $EXT_IP" >> $LOG_FILE
    echo "📍 LOCATION: $COUNTRY / $CITY" >> $LOG_FILE
    echo "🏢 ISP: $ISP" >> $LOG_FILE
  
    # 내부 IP
    INT_IP=$(hostname -I | awk '{print $1}')
    echo "🖥 INTERNAL IP: $INT_IP" >> $LOG_FILE
  
    sleep 5
  done  
  =================================================자는 동안에도 아이피를 차단해 보재이.  
<!--
PS C:\Workspace\NAVac\navac> start C:\Workspace\NAVac\navac\navac_web\src\pinetree\celebrity_mode_videp.html
//절대경로를 써서 하래이. 그럼 덜 헷갈린대이.우분투에서는 컨트롤엑스를 쓰래이.
explorer.exe celebrity_mode_videp.html

-->
=================================================================

//자는동안 로그를 추적해보재이.😘  
<!--
nano log_watch.sh
chmod +x log_watch.sh  
./log_watch.sh //tail 보다 좀 더 불안정하대이.tail은 실행 명령어래이. 누르고 숙면 같이 취하재이.  
touch appD.log  
tail -f appD.log  

✨추가했대이 추가설치하래이.05새벽 업뎃
sudo apt install dnsutils -y
stdbuf -oL ./log_pinetree.sh   //로그가 실시간이래이. 

-->
//자는동안 아이피도 추적해보재이.🤳  
  //nano ip.sh  
  ==================================================================================
  #!/bin/bash
  
  LOG_FILE=./ip.log
  [ -f "$LOG_FILE" ] || touch "$LOG_FILE"
  
  echo "🌐 IP + 위치 감시 시작" >> $LOG_FILE
  
  while true
  do
    echo "-----------------------------" >> $LOG_FILE
  
    MOSCOW_TIME=$(TZ=Europe/Moscow date "+%Y-%m-%d %H:%M:%S")
    GMT_TIME=$(TZ=UTC date "+%Y-%m-%d %H:%M:%S")
  
    echo "MOSCOW TIME: $MOSCOW_TIME" >> $LOG_FILE
    echo "GMT TIME   : $GMT_TIME" >> $LOG_FILE
  
    # 🔥 외부 IP (안정화)
    EXT_IP=$(curl -s ifconfig.me | tr -d '\n')
  
    # 🔥 위치 조회
    GEO_INFO=$(curl -s "http://ip-api.com/json/$EXT_IP")
  
    COUNTRY=$(echo "$GEO_INFO" | grep -oP '"country":"\K[^"]+')
    CITY=$(echo "$GEO_INFO" | grep -oP '"city":"\K[^"]+')
    ISP=$(echo "$GEO_INFO" | grep -oP '"isp":"\K[^"]+')
  
    echo "🌐 EXTERNAL IP: $EXT_IP" >> $LOG_FILE
    echo "📍 LOCATION: $COUNTRY / $CITY" >> $LOG_FILE
    echo "🏢 ISP: $ISP" >> $LOG_FILE
  
    # 내부 IP
    INT_IP=$(hostname -I | awk '{print $1}')
    echo "🖥 INTERNAL IP: $INT_IP" >> $LOG_FILE
  
    sleep 5
  done
    ======================================================================자는동안 아이피를 차단해 보재이. 
#!/bin/bash

LOG_FILE=./exip_block.log

# 🔥 설정값
THRESHOLD=10
BLOCK_TIME=600
ENABLE_BLOCK=true

WHITELIST=("127.0.0.1" "YOUR_IP")

declare -A BLOCKED_IPS

[ -f "$LOG_FILE" ] || touch "$LOG_FILE"

log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

is_whitelisted() {
  local ip=$1
  for wip in "${WHITELIST[@]}"
  do
    if [ "$ip" == "$wip" ]; then
      return 0
    fi
  done
  return 1
}

block_ip() {
  local ip=$1

  if is_whitelisted "$ip"; then
    return
  fi

  if iptables -L INPUT -n | grep -q "$ip"; then
    return
  fi

  iptables -A INPUT -s "$ip" -j DROP
  BLOCKED_IPS["$ip"]=$(date +%s)

  log "🚫 BLOCKED IP: $ip"
}

unblock_expired() {
  NOW=$(date +%s)

  for ip in "${!BLOCKED_IPS[@]}"
  do
    START=${BLOCKED_IPS[$ip]}
    DIFF=$((NOW - START))

    if [ "$DIFF" -gt "$BLOCK_TIME" ]; then
      iptables -D INPUT -s "$ip" -j DROP
      unset BLOCKED_IPS["$ip"]

      log "✅ UNBLOCKED IP: $ip"
    fi
  done
}

log "📡 접속 감시 + 자동 차단 시작"

while true
do
  log "-----------------------------"

  RESULT=$(ss -tn state established 2>/dev/null | tail -n +2 | awk '{print $5}' | cut -d: -f1 | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -vE '^(127\.|10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)' | sort | uniq -c)

  for LINE in "$RESULT"
  do
    COUNT=$(echo $LINE | awk '{print $1}')
    IP=$(echo $LINE | awk '{print $2}')

    [ -z "$IP" ] && continue

    log "🌐 $IP 접속 ${COUNT}회"

    if [ "$ENABLE_BLOCK" = true ] && [ "$COUNT" -ge "$THRESHOLD" ]; then
      block_ip "$IP"
    fi
  done

  unblock_expired

  sleep 2000
done
=========================================권한 승인과 당신의 아이피를 꼭 차단제외하래이.  
chmod +x ip.sh  
touch ip.log  
tail -f ip.log
  //  여기서 나온 아이피를 당신의 아이피 🙌
GEO=$(curl -s --max-time 2 ipinfo.io/$IP)  
curl -s --max-time 2 https://ipinfo.io/$IP  
curl -s --max-time 2 https://34.117.59.81/$IP  
ENABLE_GEO=false  


========================================443 SOCKET 이래이. 
sudo ufw default deny incoming
sudo ufw allow 443/tcp
sudo ufw enable


sudo iptables -P INPUT DROP
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


//이건 안됨
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 443

sudo vi /etc/ssh/sshd_config
sudo systemctl restart ssh

===============================================================================
sudo nano /etc/resolv.conf //여기에 밑에 걸 추가하래이.

nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 168.126.63.1
nameserver 168.126.63.2
nameserver 94.140.14.14
nameserver 9.9.9.9
nameserver 94.140.14.140
nameserver 94.140.14.141
nameserver 76.76.19.19
nameserver 76.223.122.150
nameserver 208.67.222.222
nameserver 208.67.220.220
nameserver 164.124.101.2
nameserver 203.248.252.2
nameserver 210.220.163.82
nameserver 219.250.36.130ㅋ
====================================권한 승인과 당신의 아이피를 넣어주래이.  
chmod +x ip.sh  
touch ip.log  
tail -f ip.log




========================================443 SOCKET 이래이. 
sudo ufw default deny incoming
sudo ufw allow 443/tcp
sudo ufw enable


sudo iptables -P INPUT DROP
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


//이건 안됨
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 443

sudo vi /etc/ssh/sshd_config
sudo systemctl restart ssh

===============================================================================
sudo nano /etc/resolv.conf //여기에 밑에 걸 추가하래이.

nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 168.126.63.1
nameserver 168.126.63.2
nameserver 94.140.14.14
nameserver 9.9.9.9
nameserver 94.140.14.140
nameserver 94.140.14.141
nameserver 76.76.19.19
nameserver 76.223.122.150
nameserver 208.67.222.222
nameserver 208.67.220.220
nameserver 164.124.101.2
nameserver 203.248.252.2
nameserver 210.220.163.82
nameserver 219.250.36.130
===============================================================================
#Windows → Linux 파일 옮기면 CRLF → LF 변환 필수  //#! /bin/bash^M  ← 이렇게 깨진대이.🤣("/bin/bash^M: bad interpreter: No such file or directory")
sed -i 's/\r$//' log_watch.sh
#프로세스랑 로그확인  
ps -ef | grep log_watch  
tail -f nohup.out  
#이걸 사용하면 좆된대이. 쓰지말고. ".out"  
nohup ./log_watch.sh > log_watch.log 2>&1 &
# 이걸 사용하래이.
nohup ./log_pinetree.sh | tee -a log_watch.log &

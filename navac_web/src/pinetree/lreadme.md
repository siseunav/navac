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
    ====================================================================================
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

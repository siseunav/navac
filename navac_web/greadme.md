git add src/pinetree/appD.log
git commit -m "Update appD.log"

Discard the unstaged changes
git restore src/pinetree/appD.log
git restore --staged src/pinetree/appD.log

git add ./mnt/c/Workspace/NAVac/navac/navac_web/src/pinetree/preadme.md
git commit -m "update log"
git push

git push --set-upstream origin list

git remote set-url list https://github.com/siseunav/navac.git

sudo iptables -P OUTPUT ACCEPT
sudo apt update
==========================
~$ nano ~/.ssh/config

Host github.com
  Hostname ssh.github.com
  Port 443
  User git


netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=172.22.11.128


“443 only 환경에서도
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F

sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT

sudo iptables -L

ping github.com
curl https://github.com

sudo nano /etc/resolv.conf

sudo iptables-save > /tmp/backup.rules
sudo iptables -F

==================================================443온리가 그립우녜이?
sudo iptables -P OUTPUT DROP

sudo iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT


git add src/pinetree/appD.log
git commit -m "Update appD.log"

Discard the unstaged changes
git restore src/pinetree/appD.log
git restore --staged src/pinetree/appD.log

git add ./mnt/c/Workspace/NAVac/navac/navac_web/src/pinetree/preadme.md
git commit -m "update log"
git push

git push --set-upstream origin list

git remote set-url main https://github.com/siseunav/navac.git

sudo iptables -P OUTPUT ACCEPT
sudo apt update
==========================
~$ nano ~/.ssh/config

Host github.com
  Hostname ssh.github.com
  Port 443
  User git


netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=172.22.11.128


“443 only 환경에서도
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F

sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT

sudo iptables -L

ping github.com
curl https://github.com

sudo nano /etc/resolv.conf

sudo iptables-save > /tmp/backup.rules
sudo iptables -F

==================================================443온리가 그립우녜이?
sudo iptables -P OUTPUT DROP

sudo iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
//이걸 추가해 보재이.
:\~$ sudo nano /etc/hosts
140.82.112.36 ssh.github.com
140.82.112.3 github.com
140.82.114.35 api.github.com
142.250.196.14 google.com

=====================================
git pull origin list --rebase
git push

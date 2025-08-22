#!/bash
cd /opt
wget https://download.docker.com/linux/static/stable/x86_64/docker-26.0.0.tgz
tar xzvf  docker-26.0.0.tgz

sudo cp docker/* /usr/bin/
# sudo dockerd & 
## create and edit the file /etc/docker/daemon.json

#===== docker-compose 
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

#sudo vim /etc/systemd/system/docker.service
sudo cat > /etc/systemd/system/docker.service << 'EOF'
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/dockerd --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitIntervalSec=60s

[Install]
WantedBy=multi-user.target
EOF
# =====
# sudo vim /etc/systemd/system/docker.socket
sudo cat /etc/systemd/system/docker.socket << 'EOF'
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF
# ====
# 檢查 docker 群組
getent group docker
sudo groupadd docker

#-----------
#sudo usermod -aG docker $USER
sudo usermod -aG docker ${USER}
#sudo usermod -a -G docker  ec2-user 
#sudo usermod -a -G nginx  ec2-user 
newgrp docker
#-----------
##-- containerd 是 Docker 的核心元件，負責管理容器的生命週期 --##
wget https://github.com/containerd/containerd/releases/download/v1.7.0/containerd-1.7.0-linux-amd64.tar.gz

sudo tar -xzvf containerd-1.7.0-linux-amd64.tar.gz -C /usr/local/
sudo rm containerd-1.7.0-linux-amd64.tar.gz
# sudo vim /etc/systemd/system/containerd.service
sudo cat /etc/systemd/system/containerd.service << 'EOF'
#-----
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStart=/usr/local/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
#-----
# 如果上面的指令沒有回傳任何結果，則創建它
sudo groupadd docker

# 重新載入 systemd 配置
sudo systemctl daemon-reload

sudo systemctl enable --now containerd

# 啟用並啟動 docker 服務
# 啟用 docker.socket 即可，它會自動啟動 docker.service
sudo systemctl enable docker.socket --now
sudo systemctl enable docker
sudo systemctl start docker

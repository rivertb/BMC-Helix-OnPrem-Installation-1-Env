# BMC HelixOM ITOM & ITSM OnPrem Installation Step by Step 1 - Environment Preparation


## 1 Architecture Diagram

![4b080021470ebc9e06c4d71c1c8955a6.png](en-resource://database/679:1)



## 2 虚拟机准备

### 2.1 虚拟机列表

| 序号 | 主机名 | IP | OS | 配置 | 用途 | 安装的软件 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | helix-svc.bmc.local | 192.168.1.1 | CentOS8 | 4 vCPU * 8 GB RAM * 500 HDD | Helix辅助服务器 | DNS/NFS/HAProxy/eMail |
| 2 | helix-harbor.bmc.local | 192.168.1.2 | CentOS8 | 2 vCPU * 4 GB RAM * 500 HDD | 容器镜像Registry |Harbor |
| 3 | helix-k8s-master.bmc.local | 192.168.1.200 | CentOS8 | 4 vCPU * 8 GB RAM * 100 HDD | k8s管理节点 | rancher容器 |
| 4 | helix-k8s-worker01.bmc.local | 191.168.1.201 | CentOS8 | 16 vCPU * 64 GB RAM * 100 HDD | k8s工作节点1 | rancher容器 |
| 5 | helix-k8s-worker02.bmc.local | 191.168.1.202 | CentOS8 | 16 vCPU * 64 GB RAM * 100 HDD | k8s工作节点2 | rancher容器 |
| 6 | helix-k8s-worker03.bmc.local | 191.168.1.203 | CentOS8 | 16 vCPU * 64 GB RAM * 100 HDD | k8s工作节点3 | rancher容器 |
| 7 | helix-k8s-worker04.bmc.local | 191.168.1.204 | CentOS8 | 16 vCPU * 64 GB RAM * 100 HDD | k8s工作节点4 | rancher容器 |
| 8 | helix-discovery.bmc.local | 191.168.1.210 | OLinux9 | 4 vCPU * 4 GB RAM * 65 HDD | Discovery VM | Discovery VM Image导入 |

### 2.2 域名列表

| 序号 | 域名 | IP | 用途 |
| --- | --- | --- | --- |
| 1 | helix-svc.bmc.local | 192.168.1.1 | VM |
| 2 | helix-harbor.bmc.local | 192.168.1.2 | VM |
| 3 | helix-k8s-master.bmc.local | 192.168.1.200 | VM |
| 5 | helix-k8s-worker01.bmc.local | 192.168.1.201 | VM |
| 6 | helix-k8s-worker02.bmc.local | 192.168.1.202 | VM |
| 8 | helix-k8s-worker03.bmc.local | 192.168.1.203 | VM |
| 9 | helix-k8s-worker03.bmc.local | 192.168.1.203 | VM |
| 10 | helix-k8s-worker03.bmc.local | 192.168.1.210 | VM |
| 11 | smtp.bmc.local | 192.168.1.1 | ITOM |
| 12 | lb.bmc.local | 192.168.1.1 | ITOM |
| 13 | tms.bmc.local | 192.168.1.1 | ITOM |
| 14 | minio.bmc.local | 192.168.1.1 | ITOM |
| 15 | minio-api.bmc.local | 192.168.1.1 | ITOM |
| 16 | kibana.bmc.local | 192.168.1.1 | ITOM |
| 16 | adelab-private-poc.bmc.local | 192.168.1.1 | ITOM |
| 16 | adelab-disc-private-poc.bmc.local | 192.168.1.210 | ITOM |
| 17 | itsm-poc.bmc.local | 192.168.1.1 | ITSM |
| 18 | itsm-poc-int.bmc.local | 192.168.1.1 | ITSM |
| 19 | itsm-poc-smartit.bmc.local | 192.168.1.1 | ITSM |
| 20 | itsm-poc-sr.bmc.local | 192.168.1.1 | ITSM |
| 21 | itsm-poc-is.bmc.local | 192.168.1.1 | ITSM |
| 22 | itsm-poc-restapi.bmc.local | 192.168.1.1 | ITSM |
| 23 | itsm-poc-atws.bmc.local | 192.168.1.1 | ITSM |
| 24 | itsm-poc-dwp.bmc.local | 192.168.1.1 | ITSM |
| 25 | itsm-poc-dwpcatalog.bmc.local | 192.168.1.1 | ITSM |
| 26 | itsm-poc-vchat.bmc.local | 192.168.1.1 | ITSM |
| 27 | itsm-poc-chat.bmc.local | 192.168.1.1 | ITSM |
| 28 | itsm-poc-supportassisttool.bmc.local | 192.168.1.1 | ITSM |




### 2.3 虚拟机安装
在安装Linux，创建磁盘分区时，删除/home目录，重建根目录，将磁盘剩余空间全部分配给根目录
![83a4d70feb871faa8db446739f210d20.png](en-resource://database/517:1)
选择最小安装
![b6c64d1bf8580075961a56f466e1374f.png](en-resource://database/519:1)


### 2.4 辅助服务器helix-svc配置

辅助服务器helix-svc的作用是为整个Helix OnPrem提供辅助服务：

* 提供外网访问的网关
* DNS域名服务器
* 邮件服务器
* NFS为k8s集群提供块存储
* 为Helix集群提供负载均衡服务

#### 2.4.1 网络配置

为了减少网络地址占用，Helix集群的所有服务器都配置在内外IP地址段192.168.1.1/24上，只有helix-svc服务器配置了双网卡，其他虚拟机全部是单网卡配置，连接LAN网络k8s-internal。

* WAN网卡负责对外提供Helix服务
* LAN网卡负责对外服务的转发

![19d6ecb36843357aca9d5705be075c14.png](en-resource://database/645:1)

设置网络
```
nmtui-edit
```

弹出配置页面
![c7d8a0ba12a2d987083a98d641f39264.png](en-resource://database/653:1)

编辑外网网卡ens34，修改如下内容：

* 选中“Ignore automatically obtained DNS parameters”
![4bbedd242c5d77e6cd81d37d5c147b28.png](en-resource://database/659:1)

编辑内网网卡ens35，修改如下内容：

* IPv4 Configuration: Manual
* DNS: 127.0.0.1
* Search domains: bmc.local
* 选中“Never use this network for default route”
![470e5faa17e67068e3f484feb0b8303f.png](en-resource://database/657:1)

#### 2.4.2 防火墙配置

创建internal和external zone

```
nmcli connection modify ens34 connection.zone external
nmcli connection modify ens35 connection.zone internal
```

查看zone:

```
firewall-cmd --get-active-zones
```

在两个zone上设置 masquerading (source-nat)

```
firewall-cmd --zone=external --add-masquerade --permanent
firewall-cmd --zone=internal --add-masquerade --permanent
firewall-cmd --reload
```
查看当前设置
```
firewall-cmd --list-all --zone=internal
firewall-cmd --list-all --zone=external
cat /proc/sys/net/ipv4/ip_forward
```
#### 2.4.3 安装配置DNS
安装BIND作为DNS
```
dnf install bind bind-utils -y
```
拷贝配置文件
```
\cp ~/helix-metal-install/dns/named.conf /etc/named.conf
cp -R ~/helix -metal-install/dns/zones /etc/named/
```
在防火墙上开放DNS端口
```
firewall-cmd --add-port=53/udp --zone=internal --permanent
firewall-cmd --add-port=53/tcp --zone=internal --permanent
firewall-cmd --reload
```
启动DNS服务
```
systemctl enable named
systemctl start named
systemctl status named
```
重启网络服务
```
systemctl restart NetworkManager
```
验证本地DNS可以解析本地域名
```
dig lb.bmc.local
dig -o 192.168.1.1
```

#### 2.4.4 install JDK
```
yum install java-11-openjdk
ls /usr/lib/jvm/jre-11-openjdk
```

### 2.5 其他虚拟机配置网络配置 
除了helix-svc之外的其他服务器，配置如下内容：

* IPv4 Configuration: Manual
* Addresses: 为各个服务器分配的地址
* Gateway:192.168.1.1
* DNS Server:192.168.1.1
* Search dommains: bmc.local
![16ad2ab8594333940772259f06d23e71.png](en-resource://database/661:1)

验证外网访问能力
```
dig www.baidu.com
```

验证本地DNS可以解析本地域名
```
dig lb.bmc.local
dig -o 192.168.1.1
```

### 2.6 Linux参数调整
```
# 系统更新
yum update -y
yum upgrade -y

# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

# 关闭SELinux
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/sysconfig/selinux
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config

# 关闭swap
swapoff -a && sysctl -w vm.swappiness=0
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab

# 设置时区
timedatectl set-timezone Asia/Shanghai 

# 时钟同步
yum install -y chrony
systemctl start chronyd
systemctl enable chronyd

chronyc sources -V

# 设置内核参数
ulimit -SHn 65535

cat <<EOF >> /etc/security/limits.conf
* soft nofile 655360
* hard nofile 131072
* soft nproc 655350
* hard nproc 655350
* soft memlock unlimited
* hard memlock unlimited
EOF

# 重启虚拟机
reboot
```
## 3. Docker Installation

### 3.1 Docker Engine安装

   在所有VM上安装Docker，安装方法请参考：[Install Docker Engine](https://docs.docker.com/engine/install/)
    
   根据当前操作系统的类型，分别选择不同的安装方式。例如对于CentOS:
```
# Uninstall old versions
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# Set up the repository
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker Engine Latest version
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Start Docker Engine.
sudo systemctl enable --now docker   

# Verify that the installation is successful by running the hello-world image:
sudo docker run hello-world

```

### 3.2 Docker Compose安装
   在helix-harbor和helix-bhii上安装Docker Compose，安装方法请参考：[Install the Docker Compose standalone](https://docs.docker.com/compose/install/standalone/)
   
   
```
# To download and install the Docker Compose standalone
curl -SL https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

# Apply executable permissions
chmod +x /usr/local/bin/docker-compose

# Create a symbolic link
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Test and execute Docker Compose
docker-compose
```
       
       
 ## 4. 准备自签名证书
###  4.1 创建证书
 
 在helix-svc服务器上，创建CA证书和自签名证书
```
# 登录helix-svc服务器
su - root
mkdir openssl
cd openssl
cp ~/helix-metal-install/cert/create_certs.sh .
chmod a+x *.sh


# 创建Helix根证书和自签名证书
./create_certs.sh

ls

-rwxr-xr-x 1 root root 1816 Feb 27 13:24 create_certs.sh
-rw------- 1 root root 3247 Feb 27 13:24 HelixCA.key
-rw-r--r-- 1 root root 1895 Feb 27 13:24 HelixCA.crt
-rw------- 1 root root 1679 Feb 27 13:24 bmc.local.key
-rw-r--r-- 1 root root  223 Feb 27 13:24 bmc.local.cnf
-rw-r--r-- 1 root root 1094 Feb 27 13:24 bmc.local.csr
-rw-r--r-- 1 root root   41 Feb 27 13:24 HelixCA.srl
-rw-r--r-- 1 root root 1574 Feb 27 13:24 bmc.local.crt
```

创建Helix使用的全量证书
```
cat bmc.local.crt HelixCA.crt > full_chain.crt
openssl x509 -text -in full_chain.crt
```

### 4.2 设置免登录
```
cd /root
ssh-keygen -t rsa

for i in helix-svc helix-k8s-master helix-k8s-worker01 helix-k8s-worker02 helix-k8s-worker03 helix-k8s-worker04;do ssh-copy-id -i .ssh/id_rsa.pub $i;done
```

### 4.3 添加自签名证书信任

将证书添加到所有的服务器中
```
cd /root/
for node in helix-svc helix-harbor helix-k8s-master helix-k8s-worker01 helix-k8s-worker02 helix-k8s-worker03 helix-k8s-worker04; do echo $node; scp HelixCA.crt root@$node:/etc/pki/ca-trust/source/anchors/; ssh root@$node "update-ca-trust enable;update-ca-trust extract;systemctl restart docker";done
```
## 5. Harbor Registry镜像库准备
### 5.1 Harbor Installation

* 为Harbor准备https证书
    ```
    # Configure Harbor registry by using self-signed SSL certificates
    mkdir -p /data/cert
    scp root@helix-svc:/root/openssl/bmc.local.crt /data/cert/
    scp root@helix-svc:/root/openssl/bmc.local.key /data/cert/
    scp root@helix-svc:/root/openssl/HelixCA.crt /data/cert/
    
    # Convert yourdomain.com.crt to yourdomain.com.cert, for use by Docker
    cd /data/cert
    openssl x509 -inform PEM -in bmc.local.crt -out bmc.local.cert
    
    # Copy the server certificate, key and CA files into the Docker certificates folder on the Harbor host.
    #mkdir -p /etc/docker/certs.d/yourdomain.com/
    mkdir -p /etc/docker/certs.d/bmc.local/

    cp /data/cert/bmc.local.cert /etc/docker/certs.d/bmc.local/
    cp /data/cert/bmc.local.key /etc/docker/certs.d/bmc.local/
    cp /data/cert/HelixCA.crt /etc/docker/certs.d/bmc.local/
    
    # Restart Docker Engine.
    systemctl restart docker
    ```

* 在helix-harbor安装harbor镜像库，安装方法请参考：[Create a Harbor registry](https://docs.bmc.com/xwiki/bin/view/IT-Operations-Management/On-Premises-Deployment/BMC-Helix-IT-Operations-Management-Deployment/itomdeploy251/Deploying/Preparing-for-deployment/Accessing-container-images/Setting-up-a-Harbor-registry-in-a-local-network-and-synchronizing-it-with-BMC-DTR/)。

    ```
    # Download Harbor
    dnf install wget -y
    #wget https://github.com/goharbor/harbor/releases/download/v<version>/harbor-offline-installer-v<version>.tgz

    # Example
    wget https://github.com/goharbor/harbor/releases/download/v2.1.4/harbor-offline-installer-v2.1.4.tgz

    # Unzip the tar file
    tar xvzf harbor-offline-installer*.tgz

    # Go to the Harbor directory
    cd harbor

    # Copy the configuration template
    cp harbor.yml.tmpl harbor.yml

    ```

* in the harbor.yml file, update the values for the following parameters:

    ```
    # Specify the name of system where you want to install Harbor.
    hostname: helix-harbor.bmc.local
    
    # Specify the password for the Harbor system administrator.
    harbor_admin_password: bmcAdm1n
    
    # The path of cert and key files for nginx
    certificate: /data/cert/bmc.local.crt
    private_key: /data/cert/bmc.local.key
    
    # Harbor repository
    data_volume: /data/harbor

    ```

* install the Harbor registry
    ```
    mkdir /data/harbor
    ./install.sh
    ```


* Configure the Harbor registry
    Log in to the Harbor registry and perform the following steps to create a new project:
    
    Select Projects and then click NEW PROJECT.
    ![9e71bdb911eddc52ca942b4e50ba34fd.png](en-resource://database/529:1)
    
    In the New Project window, specify the following values:
    Project Name: Enter bmc.
    Access Level: Select the Public check box.
    Leave the other parameters to their default values.
    ![b0ef11825bfa31300cab49d3463f2eeb.png](en-resource://database/531:1)
    Click OK
    

### 5.2 Helix容器镜像文件下载
如果helix-harbor服务器可以连接互联网，镜像下载可以在helix-harbor操作，否则需要另找一台服务器，安装上docker engine后操作。

* Create Helix images download directory

    ```
    mkdir /root/helix-images-25.1
    cd /root/helix-images-25.1

    # cp helix-load-images.sh to /root/helix-images-25.1
    # cp helix-save-images.sh to /root/helix-images-25.1
    # cp saveall.sh to /root/helix-images-25.1
    ```
*     Download Helix ITOM all_images_<version>.txt file from BMC Docs to root/helix-images-25.1
    [all_images_25.1.txt](https://docs.bmc.com/xwiki/bin/view/IT-Operations-Management/On-Premises-Deployment/BMC-Helix-IT-Operations-Management-Deployment/itomdeploy251/Deploying/Preparing-for-deployment/Accessing-container-images/Setting-up-a-Harbor-registry-in-a-local-network-and-synchronizing-it-with-BMC-DTR/)
    
 
    ```
    pwd
    /root/helix-images-25.1
    
    ls -l
    -rw-r--r-- 1 root root 13685 Feb 25 15:55 all_images_25.1.00.txt
    -rw-r--r-- 1 root root  2158 Feb 25 15:44 helix-load-images.sh
    -rw-r--r-- 1 root root  2399 Feb 25 15:44 helix-save-images.sh
    -rw-r--r-- 1 root root   174 Feb 25 15:44 saveall.sh
    
    # Convert the file to an UNIX format
    dnf install dos2unix -y
    dos2unix all_images_25.1.00.txt
    
    # Get Helix ITOM different repository images lists
    
    # lp0lz: BMC Helix Platform  images
    cat all_images_25.1.00.txt | grep lp0lz > lp0lz_images.txt
    
    # lp0oz: BMC Helix Intelligent Automation images
    cat all_images_25.1.00.txt | grep lp0oz > lp0oz_images.txt
    
    # lp0pz: BMC Helix Continuous Optimization images
    cat all_images_25.1.00.txt | grep lp0pz > lp0pz_images.txt
    
    # lp0mz: BMC Helix Operations Management on-premises images
    cat all_images_25.1.00.txt | grep lp0mz > lp0mz_images.txt
    
    # la0cz: BMC Helix AIOps images
    cat all_images_25.1.00.txt | grep la0cz > la0cz_images.txt
    
    # Run batch downloader for Helix ITOM image
    chmod a+x *.sh
    nohup ./saveall.sh > nohup.out &
    tail -f nohup.out

    # Due to the limitation of network speed, the entire download process may take several hours to several days.
    ```

### 5.3 Rancher容器镜像文件下载

在本测试中，Helix安装的Kubernetes集群采用Rancher进行创建和管理。下面的步骤是准备Rancher的镜像文件。

如果helix-harbor服务器可以连接互联网，镜像下载可以在helix-harbor操作，否则需要另找一台服务器，安装上docker engine后操作。

Rancher镜像文件的下载，可以参考Rancher官方文档：[Collect and Publish Images to your Private Registry](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/other-installation-methods/air-gapped-helm-cli-install/publish-images)。

* 选择Rancher版本，下载离线工具脚本文件与镜像列表文件，可以参考文档：[Rancher Release](https://github.com/rancher/rancher/releases)
![d94b8ff2cfb2c1610d4f34d2ab56fb01.png](en-resource://database/533:1)

* Rancher镜像文件下载
    ```
    #mkdir rancher
    mkdir /root/rancher-images-2.10.2
    
    # cp rancher-images.txt, rancher-load-images.sh, rancher-save-images.sh file to /root/rancher-images-2.10.2 directory
    cd /root/rancher-images-2.10.2
    chmod a+x *.sh
        
    ls -l
    -rw-r--r-- 1 root root 27835 Feb 25 16:33 rancher-images.txt
    -rwxr-xr-x 1 root root  4115 Feb 25 16:33 rancher-load-images.sh
    -rwxr-xr-x 1 root root  1757 Feb 25 16:33 rancher-save-images.sh

    # 对镜像列表进行排序和唯一化，以去除重复的镜像源。
    sort -u rancher-images.txt -o rancher-images.txt

    # 创建所需镜像的压缩包
    nohup ./rancher-save-images.sh --image-list ./rancher-images.txt > nohup.out &

    ```

### 5.4 Helix镜像导入
本节的工作内容是将下载的Helix Image镜像包文件导入helix-harbor服务器上部署的Harbor registry.
```
cd /root/helix-image-25.1
nohup ./loadall.sh > nohup.out &
tail -f nohup.out
```

### 5.5 Rancher镜像导入
本节的工作内容是将下载的Rancher Image镜像包文件导入helix-harbor服务器上部署的Harbor registry.

* Create new project rancher

    Log in to the Harbor registry and perform the following steps to create a new project:
    Select Projects and then click NEW PROJECT. In the New Project window, specify the following values:
    
    Project Name: Enter rancher.
    Access Level: Select the Public check box.
    Leave the other parameters to their default values.

    ![f0b2f33e4b28f981a30fd072e2d83354.png](en-resource://database/635:1)

* Rancher Image Importing
    使用脚本 rancher-load-images.sh提取rancher-images.tar.gz文件中的镜像，根据文件rancher-images.txt中的镜像列表对提取的镜像文件重新打 tag 并推送到私有镜像库中。

    ```
    # Chang to images file direcotry
    cd /root/rancher-images-2.10.2

    # Login to Helix Harbor Server
    docker login helix-harbor.bmc.local -u admin -p bmcAdm1n
    
    # Load Rancher images to Harbor Server
    nohup ./rancher-load-images.sh --images rancher-images.tar.gz  --registry helix-harbor.bmc.local > nohup.out &
    tail -f nohup.out
    ```
## 6 Kubernetes集群安装
### 6.1 Rancher容器安装

* 在helix-k8s-master服务器安装容器化的Rancher服务器


    ```
    #  Login to Harbor Server
    docker login helix-harbor.bmc.local -u admin -p bmcAdm1n
    
    # Install Rancher docker version
    docker run -d --privileged --name rancher --restart=unless-stopped -p 80:80 -p 443:443 -v /opt/rancher:/var/lib/rancher -e CATTLE_SYSTEM_DEFAULT_REGISTRY=helix-harbor.bmc.local helix-harbor.bmc.local/rancher/rancher:v2.10.2
    
    ```

* Fix k8s bug in Rancher container

    
    ```
    # There is a bug in the k3s, below is how to permanent fix it
    # kernel modules load at startup
    echo "ip_tables" | sudo tee /etc/modules-load.d/iptables.conf
    echo "iptable_filter" | sudo tee -a /etc/modules-load.d/iptables.conf

    # Reload systemd modules and reboot
    sudo systemctl restart systemd-modules-load
    sudo reboot

    # Verify the modules are loaded after reboot
    lsmod | grep ip
    ```

* Find the Rancher Console password
    ```
    docker logs rancher 2>&1 | grep "Bootstrap Password:"
    2025/02/26 04:59:02 [INFO] Bootstrap Password: 2ndg88pslbtg29xlntvqm9hwm5ggp6w8tbvmp6bxrc8wf9g8nqh7gt
    ```

* 登录Rancher console   

![604240015266d6b532fc55283c183125.png](en-resource://database/639:1)


* 设置新密码

![f4add5a9a2fb7e32b536636611b92ab1.png](en-resource://database/641:1)


### 6.2 创建集群

* 登录Rancher控制台，可以看到默认只有一个local集群，我们需要为helix的安装创建一个集群
![fa20bd98b67bb4c44b865f87cc62c244.png](en-resource://database/663:1)

* 选择RKE1，创建Custom集群
![e8ec173f199973b56c992af11faf51dc.png](en-resource://database/665:1)

* 设置集群名称为helix-compact，其余选项默认

![3be6398f2414494ff21d993f9cae20ab.png](en-resource://database/667:1)

* 拷贝添加worker节点的脚本

![a3e9af8dd1977862e9f8d4beb8a1e91a.png](en-resource://database/669:1)

* 在helix-k8s-worker01至helix-k8s-worker04服务器上粘贴并运行脚本

```
sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run  helix-harbor.bmc.local/rancher/rancher-agent:v2.10.2 --server https://192.168.1.200 --token rv6vjhfqpc9czznz7j7qt4twz7d5wjlksqjw9cbl9v96fkdxpjdz7b --ca-checksum 4a158b1469cba97e2b7d19120e449133a46edb5d7715ccb629618df27d2a073d --worker

```

* 拷贝master(etcd & Control Plance)安装脚本

![8e9249128319f17a63a610abeecdd3ee.png](en-resource://database/671:1)

* 在helix-k8s-master服务器上粘贴并执行安装脚本
```
sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run  helix-harbor.bmc.local/rancher/rancher-agent:v2.10.2 --server https://192.168.1.200 --token rv6vjhfqpc9czznz7j7qt4twz7d5wjlksqjw9cbl9v96fkdxpjdz7b --ca-checksum 4a158b1469cba97e2b7d19120e449133a46edb5d7715ccb629618df27d2a073d --etcd --controlplane
```

* 等待所有节点全部加入集群，k8s集群创建完成
![ea2b09f0d97313a9add90ad1f8f97ff8.png](en-resource://database/673:1)

* 如果集群安装报错缺少某个image，可能是rancher-images.txt文件中缺少了一些镜像，需要补充到本地镜像库即可

    ```
    # 比如报错缺少hyperkube:v1.31.5-rancher1，在helix-harbor服务器上执行
    docker pull rancher/hyperkube:v1.31.5-rancher1
    docker tag rancher/hyperkube:v1.31.5-rancher1 helix-harbor.bmc.local/rancher/hyperkube:v1.31.5-rancher1
    docker push helix-harbor.bmc.local/rancher/hyperkube:v1.31.5-rancher1
    ```


### 6.3 设置k8s集群token时效
Rancher管理的K8s集群token的默认时效都很短，会带来k8s的监控失效和Helix的安装pipeline报错等问题，建议修改为永不失效
![cd462d4682b27f29756427692382865c.png](en-resource://database/675:1)
![2f2a4ccc11a5b2ef8d0f3e08c911f46c.png](en-resource://database/677:1)


### 6.4 安装kubernetes客户端工具
helix-svc将作为Helix安装工作站，需要在此服务器安装客户端工具
#### 6.4.1 配置kubernetes配置文件

* 拷贝配置文件
![dd7f955034f6c5160d489e45a9b5235d.png](en-resource://database/685:1)

* 写入配置文件
    ```
    mkdir -p ~/.kube
    cd ~/.kube
    vi config

    # 粘贴剪切板内容并保存
    ```

#### 6.4.1 安装kubectl

* 在helix-svc服务器安装跟kubernetes版本一致的kubectl

    ```
    curl -o /usr/local/bin/kubectl -LO https://storage.googleapis.com/kubernetes-release/release/v1.31.0/bin/linux/amd64/kubectl && chmod +x /usr/local/bin/kubectl

    #Verifiy kubectl
    kubectl version
    kubectl get nodes
    kubectl top nodes
    ```

* 创建ITOM使用的命名空间helixade, ITSM使用的命名空间helixis
    ```
    kubectl create ns helixade
    kubectl create ns helixis
    ```

#### 6.4.2 安装helm

* 在helix-svc服务器安装最新版本的helm

    ```
    #Deploy helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    ```

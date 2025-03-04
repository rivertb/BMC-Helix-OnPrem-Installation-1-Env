# BMC HelixOM ITOM & ITSM OnPrem Installation Step by Step 2 - ITOM

- [BMC HelixOM ITOM & ITSM OnPrem Installation Step by Step 2 - ITOM](#bmc-helixom-itom-&-itsm-onprem-installation-step-by-step-2---itom)
  - [1 Pre-installation preparation](#1-pre-installation-preparation)
  - [2 Deploy Helix Dashboard](#2-deploy-helix-dashboard)
  - [3 Deploy Helix Discovery](#3-deploy-helix-discovery)
  - [4 Install other ITOM components)](#4-install-other-itom-components)
  - [5 Import PATROL KM to Helix Monitor repository)](#5-import-patrol-km-to-helix-monitor-repository)
  
## 1 Pre-installation preparation

The installation environment of this project depends on [BMC-Helix-OnPrem-Installation-1-Env](https://github.com/rivertb/BMC-Helix-OnPrem-Installation-1-Env). Please complete it before proceeding.

### 1.1 Download Helix Deployment Manager
The Helix ITOM installation process is completed by helix deployment manager.

* Login to [EPD](https://webepd.bmc.com/edownloads/ddl/cv/LP/442432/537020?fltk_=VTH1iwPCxfU%3D)，Download the latest version of helix-on-prem-deployment-manager-<release_version>.sh file，eg. helix-on-prem-deployment-manager-25.1.00-45.sh

![EPD Helix Deployment Manager](./diagram/epd-helix-deployment-manager.png)

* Upload helix-on-prem-deployment-manager-25.1.00-45.sh to the helix-svc server

* Add executable permissions to shell files

```
chmod a+x helix-on-prem-deployment-manager-25.1.00-45.sh
```

* Execute the self-extracting file and create the directory helix-on-prem-deployment-manager
```
./helix-on-prem-deployment-manager-25.1.00-45.sh
```

* Modify the directory name to facilitate the distinction between versions
```
mv helix-on-prem-deployment-manager helix-on-prem-deployment-manager-25.1
```

### 1.2 Set the config files
#### 1.2.1 infra.config

* Edit the ./config/infra.config file and modify the parameter values as shown in the following table:

| Line No. | Parameter | Value | Description |
| --- | --- | --- | --- |
| 9 | IMAGE_REGISTRY_HOST | helix-harbor.bmc.local |  |
| 10 | IMAGE_REGISTRY_USERNAME | admin | The password is set in the secrets file |
| 20 | NAMESPACE | helixade | Namespace for itom installation |
| 21 | LB_HOST | lb.bmc.local | |
| 22 | LB_PORT | 443 | |
| 23 | TMS_LB_HOST | tms.bmc.local | |
| 24 | DOMAIN | bmc.local | |
| 26 | MINIO_LB_HOST | minio.bmc.local |  |
| 27 | MINIO_API_LB_HOST | minio-api.bmc.local |  |
| 28 | MINIO_API_LB_HOST | minio-api.bmc.local |  |
| 30 | TENANT_ENVIRONMENT | poc |  |
| 46 | TENANT_NAME | adelab |  |
| 47 | TENANT_EMAIL | adelab@bmc.local |  |
| 48 | TENANT_FIRST_NAME | adelab |  |
| 49 | TENANT_LAST_NAME | helix |  |
| 51 | TENANT_TYPE | private | |
| 53 | TENANT_COUNTRY | "China" |  |
| 68 | SMTP_HOST | helix-svc.bmc.local |  |
| 69 | SMTP_PORT | 25 |  |
| 70 | SMTP_USERNAME | dummy |  |
| 71 | SMTP_FROM_EMAIL | helix@bmc.local |  |
| 73 | SMTP_TLS | false |  |
| 74 | SMTP_AUTH_DASHBOARD | true |  |
| 75 | SMTP_AUTH  | PLAIN |  |
| 76 | OPS_GROUP_EMAIL | ops@bmc.local |  |
| 77 | APPROVAL_GROUP_EMAIL | approval@bmc.local |  |
| 91 | PG_STORAGE_CLASS | nfs-storage |  |
| 92 | VMSTORAGE_STORAGE_CLASS | nfs-storage |  |
| 93 | VMAGGSTORAGE_STORAGE_CLASS | nfs-storage |  |
| 94 | ES_MASTER_STORAGE_CLASS | nfs-storage |  |
| 95 | ES_DATA_STORAGE_CLASS | nfs-storage |  |
| 96 | MINIO_STORAGE_CLASS | nfs-storage |  |
| 97 | EFS_STORAGE_CLASS | nfs-storage |  |
| 98 | REDIS_HA_GLOBAL_STORAGECLASS | nfs-storage |  |
| 99 | KAFKA_STORAGECLASS | nfs-storage |  |  
| 100 | REDIS_CLUSTER_STORAGE_CLASS | nfs-storage |  |
| 101 | AIOPS_STORAGE_CLASS | nfs-storage |  |
| 105 | OPT_STORAGE_CLASS | nfs-storage |  |
| 111 | CUSTOM_CA_SIGNED_CERT_IN_USE | true |  |
| 126 | SMART_SYSTEM_USERNAME | system | Helix Discovery password is set in the secrets file |
| 130 | INGRESS_CLASS | nginx |  |
| 135 | INGRESS_TLS_SECRET_NAME | my-tls-secret |  |
| 140 | HELM_BIN | /usr/local/bin/helm |  |
| 141 | KUBECTL_BIN | /usr/local/bin/kubectl |  |
| 189 | LOGIN_ID | hannah_admin | Helix Dashboard admin user |


#### 1.2.2 deployment.config
Edit the ./config/deployment.config configuration file and modify the following parameters:

| Line No. | Parameter | Value | Description |
| --- | --- | --- | --- |
| 7 | DEPLOYMENT_SIZE | compact | For PoC only |


#### 1.2.3 secrets.txt

* Edit the ./common/certs/secrets.txt file and modify the following content:

| Line No. | Parameter | Value | Description |
| --- | --- | --- | --- |
| 2 | IMAGE_REGISTRY_PASSWORD | bmcAdm1n | Harbor console admin password |
| 3 | SMTP_PASSWORD | dummy | MailHog mailbox does not require a password |
| 4 | SMART_SYSTEM_PASSWORD | bmcAdm1n | All passwords are set to bmcAdm1n for easy memorization |
| 9 | ES_JKS_PASSWORD | bmcAdm1n | |

* The secrets.txt file will be deleted when you run the Helix installer for the first time. It is recommended to make a backup.
```
cp secrets.txt secrets.txt.bak
```
#### 1.2.4 custom_cacert.pem
```
cp /root/opensslfull_chain.crt /root/helix-on-prem-deployment-manager-25.1/commons/../commons/certs/custom_cacert.pem
```
### 1.4 NFS and StorageClass

#### 1.4.1 Setup NFS Server
* Install NFS server software in helix-svc
```
dnf install nfs-utils -y
```

* Create NFS Storage Directory
```
mkdir -p /opt/datastore/helixade
chown -R nobody:nobody /opt/datastore/helixade
chmod -R 777 /opt/datastore/helixade
```

* Export NFS directory
```
echo "/opt/datastore/helixade  192.168.1.0/24(rw,sync,root_squash,no_subtree_check,no_wdelay)" > /etc/exports
exportfs -rv
```

* Opening the firewall for NFS
```
firewall-cmd --zone=internal --add-service mountd --permanent
firewall-cmd --zone=internal --add-service rpc-bind --permanent
firewall-cmd --zone=internal --add-service nfs --permanent
firewall-cmd --reload
```

* Enable and start NFS service
```
systemctl enable nfs-server rpcbind
systemctl start nfs-server rpcbind nfs-mountd
```

* Verify NFS Directory
```
showmount -e
```

#### 1.4.2 Create StorageClass on NFS

* For the creation of NFS Storage Class, please refer to the document[nfs-subdir-external-provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner)

```
#Create namespace for storageclass
kubectl create namespace infra
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=192.168.1.1 --set nfs.path=/opt/datastore/helixade --set storageClass.name=nfs-storage -n infra
```

* Verify the storageclass
```
kubectl -n infra get pod
kubectl get sc
```
### 1.5 Install HAProxy as Load Balancer

* Install HAProxy
```
dnf install haproxy -y
```

* Copy config file
```
\cp ~/helix-metal-install/haproxy.cfg /etc/haproxy/haproxy.cfg
```

* Enable and start HAProxy
```
systemctl enable haproxy
systemctl start haproxy
systemctl status haproxy
```

* Open firewall for HAProxy service
```
firewall-cmd --add-service=http --zone=internal --permanent # web services hosted on worker nodes
firewall-cmd --add-service=http --zone=external --permanent # web services hosted on worker nodes
firewall-cmd --add-service=https --zone=internal --permanent # web services hosted on worker nodes
firewall-cmd --add-service=https --zone=external --permanent # web services hosted on worker nodes
firewall-cmd --add-port=9000/tcp --zone=internal --permanent # HAProxy Stats
firewall-cmd --add-port=9000/tcp --zone=external --permanent # HAProxy Stats
firewall-cmd --reload
```

* Verify HAProxy, browser access https:192.168.1.1:9000/stats
![Helix Status 1](./diagram/haproxy-status-1.png)

You can see that the queue status is not UP because it has not been configured yet, which is normal.

### 1.6 MailHog as eMail Server

* Run the containerized version of the mailhog mail server to provide mail services for the Helix installation
```
#Add helm repo
helm repo add codecentric https://codecentric.github.io/helm-charts
helm repo update

#Install MailHog helm chart
helm install mailhog codecentric/mailhog -n email --create-namespace --set service.type=NodePort

#Verify that the email service was created successfully（STATUS=Running）
kubectl -n email get pod
```

* Query service port information
```
node_ip=$(kubectl get nodes -o=jsonpath='{.items[0].status.addresses[0].address}')
web_port=$(kubectl --namespace email get svc mailhog -o=jsonpath="{.spec.ports[?(@.name=='http')].nodePort}")
smtp_port=$(kubectl --namespace email get svc mailhog -o=jsonpath="{.spec.ports[?(@.name=='tcp-smtp')].nodePort}")

echo "MailHog Web UI at http://$node_ip:$web_port"
echo "MailHog SMTP port at $node_ip:$smtp_port"


MailHog Web UI at http://192.168.1.200:31532
MailHog SMTP port at 192.168.1.200:32354
```
The above output shows that the mail console is http://192.168.1.200:31532 and the sending interface is 192.168.1.200:32354

* Modify the HAProxy configuration file and adjust the mailhog port to the SMTP port output value
```
vi /etc/haproxy/haproxy.cfg
```
backend mailhog
  mode tcp
    balance     leastconn
    server helix-k8s-worker01 192.168.1.200:**32354** check

* Restart the HAProxy service and enable the new configuration file
```
systemctl restart haproxy
```

* Check the HAProxy console to verify that mailhog is running
![Helix Status 2](./diagram/haproxy-status-2.png)

* Open firewall ports for MailHog
```
firewall-cmd --add-port=25/tcp --zone=internal --permanent
firewall-cmd --add-port=31532/tcp --zone=internal --permanent
firewall-cmd --add-port=32354/tcp --zone=internal --permanent
firewall-cmd --reload
```

* Send test mail
```
dnf install epel-release -y 
dnf install swaks -y
# send email using swaks
swaks -f host-test@me -t local@me -s $node_ip -p $smtp_port --body "this is a test" --header "Subject: host validation via port: $smtp_port"
swaks -f host-test@me -t local@me -s 192.168.1.1 -p 25 --body "this is a test" --header "Subject: host validation via port: 25"
```
* Log in to the email console https://192.168.1.200:31532 through the browser, and you can see two emails, one sent to the original port and the other to port 25 of the HAProxy proxy
![MailHog Test eMails](./diagram/mailhog-test-emails.png)

### 1.7 Ingress
Helix supports two types of Kubernetes reverse proxy and load balancing starting from 24.3

* NGINX Open Source Ingress Controller
* F5 NGINX Plus Ingress Controller

This document uses the first method. For detailed introduction and installation steps, please refer to the document[IngressController](https://docs.bmc.com/xwiki/bin/view/IT-Operations-Management/On-Premises-Deployment/BMC-Helix-IT-Operations-Management-Deployment/itomdeploy251/Deploying/Preparing-for-deployment/Deploying-and-configuring-the-NGINX-Open-Source-Ingress-Controller/)

* Delete the old ingress-nginx namespace

```
kubectl delete ds -n ingress-nginx ingress-nginx-controller
kubectl -n ingress-nginx delete svc ingress-nginx-controller-admission
kubectl delete clusterrole ingress-nginxkubectl delete ClusterRoleBinding ingress-nginx
kubectl delete IngressClass nginx
kubectl delete ValidatingWebhookConfiguration ingress-nginx-admission
kubectl delete ns ingress-nginx
```

* Download the corresponding kubernetes version [NGINX Ingress Controller](https://docs.bmc.com/xwiki/bin/view/IT-Operations-Management/On-Premises-Deployment/BMC-Helix-IT-Operations-Management-Deployment/itomdeploy251/Planning/System-requirements/) 

```
dnf install wget -y
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.4/deploy/static/provider/cloud/deploy.yaml
```

* Edit and modify the downloaded deploy.yaml file

    Change the kind field of the ingress-nginx-controller from **Deployment** to **DaemonSet**
    Under kind: **Daemonset**, change the spec.**strategy** field to spec.**updateStrategy**
    Under kind: **Daemonset**, locate **securityContext**, and then set the value of the flag **allowPrivilegeEscalation** as **true**

*  Deploy deploy.yaml
```
kubectl create ns ingress-nginx
kubectl apply -f deploy.yaml
```

* Wait for Ingress Nginx to be created
```
kubectl -n ingress-nginx get all

NAME                                       READY   STATUS      RESTARTS   AGE
pod/ingress-nginx-admission-create-4fdv9   0/1     Completed   0          111s
pod/ingress-nginx-admission-patch-tdxjj    0/1     Completed   0          111s
pod/ingress-nginx-controller-dwxv7         1/1     Running     0          111s
pod/ingress-nginx-controller-kw2qt         1/1     Running     0          111s
pod/ingress-nginx-controller-llgpq         1/1     Running     0          111s
pod/ingress-nginx-controller-sbwrb         1/1     Running     0          111s

NAME                                         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/ingress-nginx-controller             LoadBalancer   10.43.144.239   <pending>     80:30468/TCP,443:31019/TCP   112s
service/ingress-nginx-controller-admission   ClusterIP      10.43.137.171   <none>        443/TCP                      112s

NAME                                      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/ingress-nginx-controller   4         4         4       4            4           kubernetes.io/os=linux   111s

NAME                                       STATUS     COMPLETIONS   DURATION   AGE
job.batch/ingress-nginx-admission-create   Complete   1/1           35s        112s
job.batch/ingress-nginx-admission-patch    Complete   1/1           35s        112s
```

* Create secret my-tls-secret
```
kubectl create secret tls my-tls-secret --cert=/root/openssl/bmc.local.crt --key=/root/openssl/bmc.local.key -n ingress-nginx
```

* Modify daemonset to point the default SSL certificate to my-tls-secret
```
kubectl edit daemonset ingress-nginx-controller -n ingress-nginx
```
The modified configuration is as follows:
![my-tls-secret-setting](./diagram/my-tls-secret-setting.png)

* Modify ingress-nginx-controller
```
kubectl edit cm ingress-nginx-controller -n ingress-nginx
```

* Add the following content under data:

```
  enable-underscores-in-headers: "true"
  proxy-body-size: 250m
  server-name-hash-bucket-size: "1024"
  ssl-redirect: "false"
  use-forwarded-headers: "true"
  worker-processes: "40"
  allow-snippet-annotations: "true"
```

* After modification, the figure is as follows:

![Ingress Nginx Controller](./diagram/ingress-nginx-controller-setting.png)

* Restart daemonset
```
kubectl -n ingress-nginx rollout restart ds ingress-nginx-controller
```

* Wait for the pod restart to complete
```
kubectl -n ingress-nginx get pod
```

* Verify that the new Ingress Controller version is used
```
kubectl -n ingress-nginx describe <pod name> | grep -i image
```
The verification results are as follows:
```
[root@helix-svc openssl]# kubectl -n ingress-nginx get pod
NAME                                   READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-4fdv9   0/1     Completed   0          46m
ingress-nginx-admission-patch-tdxjj    0/1     Completed   0          46m
ingress-nginx-controller-2q2vg         1/1     Running     0          13s
ingress-nginx-controller-8h92b         1/1     Running     0          98s
ingress-nginx-controller-wrmq5         1/1     Running     0          66s
ingress-nginx-controller-zt5wg         1/1     Running     0          35s
[root@helix-svc openssl]# kubectl -n ingress-nginx describe ingress-nginx-controller-2q2vg | grep -i image
error: the server doesn't have a resource type "ingress-nginx-controller-2q2vg"
[root@helix-svc openssl]# kubectl -n ingress-nginx describe pod ingress-nginx-controller-2q2vg | grep -i image
    Image:           registry.k8s.io/ingress-nginx/controller:v1.11.4@sha256:981a97d78bee3109c0b149946c07989f8f1478a9265031d2d23dea839ba05b52
    Image ID:        docker-pullable://registry.k8s.io/ingress-nginx/controller@sha256:981a97d78bee3109c0b149946c07989f8f1478a9265031d2d23dea839ba05b52
  Normal  Pulled     50s   kubelet                   Container image "registry.k8s.io/ingress-nginx/controller:v1.11.4@sha256:981a97d78bee3109c0b149946c07989f8f1478a9265031d2d23dea839ba05b52" already present on machine
```
* Delete the Validating Webhook Configuration, otherwise it may prevent the release of the ingress object
```
kubectl delete job ingress-nginx-admission-create ingress-nginx-admission-patch -n ingress-nginx --ignore-not-found=true
kubectl -n ingress-nginx delete -A ValidatingWebhookConfiguration ingress-nginx-admission
```
* Update the service ingress-nginx-controller to point the external IP to the address of the service on the balancer
```
kubectl patch service/ingress-nginx-controller -n ingress-nginx -p '{"spec":{"externalIPs":["192.168.1.1"]}}'
```

* Verify that ingress-nginx-controller has been successfully changed
```
kubectl -n ingress-nginx get service

NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.43.144.239   192.168.1.1   80:30468/TCP,443:31019/TCP   55m
ingress-nginx-controller-admission   ClusterIP      10.43.137.171   <none>        443/TCP                      55m
```

* Change the HAProxy configuration based on the returned 443 mapping port number (31019 in this example).
```
vi /etc/haproxy/haproxy.cfg
```

* Screenshot of the effect after the change

![HAProxy cfg](./diagram/haproxy-cfg.png)

* Restart the HAProxy service to enable the new configuration
```
systemctl restart haproxy
```

* Log in to the HAProxy console with a browser and verify the result
![HAProxy Status 3](./diagram/haproxy-status-3.png)


## 2 Deploy Helix Dashboard

### 2.1 Run Helix Deployment Manager
* Execute the Helix deployment manager on the helix-svc server

```
cd /root//root/helix-on-prem-deployment-manager-25.1
./deployment-manager.sh
```

* Wait for the installer to complete:
![Completed Helix Installation](./diagram/completed-helix-on-prem-installation.png)

### 2.2 Import the CA certificate into the Windows server where the browser is located

* Check Helix Portal account activation email
![Activate Portal Account](./diagram/activate-portal-account-eamil.png)

* Click the "Sign in to activate your account" link in the email, and the browser will pop up the Helix Portal login page, and the error "net::ERR_CERT_AUTHORITY_INVALID" will be reported. This is normal. Because the Https signing CA used by Helix is customized, the CA certificate needs to be imported into the trust store.
![NET::ERR-CERT-AUTHORITY-INVALID](./diagram/net-err-cert-authority-invalid.png)


* Copy the /root/openssl/HelixCA.crt file on the helix-svc host to the current Windows host and double-click it.

![Install Certification in Chrome](./diagram/install-certification-in-chrome.png)


* Enter the Certificate Import Wizard and select Local Machine

![Store Location Local Machine](./diagram/store-location-local-machine.png)

* Select Trusted Root Certificate

![Trusted Root Certifate](./diagram/trusted-root-certification-authorities.png)

* Refresh the browser login interface again and set the password for the default administrator account hannah_admin
![Change hannah-admin Password](./diagram/hannah_admin-password.png)

* Complete the Helix Portal installation
![Helix Portal](./diagram/helix-portal.png)

## 3 Deploy Helix Discovery
BMC Helix Discovery is a basic component of Helix ITOM. You must successfully install and configure Helix Discovery before installing other Helix ITOM components. Helix Discovery is delivered as a virtual machine OVF file and runs as a VM.

### 3.1 Helix Discovery virtual machine import and configuration

* In the virtual machine console, create a virtual machine and choose to create it from an OVF or OVA file.

![Import Helix Discovery VM](./diagram/import-discovery-ovf.png)

* Define the hostname, select the OVF file, and complete the import process

![Select Helix Discovery OVF file](./diagram/select-helix-discovery-ovf.png)

* Login to the helix-discovery server, use the built-in user tideway/tidewayuser, and change the password to bmcAdm1n%

![Login Helix Discovery with tideway](./diagram/login-helix-discovery-with-tideway.png)

* Switch to the root user, the default password is tideway. When you login for the first time, you need to change the password to bmcAdm1n$

![Helix Discovery switch to root](./diagram/helix-discovery-switch-to-root.png)

* Setup time zone
```
#set timezone
timedatectl set-timezone Asia/Shanghai 

#check result
timedatectl
```

* Switch to netadmin user and enter the network management shell
![Helix Discovery switch to netadmin](./diagram/helix-discovery-switch-to-netadmin.png)

* Select option G first, then option H, configure the host name to helix-discovery, option C to submit, and option Q to return to the main menu

![Helix Discovery set hostname](./diagram/helix-discovery-set-hostname.png)


* Select option I, option 1, reconfigure the network card, and set:
DHCP: n
 IPv4 Address: 192.168.1.210
 Netmask: 255.255.255.0
 IPv4 Gateway: 192.168.1.1
 IPv6: n
 Enable on boot: y
Select option C to submit, y to confirm the changes, then select option Q to return to the main menu, and finally select option R to restart the virtual machine and complete the virtual machine configuration.

![Helix Discovery set network](./diagram/helix-discovery-set-network.png)

### 3.2 Config Helix Discovery console
Use a browser to login to the Helix Discovery console at https://192.168.1.210, use the built-in login username system, and the default password system
![Helix Discovery login](./diagram/helix-discovery-login.png)

* When logging in for the first time, you need to change the system user password, for example, to bmcAdm1n#
![Helix Discovery set password for system](./diagram/helix-discovery-set-password-for-system.png)


* To facilitate testing, it is recommended to modify the security policy and cancel the password restriction. Administration menu -> Security Policy view
Check out below options:
Must contain uppercase characters
Must contain lowercase characters
Must contain numeric characters
Must contain special characters
Must not contain sequences
Must not match a common dictionary password

![Helix Discovery change Security Policy](./diagram/helix-discovery-change-security-policy.png)

* For easier memorization, change the password to bmcAdm1n, which is consistent with the SMART_SYSTEM_PASSWORD value in secrets.txt.
![Helix Discovery set system password to bmcAdm1n](./diagram/helix-discovery-set-password-for-system2.png)

* Enter the menu Administration->Appliance Configuration->Name Resolution view to set DNS
Search Domain: bmc.local
Name Servers: 192.168.1.1

![Helix Discovery set system Name Resolution](./diagram/helix-discovery-set-name-resolution.png)

* Enter the menu Administration->Time Sync view NTP
![Helix Discovery set Time Sync](./diagram/helix-discovery-set-time-sync.png)

* Upload the Helix CA certificate as a trusted certificate
Administration->Single Sign On view，Upload CA Bundle
![Helix Discovery upload Trustred CA](./diagram/helix-discovery-upload-trusted-ca.png)


## 4 Install other ITOM components
Helix ITOM components include the following list. Select the component to install, change the corresponding parameter value to yes in the deployment.config file, and re-execute /deployment-manager.sh

| Line no. | Parameter | Helix ITOM Component |
| --- | --- | --- |
| 42 | AIOPS_SERVICES | Helix Service Monitoring |
| 45 | MONITOR | Helix Operations Management |
| 48 | LOG_ANALYTICS_SERVICES | Helix Log Analytics |
| 51 | INTELLIGENT_AUTOMATION | Helix Intelligent Automation |
| 54 | OPTIMIZE | Helix Continuous Optimization |
| 62 | AUTOANAMOLY | Helix Operations Management & Helix Service Monitoring |

## 5 Import PATROL KM to Helix Monitor repository
```
cp -R ~/BMC-Helix-OnPrem-Installation-1-Env/BHOM-KMImport /root
cd /root/HOM-KMImport
chmod a+x *.sh
import-signle-KM-to-repository.sh <KM> <TenantID> <NameSpace>
```


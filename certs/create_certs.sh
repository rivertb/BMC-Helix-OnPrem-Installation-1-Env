#!/bin/bash

# 证书参数
ORG="BMCSoftware"
CA_KEY="HelixCA.key"
CA_CRT="HelixCA.crt"
CA_SUBJECT="/CN=BMC-CA/O=${ORG}/C=CN"

SERVER_NAME="bmc.local"
SERVER_KEY="${SERVER_NAME}.key"
SERVER_CSR="${SERVER_NAME}.csr"
SERVER_CRT="${SERVER_NAME}.crt"
SERVER_CONF="${SERVER_NAME}.cnf"
SERVER_SUBJECT="/CN=*.${SERVER_NAME}/O=${ORG}/C=CN"


DAYS=3650  # 证书有效期 3650 天

# 定义 SAN (多个子域名)
SAN_DNS="DNS:*.bmc.local,DNS:helix-harbor.bmc.local,DNS:helix-discovery.bmc.local,DNS:helix-bhii.bmc.local"

# 生成 CA 私钥
echo "👉 生成 CA 私钥..."
openssl genrsa -out $CA_KEY 4096

# 生成 CA 证书
echo "👉 生成 CA 证书..."
openssl req -x509 -new -nodes -key $CA_KEY -sha256 -days $DAYS -out $CA_CRT -subj "$CA_SUBJECT"

# 生成服务器私钥
echo "👉 生成服务器私钥..."
openssl genrsa -out $SERVER_KEY 2048

# 生成 OpenSSL 配置文件 (支持 SAN)
echo "👉 生成 OpenSSL 配置文件..."
cat > $SERVER_CONF <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
[req_distinguished_name]
[v3_req]
subjectAltName = $SAN_DNS
EOF

# 生成服务器 CSR (证书签名请求)
echo "👉 生成服务器 CSR..."
openssl req -new -key $SERVER_KEY -out $SERVER_CSR -subj "$SERVER_SUBJECT" -config $SERVER_CONF

# 使用 CA 签发服务器证书
echo "👉 使用 CA 签发服务器证书..."
openssl x509 -req -in $SERVER_CSR -CA $CA_CRT -CAkey $CA_KEY -CAcreateserial -out $SERVER_CRT -days $DAYS -sha256 -extfile $SERVER_CONF -extensions v3_req

# 显示证书信息
echo "👉 证书信息："
openssl x509 -in $SERVER_CRT -noout -text

echo "✅ 证书创建完成！"
echo "📌 CA 证书: $CA_CRT"
echo "📌 CA 私钥: $CA_KEY"
echo "📌 服务器私钥: $SERVER_KEY"
echo "📌 服务器 CSR: $SERVER_CSR"
echo "📌 服务器证书: $SERVER_CRT"


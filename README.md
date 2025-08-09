# GENOM SCRIPT VPS INSTALL

## 1. INSTALL

```
 apt update && apt upgrade -y && wget -q https://github.com/makruf1954/genom/raw/refs/heads/main/install && chmod +x install  && ./install
```

## 2. UPDATE 

```
cd root
rm update.sh
wget https://github.com/makruf1954/genom/raw/refs/heads/main/menu/update.sh && chmod +x update.sh && ./update.sh
```

#### ALTERNATIF CERT :


```
DOMAIN="ISI SUBDOMAIN"
EMAIL="ISI EMAIL SUBDOMAIN"
/root/.acme.sh/acme.sh --set-default-ca --server zerossl && \
/root/.acme.sh/acme.sh --register-account -m "$EMAIL" --server zerossl && \
/root/.acme.sh/acme.sh --issue --standalone -d "$DOMAIN" -k ec-256 && \
/root/.acme.sh/acme.sh --installcert -d "$DOMAIN" \
  --fullchainpath /etc/xray/xray.crt \
  --keypath /etc/xray/xray.key \
  --ecc && \
chmod 600 /etc/xray/xray.key && \
systemctl restart nginx && \
systemctl restart xray

```

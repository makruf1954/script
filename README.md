## script vps 



# First, make sure that you have root access to the VPS.
# What is also needed is permission on my repo, and also your domain which is already connected to the VPS, you can use Cloudflare or others to connect it

## How to Root Access
```
wget -qO- -O aksesroot.sh https://raw.githubusercontent.com/makruf1954/script/refs/heads/main/root.sh && bash root.sh
```

## how to install 

```
 apt update && apt upgrade -y && wget -q https://github.com/makruf1954/script/raw/refs/heads/main/install && chmod +x install  && ./install
```

## How to Update

```
cd root
rm update.sh
wget https://github.com/makruf1954/script/raw/refs/heads/main/menu/update.sh && chmod +x update.sh && ./update.sh
```

## if your ssl fails the certification will appear :

```
DOMAIN="your domain"
EMAIL="email sub domain"
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

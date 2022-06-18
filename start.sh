#!/bin/sh

# configs
AUUID=9db81eb5-a57f-49d5-8cd5-3edef7369158
ParameterSSENCYPT=chacha20-ietf-poly1305
CADDYIndexPage=https://github.com/AYJCSGM/mikutap/archive/master.zip
CONFIGCADDY=https://raw.githubusercontent.com/xxjs890/r2hgreger/master/etc/Caddyfile
CONFIGv2ray=https://raw.githubusercontent.com/xxjs890/r2hgreger/master/etc/v2ray.json
StoreFiles=https://raw.githubusercontent.com/xxjs890/r2hgreger/master/etc/StoreFiles

#PORT=4433
mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile
wget -qO- $CONFIGv2ray | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/v2ray.json

# storefiles
mkdir -p /usr/share/caddy/$AUUID && wget -O /usr/share/caddy/$AUUID/StoreFiles $StoreFiles
wget -P /usr/share/caddy/$AUUID -i /usr/share/caddy/$AUUID/StoreFiles

for file in $(ls /usr/share/caddy/$AUUID); do
    [[ "$file" != "StoreFiles" ]] && echo \<a href=\""$file"\" download\>$file\<\/a\>\<br\> >>/usr/share/caddy/$AUUID/ClickToDownloadStoreFiles.html
done

# start
tor &

/v2ray -config /v2ray.json &

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile

---
title: "Let’s Encrypt の証明書を発行するコマンドが覚えられないので Makefile でラップする"
date: 2020-02-26
categories:
- 覚書
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/letsencrypt.png.webp
summary: "Let’s Encrypt の証明書を発行するコマンドが覚えられない！"
---

Let’s Encrypt の証明書を発行するコマンドが覚えられない！
毎回ググるなり history 見るなりして必死に SSL 証明書の発行をしている。

それでもだんだんと面倒くさくなって Makefile でラップした。

```Make
EMAIL_ADDRESS = hogehoge@fuga.jp
DOMAIN_NAME = hoge.fuga.jp

.PHONY: create

create:
       certbot-auto certonly --webroot -w /var/www/html -d $(DOMAIN_NAME) --email $(EMAIL_ADDRESS) --agree-tos -n
```

nginx で /var/www/html/.well-known 以下に証明書を発行したいドメインでアクセスできるようにしてから

```bash
$ make DOMAIN_NAME=hege.fuga.jp
```

と叩くだけでいちいちコマンドを探す旅に出ずとも証明書の発行ができるようになった。
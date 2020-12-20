---
title: "EC2 にたてた nginx から AWS S3 に保存されているファイルへリバースプロキシする"
date: 2020-07-31
categories:
- AWS
- nginx
- 覚書
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/nginx.png.webp
draft: false
summary: "S3 に保存されているファイルへアクセスする際、独自ドメインを使いたかったり、 Basic 認証をかけたかったりと色々思ったりする。"
---

S3 に保存されているファイルへアクセスする際、独自ドメインを使いたかったり、 Basic 認証をかけたかったりと色々思ったりする。

ただ、このために CloudFront をかませて Lambda@Edge で Basic 認証かけてってやっているとめんどくさいし余計なコストがかかったりするので、手っ取り早く nginx でリバースプロキシする。

```bash
server {
    listen       80 default_server;
    server_name  hogehoge.com;

    access_log   /var/log/nginx/access.log main;
    error_log    /var/log/nginx/error.log warn;

    add_header X-Frame-Options SAMEORIGIN;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-XSS-Protection "1; mode=block";

    if ($http_x_forwarded_proto = 'http') {
        return 301 https://$server_name$request_uri;
    }

    location ~ /(.*) {
        set $file $1;
        resolver              8.8.8.8;
        proxy_set_header      Authorization "";
        proxy_set_header      X-Frame-Options SAMEORIGIN;
        proxy_set_header      Content-Security-Policy "frame-ancestors 'self'";
        proxy_set_header      X-XSS-Protection "1; mode=block";
        proxy_pass            https://s3-us-west-2.amazonaws.com/bucket_name/$file;
    }
}
```

もし nginx 側から Basic 認証をかける場合、そのままプロキシすると Authorization ヘッダに Basic 認証ユーザの情報が入り S3 側で Access Denied される。

そのため、 `proxy_set_header Authorization "";` のように Authorization ヘッダを上書きする必要があるので注意。
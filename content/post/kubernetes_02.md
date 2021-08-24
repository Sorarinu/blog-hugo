---
title: "Kubernetes クラスタに Nginx の Pod をデプロイしてみる"
date: 2021-08-24T00:00:00+09:00
categories:
- Kubernetes
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/kubernetes.png.webp
draft: false
summary: "Kubernetes クラスタを運用するうえで割と作ることが多いであろう Nginx を自宅オンプレクラスタ上にデプロイしてみたのでご紹介してみる。"
---

Kubernetes クラスタを運用するうえで割と作ることが多いであろう Nginx を自宅オンプレクラスタ上にデプロイしてみたのでご紹介してみる。

# Deployment のマニフェストを用意する

まずは Pod が何台必要か、どのイメージを利用するかなどを記載したマニフェスト `nginx-deployment.yaml` を用意する。

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx-pod
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx-pod
    spec:
      containers:
        - name: nginx-container
          image: nginx:1.21.1-alpine
          ports:
          - containerPort: 80 
          volumeMounts:
            - name: nginx-conf
              mountPath: /etc/nginx
      volumes:
        - name: nginx-conf
          configMap:
            name: nginx-conf
            items:
              - key: nginx.conf
                path: nginx.conf
              - key: hoge.conf
                path: conf.d/hoge.conf
```

このマニフェストでは、 `nginx:1.12.1-alpine` イメージをもとにして `nginx-pod` という Pod を 3 台デプロイしている。

また、Pod 内の `/etc/nginx` に対して、後述する ConfigMap に記載された `nginx.conf`、`hoge.conf` など Nginx の設定ファイルをマウントしている。

# ConfigMap を定義したマニフェストを用意する

つぎに、Nginx の Pod 内でマウントするための設定ファイルを ConfigMap として定義した `nginx-configmap.yaml` を作成する。

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-conf
data:
  nginx.conf: |
    user nginx;
    worker_processes auto;
    
    error_log /var/log/nginx/error.log warn;
    pid /var/run/nginx.pid;
    
    worker_rlimit_nofile 163840;
    
    events {
        worker_connections 65535;
        multi_accept on;
        use epoll;
    }
    
    http {
        index  index.html index.htm index.php;
        default_type  application/octet-stream;
    
        add_header X-Frame-Options SAMEORIGIN;
    
        client_max_body_size 50M;
        client_body_buffer_size 64k;
    
        proxy_buffer_size 4k;
        proxy_buffers     64 4k;
        proxy_busy_buffers_size 8k;
        proxy_cache_path /var/cache/nginx/serv_cache levels=1:2 keys_zone=czone:64M max_size=1000m inactive=14d;
        proxy_cache_lock on;
        proxy_cache_lock_timeout 3s;
    
        proxy_ignore_headers Cache-Control Expires Set-Cookie;
    
        log_format  main  '$remote_addr - $remote_user [$time_local] '
                          '"$request" $status $body_bytes_sent '
                          '"$http_referer" "$http_user_agent" $upstream_cache_status $request_time';
    
        access_log  /var/log/nginx/access.log  main;
    
        limit_req_zone $binary_remote_addr zone=lrz:20m rate=30r/s;
    
        server_tokens   off;
    
        sendfile        on;
        tcp_nopush      on;
    
        keepalive_timeout 10;
    
        gzip  on;
        gzip_vary on;
        gzip_proxied any;
        gzip_types text/css text/xml application/javascript application/atom+xml application/rss+xml text/plain application/json;
        gzip_min_length 15k;
        gzip_comp_level 4;
    
        include /etc/nginx/conf.d/*.conf;
    }
  hoge.conf: |
    server {
        listen 80;
        server_name example.com;
        root /var/www/html;
    
        access_log   /var/log/nginx/access.log main;
        error_log    /var/log/nginx/error.log warn;
    
        fastcgi_read_timeout 60;
    
        gzip off;

        location / {
            root /var/www/html;
        }
    }
```

`data` に書かれている `nginx.conf` や `hoge.conf` は Deployment のマニフェストに記載された volumes の key にそれぞれ対応しているので、必要に応じてここに設定ファイルを増やしたりしてマウントする。

# Pod と通信できるように Service のマニフェストを用意する

Deployment によってそれぞれの Node にデプロイされた Pod は固定の IP アドレスを持たないため、単一のエンドポイントとして通信できるように Service を定義した `nginx-service.yaml` を用意する。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  selector:
    app: nginx-pod
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 80
  type: LoadBalancer
```

今回は自宅のオンプレで Kubernetes のクラスタを動かしているため、MetalLB を別途デプロイして `type: LoadBalancer` としている。

https://metallb.universe.tf/installation/

MetalLB をインストールすることで、LoadBalancer タイプの Service をデプロイした時に `EXTERNAL-IP` にホスト側と通信ができる仮想 IP アドレスが払い出されるのであとはリバースプロキシしてやるなり直接接続するなりして Pod にアクセスすることができるようになる。

```bash
# kubectl -n namespace get svc
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)          AGE
nginx-svc    LoadBalancer   10.98.18.22      192.168.1.70   8080:30080/TCP   9d
```

# マニフェストをデプロイする

マニフェストが用意出来たらあとは `kubectl apply` を叩くだけ。

```bash
# kubectl -n namespace apply -f ./nginx-deployment.yaml -f ./nginx-configmap.yaml -f nginx-service.yaml
deployment.apps/nginx-deployment created
configmap/nginx-conf created
service/nginx-svc created
```

うまくデプロイできていれば Pod が 3 台 Running になっているはず。

```bash
# kubectl -n namespace get pods
NAME                                                 READY   STATUS    RESTARTS         AGE
nginx-deployment-78d7d9fb8f-98g26                    1/1     Running   0                8d
nginx-deployment-78d7d9fb8f-gp8bz                    1/1     Running   0                8d
nginx-deployment-78d7d9fb8f-wrb8b                    1/1     Running   0                8d
```
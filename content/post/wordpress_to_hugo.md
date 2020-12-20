---
title: "このブログを WordPress から Golang 製の Hugo へ移行した"
date: 2020-09-15
categories:
- 覚書
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/hugo.png
draft: false
summary: "つい先日、これまでブログの運用に利用していた WordPress をやめ Hugo へ移行した。"
---

{{< img src="hugo_02" ext="png">}}

つい先日、これまでブログの運用に利用していた WordPress をやめ Hugo へ移行した。

https://github.com/gohugoio/hugo

というのも、WordPress の脆弱性やら、そもそもプラグインをほとんど使わないし WordPress である必要性がないといったところで、前々から考えてはいたことをようやく実行した感じ。

Hugo にするにあたってホスティング先も GitHub Pages だとか Firebase だとか S3 + CloudFront だとかも検討したけど、無料枠の制限とかが比較的緩めで、GitHub と連携すれば勝手に CI/CD してくれる Netlify にした。
Netlify は CDN が無料で使えるけどエッジサーバがシンガポールにあるので若干レイテンシが大きい。

なので、前段に CloudFlare を置いてそっちでキャッシュをしていたりする。

↓ Netlify
```bash
$ ping -c 10 -s 1024 *****.netlify.app
PING *****.netlify.app(2400:6180:0:d1::360:1001 (2400:6180:0:d1::360:1001)) 1024 data bytes
1032 bytes from 2400:6180:0:d1::360:1001 (2400:6180:0:d1::360:1001): icmp_seq=1 ttl=44 time=77.8 ms
1032 bytes from 2400:6180:0:d1::360:1001 (2400:6180:0:d1::360:1001): icmp_seq=2 ttl=44 time=75.0 ms
1032 bytes from 2400:6180:0:d1::360:1001 (2400:6180:0:d1::360:1001): icmp_seq=3 ttl=44 time=75.4 ms
1032 bytes from 2400:6180:0:d1::360:1001 (2400:6180:0:d1::360:1001): icmp_seq=4 ttl=44 time=75.3 ms
1032 bytes from 2400:6180:0:d1::360:1001 (2400:6180:0:d1::360:1001): icmp_seq=5 ttl=44 time=75.4 ms
1032 bytes from 2400:6180:0:d1::360:1001 (2400:6180:0:d1::360:1001): icmp_seq=6 ttl=44 time=75.2 ms
1032 bytes from 2400:6180:0:d1::360:1001 (2400:6180:0:d1::360:1001): icmp_seq=7 ttl=44 time=75.6 ms
1032 bytes from 2400:6180:0:d1::360:1001 (2400:6180:0:d1::360:1001): icmp_seq=8 ttl=44 time=75.1 ms
1032 bytes from 2400:6180:0:d1::360:1001 (2400:6180:0:d1::360:1001): icmp_seq=9 ttl=44 time=75.5 ms
1032 bytes from 2400:6180:0:d1::360:1001 (2400:6180:0:d1::360:1001): icmp_seq=10 ttl=44 time=75.4 ms

--- *****.netlify.app ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 22ms
rtt min/avg/max/mdev = 75.044/75.561/77.765/0.810 ms
```

↓ CloudFlare 経由
```bash
$ ping -c 10 -s 1024 sorarinu.dev
PING sorarinu.dev(2606:4700:3033::ac43:c04e (2606:4700:3033::ac43:c04e)) 1024 data bytes
1032 bytes from 2606:4700:3033::ac43:c04e (2606:4700:3033::ac43:c04e): icmp_seq=1 ttl=54 time=12.9 ms
1032 bytes from 2606:4700:3033::ac43:c04e (2606:4700:3033::ac43:c04e): icmp_seq=2 ttl=54 time=12.2 ms
1032 bytes from 2606:4700:3033::ac43:c04e (2606:4700:3033::ac43:c04e): icmp_seq=3 ttl=54 time=12.3 ms
1032 bytes from 2606:4700:3033::ac43:c04e (2606:4700:3033::ac43:c04e): icmp_seq=4 ttl=54 time=12.1 ms
1032 bytes from 2606:4700:3033::ac43:c04e (2606:4700:3033::ac43:c04e): icmp_seq=5 ttl=54 time=12.2 ms
1032 bytes from 2606:4700:3033::ac43:c04e (2606:4700:3033::ac43:c04e): icmp_seq=6 ttl=54 time=12.7 ms
1032 bytes from 2606:4700:3033::ac43:c04e (2606:4700:3033::ac43:c04e): icmp_seq=7 ttl=54 time=11.7 ms
1032 bytes from 2606:4700:3033::ac43:c04e (2606:4700:3033::ac43:c04e): icmp_seq=8 ttl=54 time=12.0 ms
1032 bytes from 2606:4700:3033::ac43:c04e (2606:4700:3033::ac43:c04e): icmp_seq=9 ttl=54 time=12.2 ms
1032 bytes from 2606:4700:3033::ac43:c04e (2606:4700:3033::ac43:c04e): icmp_seq=10 ttl=54 time=12.5 ms

--- sorarinu.dev ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 23ms
rtt min/avg/max/mdev = 11.675/12.281/12.938/0.353 ms
```

WordPress から移行したことでパーマリンクの設定が変わったので、Twitter だとかで呟いた過去の URL にアクセスするとトップページに飛ぶのでお気を付けください（WordPress 側のパーマリンクを再現できなかった & リダイレクトするためのサーバを用意するのが面倒くさかった）。
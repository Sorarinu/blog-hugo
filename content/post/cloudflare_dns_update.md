---
title: "パブリック IP アドレスを取得して CloudFlare の DNS レコードを更新するスクリプトを作った"
date: 2020-02-11
categories:
- CloudFlare
- OSS
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/cloudflare.jpg
summary: "なんのことかわからないけど、気がついたら自宅サーバを組み上げていた。"
---

{{< image classes="fancybox nocaption clear center fig-100" src="/img/post/cloudflare_02.jpg" >}}

なんのことかわからないけど、気がついたら自宅サーバを組み上げていた。

ただ、我が家は固定 IP アドレスを契約していないため、ルータの再起動などでパブリック IP アドレスが変わってしまう。

そこで、パブリック IP アドレスを取得してきて、現在登録されている DNS レコードに変更があったら勝手にアップデートしてくれるスクリプトを作ってみた。

https://github.com/Sorarinu/UpdateCloudFlareDNS

`.env.example` をコピーして必要な情報を埋めてから main.php を叩けば更新されるはず。
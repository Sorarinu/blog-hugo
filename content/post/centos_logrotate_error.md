---
title: "CentOS7 のサーバで logrotate しようとしたらエラーが出たので直した"
date: 2020-04-22
categories:
- CentOS
- 覚書
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/centos.png.webp
draft: false
summary: "Amazon Linux 1 系のサーバで動かしていたものを CentOS7 に移行した際、logrotate が下記のようなエラーを吐いた。"
---

{{< img src="centos_02" ext="png">}}

Amazon Linux 1 系のサーバで動かしていたものを CentOS7 に移行した際、logrotate が下記のようなエラーを吐いた。

```
error: skipping "/var/log/php/error.log" because parent directory has insecure permissions (It's world writable or writable by group which is not "root") Set "su" directive in config file to tell logrotate which user/group should be used for rotation.
```

調べてみたところ、ログローテートを行う対象の親ディレクトリでパーミッションが 777 だったり、同一グループの書き込み権限がついていたりすると出るエラーらしい。

解決策は、 su user group のようにローテートするユーザとグループを指定するか、親ディレクトリのパーミッションを 755 などにするといいらしい。

```bash
/var/log/app/*.log
{
    :
    su apache apache
    :
}
```

CentOS 6 系の OS だと出なかったみたい。
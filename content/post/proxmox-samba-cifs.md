---
title: "Proxmox のノードでファイルサーバを CIFS マウントしてたら VM が起動できなくなってた話"
date: 2022-01-29T19:54:00+09:00
categories:
- Proxmox
- 自宅サーバ
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/proxmox_logo.png.webp
draft: false
summary: "PVE ノードでファイルサーバを CIFS マウントしてたら samba が tmpfs を食い尽くして VM があがらなくなった。"
---

Kubernetes 1.22 に対応した Rancher がリリースされてたから久々に VM を起動しようとしたら、 `start failed: org.freedesktop.systemd1.NoSuchUnit: Unit 105.scope not found.` とエラーが出て起動しなかった。

{{< img src="proxmox_error" ext="png">}}

色々調べてみると、PVE ノードでファイルサーバを CIFS マウントしてたら samba が tmpfs を食い尽くしたのが原因っぽく、これは Proxmox の既知のバグらしい。

https://bugzilla.proxmox.com/show_bug.cgi?id=2333

```bash
root@sorarinusv01:~# df -h
Filesystem              Size  Used Avail Use% Mounted on
udev                     16G     0   16G   0% /dev
tmpfs                   3.2G  3.2G     0 100% /run
/dev/mapper/pve-root     70G  5.0G   65G   8% /
tmpfs                    16G   63M   16G   1% /dev/shm
tmpfs                   5.0M     0  5.0M   0% /run/lock
tmpfs                    16G     0   16G   0% /sys/fs/cgroup
/dev/fuse                30M   36K   30M   1% /etc/pve
//192.168.1.254/system  2.5T  571G  2.0T  23% /mnt/pve/sorarinusv-fileserver

root@sorarinusv01:~# ls -la /var/run/samba/msg.lock/ | wc -l
742259

root@sorarinusv01:~# ls -la /var/lib/samba/private/msg.sock/ | wc -l
1807384
```

現状バグの修正などはなく、とりあえず 1 時間おきに samba の一時ファイルを削除するシェルスクリプトを cron で動かすようにして回避した。

```shell
#!/bin/sh

# Cleanup old files
find /var/lib/samba/private/msg.sock -type s -mmin +600 -delete
find /var/run/samba/msg.lock -type f -mmin +600 -delete

# Cleanup recent files by checking for process
for file in `find /var/lib/samba/private/msg.sock -type s`; do [ -d "/proc/$(basename "$file")" ] || rm -vf "$file"; done;
for file in `find /var/run/samba/msg.lock -type f`; do [ -d "/proc/$(basename "$file")" ] || rm -vf "$file"; done;
```

```crontab
* */1 * * * /usr/bin/sh /opt/cleanup_samba.sh
```
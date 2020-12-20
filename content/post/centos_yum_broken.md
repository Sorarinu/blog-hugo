---
title: "CentOS7 で epel-release を入れたら yum が動かなくなったので対処した"
date: 2020-02-04
categories:
- AWS
- CentOS
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/centos.png.webp
summary: "AWS EC2 で CentOS7 サーバをたてて `yum install epel-release` をしたら yum が動かなくなった。"
---

AWS EC2 で CentOS7 サーバをたてて `yum install epel-release` をしたら yum が動かなくなった。

```bash
[root@hostname ~]# yum update
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 One of the configured repositories failed (Unknown),
 and yum doesn't have enough cached data to continue. At this point the only
 safe thing yum can do is fail. There are a few ways to work "fix" this:
     1. Contact the upstream for the repository and get them to fix the problem.
     2. Reconfigure the baseurl/etc. for the repository, to point to a working
        upstream. This is most often useful if you are using a newer
        distribution release than is supported by the repository (and the
        packages for the previous distribution release still work).
     3. Run the command with the repository temporarily disabled
            yum --disablerepo=<repoid> ...
     4. Disable the repository permanently, so yum won't use it by default. Yum
        will then just ignore the repository until you permanently enable it
        again or use --enablerepo for temporary usage:
            yum-config-manager --disable <repoid>
        or
            subscription-manager repos --disable=<repoid>
     5. Configure the failing repository to be skipped, if it is unavailable.
        Note that yum will try to contact the repo. when it runs most commands,
        so will have to try and fail each time (and thus. yum will be be much
        slower). If it is a very temporary problem though, this is often a nice
        compromise:
            yum-config-manager --save --setopt=<repoid>.skip_if_unavailable=true
Cannot retrieve metalink for repository: epel/x86_64. Please verify its path and try again
```

ちょっと調べてみたところ、どうやら fedoraproject の名前解決周りが怪しそうな雰囲気。

```bash
[root@hostname ~]# curl https://mirrors.fedoraproject.org
curl: (6) Could not resolve host: mirrors.fedoraproject.org; 不明なエラー
```

https://www.reddit.com/r/Fedora/comments/eylcui/fedoraprojectorg_dns_servers_returning_servfail/

いったん `/etc/resolv.conf` に Google DNS （8.8.8.8）を追加したら接続できるようになった。
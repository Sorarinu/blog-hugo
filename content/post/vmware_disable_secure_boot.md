---
title: "VMware ESXi 6.7 でセキュアブートを無効化する"
date: 2020-02-18
categories:
- VMware
- 覚書
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/vmware.png
summary: "VMware ESXi 6.7 で VM を構築してさぁセットアップするぞ！って時にセキュアブート周りでエラーを吐かれてしまったので、セキュアブートを無効化する。"
---

{{< img src="vmware_esxi" ext="png">}}

VMware ESXi 6.7 で VM を構築してさぁセットアップするぞ！って時にセキュアブート周りでエラーを吐かれてしまったので、セキュアブートを無効化する。

{{< img src="vmware_disable_secure_boot" ext="png">}}

やり方は簡単で、VM の設定画面から「仮想マシンオプション」を開き、「UEFI セキュアブートの有効化」のチェックボックスを外すだけ。

再起動後、セキュアブートが無効になっていればOK。

```bash
$ dmesg | grep Secure
[    0.000000] Secure boot disabled
```
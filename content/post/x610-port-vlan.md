---
title: "Allied Telesis x610-48Ts/X で SFP+ のポートを Vlan で分けてみた"
date: 2021-04-10T15:09:00+09:00
categories:
- ネットワーク
- 覚書
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/allied_telesis_logo.png.webp
draft: false
summary: "家のネットワーク周りでメイン PC （Windows）とファイルサーバ間を 10GbE で繋ぐってなったときに困るのがジャンボパケットだと思う。"
---

家のネットワーク周りでメイン PC （Windows）とファイルサーバ間を 10GbE で繋ぐってなったときに割と困るのがジャンボパケットだと思う。

メイン PC とファイルサーバに 10GbE の NIC を接続してジャンボパケットを有効にしても、そもそも 10GbE ＋ ジャンボパケットに対応していない機器（その他 PC やサーバ群）との通信で不都合が起きたりする。

そこで、スイッチの SFP+ ポートを Vlan で切り出してジャンボパケットのやり取りはそっちに任せてみた。

# スイッチの現状を確認してみる

作業を始める前に、初期状態の設定がどうなっているのか確認してみた。

```
SW01#show vlan all
VLAN ID  Name            Type    State   Member ports                   
                                         (u)-Untagged, (t)-Tagged
======= ================ ======= ======= ====================================
1       default          STATIC  ACTIVE  port1.0.1(u) port1.0.2(u) port1.0.3(u) 
                                         port1.0.4(u) port1.0.5(u) port1.0.6(u) 
                                         port1.0.7(u) port1.0.8(u) port1.0.9(u) 
                                         port1.0.10(u) port1.0.11(u) 
                                         port1.0.12(u) port1.0.13(u) 
                                         port1.0.14(u) port1.0.15(u) 
                                         port1.0.16(u) port1.0.17(u) 
                                         port1.0.18(u) port1.0.19(u) 
                                         port1.0.20(u) port1.0.21(u) 
                                         port1.0.22(u) port1.0.23(u) 
                                         port1.0.24(u) port1.0.25(u) 
                                         port1.0.26(u) port1.0.27(u) 
                                         port1.0.28(u) port1.0.29(u) 
                                         port1.0.30(u) port1.0.31(u) 
                                         port1.0.32(u) port1.0.33(u) 
                                         port1.0.34(u) port1.0.35(u) 
                                         port1.0.36(u) port1.0.37(u) 
                                         port1.0.38(u) port1.0.39(u) 
                                         port1.0.40(u) port1.0.41(u) 
                                         port1.0.42(u) port1.0.43(u) 
                                         port1.0.44(u) port1.0.45(u) 
                                         port1.0.46(u) port1.0.47(u) 
                                         port1.0.48(u) port1.0.49(u)
                                         port1.0.50(u)
```

見たらわかる通り、すべてのポートがデフォルトの Vlan 1 で繋がっているので、ジャンボパケットを有効にしたら対応してない機器側でパケットを破棄されたりと不都合が発生してしまう。
x610-48Ts/X は SFP+ のポートを 2 つ持っていて、今回はその SFP+ ポートである `port1.0.49` と `port1.0.50` を Vlan で切り出す。

# さくっと Vlan を作成する

[x610 コマンドリファレンス](https://www.allied-telesis.co.jp/support/list/switch/x610poe/rel/5.4.3-2.5/001613d/docs/vlan@166VLAN.html)

```
SW01> enable
SW01# configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
SW01(config)# vlan database
SW01(config-vlan)# vlan 10 name 10GbE # わかりやすい名前
SW01(config-vlan)# exit
SW01(config)# interface port1.0.49-1.0.50
SW01(config-if)# switchport mode access
SW01(config-if)# switchport access vlan 10
SW01(config-if)# exit
SW01(config)# exit
SW01# write
Building configuration...
[OK]
```

これで Vlan を確認してみると Vlan 10 が出来上がっているはず。

```
SW01#show vlan all
VLAN ID  Name            Type    State   Member ports                   
                                         (u)-Untagged, (t)-Tagged
======= ================ ======= ======= ====================================
1       default          STATIC  ACTIVE  port1.0.1(u) port1.0.2(u) port1.0.3(u) 
                                         port1.0.4(u) port1.0.5(u) port1.0.6(u) 
                                         port1.0.7(u) port1.0.8(u) port1.0.9(u) 
                                         port1.0.10(u) port1.0.11(u) 
                                         port1.0.12(u) port1.0.13(u) 
                                         port1.0.14(u) port1.0.15(u) 
                                         port1.0.16(u) port1.0.17(u) 
                                         port1.0.18(u) port1.0.19(u) 
                                         port1.0.20(u) port1.0.21(u) 
                                         port1.0.22(u) port1.0.23(u) 
                                         port1.0.24(u) port1.0.25(u) 
                                         port1.0.26(u) port1.0.27(u) 
                                         port1.0.28(u) port1.0.29(u) 
                                         port1.0.30(u) port1.0.31(u) 
                                         port1.0.32(u) port1.0.33(u) 
                                         port1.0.34(u) port1.0.35(u) 
                                         port1.0.36(u) port1.0.37(u) 
                                         port1.0.38(u) port1.0.39(u) 
                                         port1.0.40(u) port1.0.41(u) 
                                         port1.0.42(u) port1.0.43(u) 
                                         port1.0.44(u) port1.0.45(u) 
                                         port1.0.46(u) port1.0.47(u) 
                                         port1.0.48(u) 
10      10GbE            STATIC  ACTIVE  port1.0.49(u) port1.0.50(u) # ← 追加されてる
```

# インタフェースの MRU を変更する

Vlan を分けたところで肝心のジャンボパケットを許可する設定を入れないと意味がないので突っ込む。

[x610 コマンドリファレンス](https://www.allied-telesis.co.jp/support/list/switch/x610poe/rel/5.4.1-2.7/001613a/docs/mru@116INTERFACE.html)

```
SW01> enable
SW01# configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
SW01(config)# interface port1.0.49-1.0.50
SW01(config-if)# mru 9000
SW01(config-if)# exit
SW01(config)# exit
SW01# write
Building configuration...
[OK]
```

これでインタフェースの情報を確認すると MRU が 9000 になっていることがわかる。

```
SW01#show interface
:
:
Interface port1.0.49
  Scope: both
  Link is UP, administrative state is UP
  Thrash-limiting
    Status Not Detected, Action learn-disable, Timeout 1(s)
  Hardware is Ethernet, address is eccd.6d83.1245
  index 5049 metric 1 mru 9000 # ← MRU が 9000 になってる
  current duplex full, current speed 10000, current polarity mdi
  configured duplex auto, configured speed auto, configured polarity auto
  <UP,BROADCAST,RUNNING,MULTICAST>
  SNMP link-status traps: Disabled
    input packets 104139791, bytes 588610478830, dropped 0, multicast packets 57685
    output packets 67200916, bytes 168777655735, multicast packets 299490 broadcast packets 454331
  Time since last state change: 2 days 16:05:55
Interface port1.0.50
  Scope: both
  Link is UP, administrative state is UP
  Thrash-limiting
    Status Not Detected, Action learn-disable, Timeout 1(s)
  Hardware is Ethernet, address is eccd.6d83.1245
  index 5050 metric 1 mru 9000
  current duplex full, current speed 10000, current polarity mdi
  configured duplex auto, configured speed auto, configured polarity auto
  <UP,BROADCAST,RUNNING,MULTICAST>
  SNMP link-status traps: Disabled
    input packets 68267532, bytes 165285513894, dropped 0, multicast packets 4521
    output packets 111711808, bytes 603958029596, multicast packets 177149 broadcast packets 255797
  Time since last state change: 2 days 16:05:52
:
:
```

# Vlan10 に IP アドレスを割り当てる

今回は Vlan10 に `192.168.10.1/24` を割り当てて通信できるようにする。

```
SW01> enable
SW01# configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
SW01(config)# interface vlan10
SW01(config-if)# ip address 192.168.10.1/24
SW01(config-if)# exit
SW01(config)# exit
SW01#write
Building configuration...
[OK]
```

IP アドレスが正常に割り当たっていればこんな感じになっているはず。

```
SW01# show ip interface
Interface             IP-Address         Status          Protocol
lo                    unassigned         admin up        running    
vlan1                 192.168.1.253/24   admin up        running    
vlan10                192.168.10.1/24    admin up        running
```

これでスイッチ側の設定は一通り完了したので、あとはクライアント側で 10GbE NIC に `192.168.10.1/24` の IP アドレスを割り振って疎通確認しよう。

また、10GbE NIC だけだとローカルエリア通信は問題ないけど WAN 側に出られなくなるので、別途 1GbE NIC を追加して Vlan 1 に繋いだ後、そっちをデフォルトゲートウェイに設定したら外とも通信ができるようになる。
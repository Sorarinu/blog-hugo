---
title: "Prometheus で YAMAHA RTX3000 のメトリクスを取得して可視化した"
date: 2020-05-10
categories:
- ネットワーク
- 覚書
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/prometheus.png
draft: false
summary: "気が付いたら家に YAMAHA RTX3000 が届いた。"
---

気が付いたら家に YAMAHA RTX3000 が届いた。

{{< img src="yamaha_rtx3000" ext="jpg">}}

諸々の設定を済ませてもりもり働きだしたので、Prometheus でメトリクスを収集して Grafana で可視化したので備忘録。

# docker-compose.yml に snmp_exporter を追加する

```yaml
# version: '3'

volumes:
    prometheus_data:
    grafana_data:

networks:
  prometheus:

services:
:
:
  snmp-exporter:
    image: prom/snmp-exporter:v0.10.0
    container_name: snmp-exporter
    volumes:
      - /opt/docker/snmp-exporter:/etc/snmp_exporter
    networks:
      - prometheus
    ports:
      - 9116:9116
    restart: always
:
:
```

今回は `/opt/docker/snmp-exporter` に必要なファイルを設置するため、コンテナの `/etc/snmp_exporter` にボリュームをマウントしている。

# snmp-exporter の Generator で snmp.yml を生成して設置する

まずは snmp-exporter を git clone してきて、mib ファイルを設置する。

また、YAMAHA はプライベート mib を公開しているので、それも併せてダウンロードして設置する。

```bash
# yum install gcc make net-snmp net-snmp-utils net-snmp-libs net-snmp-devel
# git clone https://github.com/prometheus/snmp_exporter.git
# cd snmp_exporter/generator
# go build
# make mibs
# wget http://www.rtpro.yamaha.co.jp/RT/docs/mib/yamaha-private-mib.zip
# unzip yamaha-private-mib.zip 
# mv yamaha-* mibs/
# export MIBDIRS=mibs
```

mib ファイルの設置ができたら、Generator に必要な generator.yml を準備する。

【module name】適当なわかりやすい文字列（今回は rtx3000 ）

【walk】取得したいメトリクスたち

【version】SNMP のバージョン（ RTX3000 は SNMP v1 にしか対応していない）

【auth】RTX3000 側で設定した認証情報

```yaml
modules:
  rtx3000:
    walk:
      - yrhCpuUtil5sec
      - yrhCpuUtil1min
      - yrhCpuUtil5min
      - yrfRevision
      - yrhInboxTemperature
      - yrfUpTime
      - yrhMemoryUtil
      - ifInOctets
      - ifOutOctets
    version: 1
    auth:
      community: public
```

generator.yml が準備できたら、Generator を実行して snmp.yml を生成しよう。

特にエラーが出なければこんな感じの出力がされる。

```bash
# ./generator generate
level=info ts=2020-05-09T15:06:34.262Z caller=net_snmp.go:142 msg="Loading MIBs" from=$HOME/.snmp/mibs:/usr/share/snmp/mibs
level=info ts=2020-05-09T15:06:34.296Z caller=main.go:52 msg="Generating config for module" module=rtx3000
level=info ts=2020-05-09T15:06:34.300Z caller=main.go:67 msg="Generated metrics" module=rtx3000 metrics=9
level=info ts=2020-05-09T15:06:34.301Z caller=main.go:92 msg="Config written" file=/opt/docker/snmp_exporter/generator/snmp.yml
```

この例だと、 `/opt/docker/snmp_exporter/generator/snmp.yml` にファイルが生成されるので、これを docker コンテナにマウントしたディレクトリに配置し、Prometheus の設定ファイルにジョブを追加する。

```yaml
:
:
  - job_name: 'snmp.rtx3000'
    static_configs:
      - targets:
          - 192.168.1.1  # RTX3000
        labels:
          name: RTX3000
          vendor: yamaha
    params:
      module:
        - rtx3000
    metrics_path: /snmp
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - source_labels: [type]
        target_label: __param_module
      - target_label: __address__
        replacement: snmp-exporter:9116
:
:
```

できたらコンテナを立ち上げる。

```bash
# docker-compose up -d
```

無事に立ち上がっていれば、 curl を叩くといい感じなメトリクスが返ってくると思うので、これを使って Grafana のダッシュボードを作成すれば幸せになれそう。

```bash
# curl -XGET "http://localhost:9116/snmp?target=<RTX3000 の IP アドレス>&module=rtx3000"
```

# Grafana ダッシュボードを作ってみた

{{< image classes="fancybox nocaption clear center fig-100" src="/img/post/Grafana.png" >}}

幸せになれた。
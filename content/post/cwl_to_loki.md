---
title: "CloudWatch Logs に出力された TSV 形式のログを Grafana Loki に送る OSS を公開した"
date: 2020-02-05
categories:
- AWS
- OSS
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/cwl_to_loki_01.png.webp
summary: "AWS Lambda などで CloudWatch Logs に対して TSV 形式でログを送っている場合に、CloudWatch Insight を使って解析するのもなんだか辛かったので Grafana Loki へ送信するツールを作った。"
---

{{< img src="cwl_to_loki_02" ext="png">}}

AWS Lambda などで CloudWatch Logs に対して TSV 形式でログを送っている場合に、CloudWatch Insight を使って解析するのもなんだか辛かったので Grafana Loki へ送信するツールを作った。

https://github.com/Sorarinu/cloudwatch-logs-to-loki

```bash
message: this message is hoge.\tlevel: ERROR\tline: 10
```

上記のような形式で CloudWatch Logs にログを投げ込むとコロン区切りで key – value に分けて Grafana Loki にログを送信できる。

使い方は簡単で、make するとビルド成果物が zip で出来上がるので AWS Lambda に Lambda 関数を作成し、必要な環境変数をセットした上で CloudWatch Logs ストリームに登録するだけで動くはず。

GitHub で公開しているので何かあったらプルリクお待ちします。
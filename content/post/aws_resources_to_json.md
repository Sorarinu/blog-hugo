---
title: "AWS にある EC2 とそれに紐づく ALB の情報を json で取得するツールを作った"
date: 2020-10-31
categories:
- aws
- oss
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/aws.jpg.webp
draft: false
summary: "AWS に EC2 インスタンスや ALB を作成した後、たまにインスタンスの情報を一覧で取得したくなる衝動に駆られる人はいると思う。"
---

AWS に EC2 インスタンスや ALB を作成した後、たまにインスタンスの情報を一覧で取得したくなる衝動に駆られる人はいると思う。
それに加えて、どのロードバランサがどの EC2 インスタンスに紐づいているのかを知りたい欲張りさんも中にはいるだろう。

かく言う私もその一人だ。

ただ、AWS CLI とか使ってゴニョゴニョするのも面倒くさいと思うので json で吐き出してくれる君を作ってみた。

{{< tweet 1322554556014886912 >}}

これを使うとまさに顧客の求めていたもの（json）が取得できるようになる。

```
[
    :
    :
  {
    "InstanceId": "i-xxxxxxxxxxxxx",
    "InstanceType": "t3.small",
    "Placement": "ap-northeast-1a",
    "PrivateIP": "xxx.xxx.xxx.xxx",
    "PublicIP": "yyy.yyy.yyy.yyy",
    "State": "running",
    "Tags": [
      {
        "Key": "Name",
        "Value": "ec2_instance_hoge"
      }
    ],
    "Name": "ec2_instance_hoge",
    "LoadBalancer": {
      "Arn": "arn:aws:elasticloadbalancing:ap-northeast-1:xxxxxxxxxx:loadbalancer/app/hoge-loadbalancer/zzzzzzzzzzzz",
      "Name": "hoge-loadbalancer",
      "Tags": [
        {
          "Key": "hoge",
          "Value": "true"
        }
      ],
      "TargetGroups": [
        {
          "Arn": "arn:aws:elasticloadbalancing:ap-northeast-1:xxxxxxxxxxx:targetgroup/hoge-target/zzzzzzzzzzzzz",
          "Name": "hoge-target",
          "Targets": [
            {
              "InstanceId": "i-xxxxxxxxxxxxx",
              "State": "healthy"
            }
          ]
        }
      ]
    }
  },
    :
    :
]
```

結構適当に作ったのでプルリクまってます。
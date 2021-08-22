---
title: "Kubernetes の Deployment と StatefulSet の違いを今更学んだ"
date: 2021-08-22T00:00:00+09:00
categories:
- Kubernetes
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/kubernetes.png.webp
draft: false
summary: "プライベートで Kubernetes のクラスタを扱う機会があり、今更になって Deployment と StatefulSet の違いについて学んだので備忘録。"
---

プライベートで Kubernetes のクラスタを扱う機会があり、今更になって Deployments と StatefulSet の違いについて学んだので備忘録。

# Deployment

- ステートレス＝状態を持たない Pod を展開する
- Deployment の中で PersistentVolumeClaim を通して永続ボリュームを要求すると、展開された全ての Pod で共有の永続ボリュームが割り当てられる
- nginx とかアプリケーションを動かしたい場合は基本こっち


# StatefulSet

- ステートフル＝状態を持つ Pod を展開する
- 展開された全ての Pod は順序付けされた一意な識別子が付与されるため、デプロイ、スケーリング、ローリングアップデート時に順序付けされた動作の元実行される
- StatefulSet の中で VolumeClaimTemplate を通して永続ボリュームを要求すると、それぞれの Pod に対して一意の永続ボリュームが割り当てられる
- Pod を喪失しても喪失前と同じ名前（識別子）で複製されて対応する永続ボリュームに再度関連付けされる
- DB とか状態を持たせておきたい場合はこっち

ほかにも細かい違いはあるけど、だいたいこんな感じだと思っておけばよさそう。

{{< img src="pv" ext="png">}}
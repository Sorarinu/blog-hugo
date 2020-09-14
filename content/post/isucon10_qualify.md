---
title: "ISUCON10 予選に参加して惨敗しました"
date: 2020-09-13
categories:
- 覚書
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/isucon.png
draft: false
summary: "前回の ISUCON9 から 1 年、ISUCON10 の予選に「oystersから集いし精鋭たちの集まり」として参加しました。"
---

前回の ISUCON9 から 1 年、ISUCON10 の予選に「oystersから集いし精鋭たちの集まり」として参加しました。

{{< tweet 1304616459335680001 >}}

# やったこと

自分はインフラ担当だったので、アプリケーション側はほとんど見てません（ちょっと眺めるくらい）。

だいたいこんな感じのタスクを実施しました。

1. Nginx パラメータ周りのチューニング
2. MySQL 8.0 へのアップグレード
3. MySQL 周りのチューニング
4. Web アプリケーションを複数台でバランシング出来るようにする
5. カーネルパラメータのチューニング

MySQL 周りに関しては、MySQL 8.0 にアップグレードするとスコアが激減するという事象に見舞われましたが、また戻すのも時間がかかるのでそのまま進めることにしました（後から気が付いたけど Query Cache とかその辺が問題だったらしい）。

また、おなじみの AppArmor にも大分苦しめられてだいぶ時間を浪費しました。

# 最終スコア

なぜか一生終わらないベンチにぶち当たりながら最終スコアはこんな感じで惨敗でした。

最高でも 524 点だったので文字通り惨敗でした。

{{< image classes="fancybox nocaption clear center fig-100" src="/img/post/isucon10_score.png" >}}

# さいごに

1 年ぶりの ISUCON でしたが、初のリモートということもありまた違った楽しさがありました。

とりあえず手も足も出なくて悔しすぎたので次回は優勝します。

ISUCON 運営のみなさん、本当にありがとうございました。

↓がんばりの軌跡

https://github.com/zoetics/20200912-isucon10-qualify/issues/1
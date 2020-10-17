---
title: "AWS Trusted Advisor の通知を CloudWatch Events + Lambda + Golang で Slack へ送信する"
date: 2020-10-18
categories:
- 覚書
- AWS
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/aws.jpg
draft: false
summary: "セキュリティやコスト周りなどの改善点をベストプラクティスに則って教えてくれる AWS Trusted Advisor は通常だとメールで通知を送ることしかできない。"
---

セキュリティやコスト周りなどの改善点をベストプラクティスに則って教えてくれる AWS Trusted Advisor は通常だとメールで通知を送ることしかできない。
Slack へ通知を送る場合は Lambda を使っていい感じにする必要があるが、Google 先生に教えを乞っても大体 Python を使ったものが多い（別にいいんだけど）

ただ、最近 Golang が好きなおじさんになりつつあるので、今回は色々参考にしながら Golang で実装をした。

```
package main
​
import (
	"bytes"
	"context"
	"encoding/json"
	"github.com/aws/aws-lambda-go/lambda"
	"net/http"
	"os"
	"time"
)
​
type PayloadParam struct {
	Blocks []Blocks `json:"blocks"`
}
​
type Blocks struct {
	Type     string     `json:"type"`
	Text     *Text      `json:"text,omitempty"`
	Fields   []Fields   `json:"fields,omitempty"`
	Elements []Elements `json:"elements,omitempty"`
}
​
type Text struct {
	Type string `json:"type,omitempty"`
	Text string `json:"text,omitempty"`
}
​
type Fields struct {
	Type string `json:"type"`
	Text string `json:"text"`
}
​
type Elements struct {
	Type  string       `json:"type"`
	Text  ElementsText `json:"text"`
	Style string       `json:"style"`
	Value string       `json:"value"`
}
​
type ElementsText struct {
	Type  string `json:"type"`
	Emoji bool   `json:"emoji"`
	Text  string `json:"text"`
}
​
type TrustedAdvisorCloudWatchEvent struct {
	Version    string    `json:"version"`
	ID         string    `json:"id"`
	DetailType string    `json:"detail-type"`
	Source     string    `json:"source"`
	AccountID  string    `json:"account"`
	Time       time.Time `json:"time"`
	Region     string    `json:"region"`
	Resources  []string  `json:"resources"`
	Detail     Detail    `json:"detail"`
}
​
type Detail struct {
	CheckName       string          `json:"check-name"`
	CheckItemDetail json.RawMessage `json:"check-item-detail"`
	Status          string          `json:"status"`
	ResourceID      string          `json:"resource_id"`
	UUID            string          `json:"uuid"`
}
​
func getEmoji(status string) string {
	if status == "ERROR" {
		return ":exclamation:"
	} else if status == "WARN" {
		return ":warning:"
	}
​
	return ":information_source:"
}
​
func sendSlack(event TrustedAdvisorCloudWatchEvent) error {
	url := os.Getenv("SLACK_WEBHOOK_URI")
​
	payload := PayloadParam{
		Blocks: []Blocks{
			{
				Type: "section",
				Text: &Text{
					Type: "mrkdwn",
					Text: "<!here> " + getEmoji(event.Detail.Status) + " AWS Trusted Advisor のステータスが更新されました",
				},
			},
			{
				Type: "divider",
			},
			{
				Type: "section",
				Text: &Text{
					Type: "mrkdwn",
					Text: "*Detail Type*\n" + event.DetailType,
				},
			},
			{
				Type: "section",
				Text: &Text{
					Type: "mrkdwn",
					Text: "*Check Name*\n" + event.Detail.CheckName,
				},
			},
			{
				Type: "section",
				Text: &Text{
					Type: "mrkdwn",
					Text: "*Source*\n" + event.Source,
				},
			},
			{
				Type: "section",
				Text: &Text{
					Type: "mrkdwn",
					Text: "*Status*\n" + event.Detail.Status,
				},
			},
			{
				Type: "section",
				Text: &Text{
					Type: "mrkdwn",
					Text: "*Check Item Detail*\n```\n" + string(event.Detail.CheckItemDetail) + "\n```",
				},
			},
			{
				Type: "section",
				Text: &Text{
					Type: "mrkdwn",
					Text: "*Resource ID*\n" + event.Detail.ResourceID,
				},
			},
		},
	}
​
	json, err := json.Marshal(&payload)
	if err != nil {
		return err
	}
​
	data := []byte(json)
​
	req, err := http.NewRequest(
		"POST",
		url,
		bytes.NewBuffer(data),
	)
	if err != nil {
		return err
	}
​
	req.Header.Set("Content-Type", "application/json")
​
	client := &http.Client{}
	res, err := client.Do(req)
	if err != nil {
		return err
	}
​
	defer res.Body.Close()
​
	return nil
}
​
func handler(ctx context.Context, event TrustedAdvisorCloudWatchEvent) error {
	err := sendSlack(event)
	if err != nil {
		return err
	}
​
	return nil
}
​
func main() {
	lambda.Start(handler)
}
```

Slack の WebHook URI は `SLACK_WEBHOOK_URI` といった環境変数を読んでるので適宜追加をする。 
また、CloudWatch Event で Trusted Advisor を指定する場合はバージニア北部（us-east-1）じゃないといけないので、Lambda もバージニア北部に設置していい感じにトリガーの設定をしたら Slack へ通知を送れるようになる。
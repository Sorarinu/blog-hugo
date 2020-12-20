---
title: "Ansible を使って AWS EC2 のインスタンスを作成する"
date: 2020-02-21
categories:
- AWS
- Ansible
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/ansible.png.webp
summary: "最近、Terraform で消耗しがちな人生を送ってきているので Ansible で AWS リソースの管理ができないか試してみたメモ。"
---

{{< img src="ansible_02" ext="png">}}

# やってみる

最近、Terraform で消耗しがちな人生を送ってきているので Ansible で AWS リソースの管理ができないか試してみたメモ。

ディレクトリ構造はこんな感じで、 common と ec2 の 2 つ role を用意した。

```bash
.
├── aws.yml
├── hosts
└── roles
    ├── common
    │   └── vars
    │       └── main.yml
    └── ec2
        └── tasks
            └── main.yml
```

common には、AWS Profile の名前を vars に書き出しておく。

```yaml
---

profile: default
```

そして、本命の ec2 に関する role を用意する。

```yaml
---

# c.f. https://docs.ansible.com/ansible/2.6/modules/ec2_module.html
- name: create ec2 instance
  ec2:
    profile: "{{ profile }}"
    region: us-west-2
    state: present
    count: 1
    key_name: ec2-user
    instance_type: t3a.small
    instance_profile_name: Ec2AccessRole
    image: ami-01ed306a12b7d1c96    # CentOS 7 AMI (AWS Marketplace)
    wait: yes
    wait_timeout: 500
    vpc_subnet_id: subnet-xxxxxxx
    assign_public_ip: yes
    group: [
      'default',
    ]
    volumes:
      - device_name: /dev/xvda
        volume_type: gp2
        volume_size: 100
    ebs_optimized: yes
    instance_tags:
      Name: instance_name-1
      Ansible: true
```

これらが用意できたら、playbook と inventory を用意する。

```yaml
---

- hosts: aws
  connection: local
  roles:
    - common
    - ec2
```

```yaml
[aws]
127.0.0.1
```

あとはいつものように ansible-playbook コマンドを流してあげれば EC2 インスタンスが作成されるはず。

```bash
$ ansible-playbook -i hosts aws.yml
```

# Ansible で EC2 を作ってみた所感

* いつも Ansible を書く勢いで AWS リソースが作れるので良い
* インスタンスタイプを変更しようと、 instance_type を書き換えて流すと新しいインスタンスが作られるのがちょっと辛い
* 冪等性を担保しようとすると結構辛そう
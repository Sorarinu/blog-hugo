---
title: "AWS EC2 にたてた CentOS サーバを Ansible で判別する"
date: 2020-01-30
categories:
- Ansible
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/ansible.png.webp
summary: "例えば firewalld のコンフィグを Ansible で管理しているけど、 EC2 の場合はセキュリティグループで管理するから除外したいといった時がたまーにある。"
---

例えば firewalld のコンフィグを Ansible で管理しているけど、 EC2 の場合はセキュリティグループで管理するから除外したいといった時がたまーにある。

そんな時は Ansible で対象ホストの fact 情報を取得してあげると良い。

``` bash
$ ansible -i inventory all -m setup
hostname | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "xxx.xxx.xxx.xxx"
        ],
        "ansible_all_ipv6_addresses": [
            "xxxx::xxx:xxxx:xxxx:xxx"
        ],
        "ansible_apparmor": {
            "status": "disabled"
        },
:
:
```

ansible_system_vendor にベンダ情報がのっているので、 AWS EC2 の場合 Playbook を読み込みたくない場合は以下のようにする。

``` yaml
---

- include: firewalld.yml
  when:
    - ansible_distribution == "CentOS"
    - ansible_distribution_major_version == "7"
    - ansible_system_vendor != "Amazon EC2"

- include: iptables.yml
  when:
    - ansible_distribution == "CentOS"
    - ansible_distribution_major_version == "6"
    - ansible_system_vendor != "Amazon EC2"
```
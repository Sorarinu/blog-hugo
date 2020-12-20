---
title: "Ansible で Linux の swapfile を作成して vm.swappiness を設定する"
date: 2020-01-29
categories:
- Ansible
thumbnailImagePosition: left
thumbnailImage: /img/thumbnail/ansible.png.webp
summary: "Linux の swapfile を Ansible で作成して vm.swappiness を設定するための Playbook を作ってみた"
---

Linux の swapfile を Ansible で作成して vm.swappiness を設定するための Playbook を作ってみた

``` yaml
---

- name: stat /swapfile
  stat:
    path: /swapfile
  register: swapfile

- name: dd if=/dev/zero of=/swapfile bs=1024 count=4194304
  command: dd if=/dev/zero of=/swapfile bs=1024 count=4194304
  when: not swapfile.stat.exists

- name: chmod 0600 /swapfile
  file:
    path: /swapfile
    mode: 0600
  ignore_errors: "{{ ansible_check_mode }}"
  when: not swapfile.stat.exists

- name: mkswap /swapfile
  command: mkswap /swapfile
  when: not swapfile.stat.exists

- name: swapon /swapfile
  command: swapon /swapfile
  when: not swapfile.stat.exists

- name: set swapfile in /etc/fstab
  lineinfile:
    path: /etc/fstab
    regexp: '^/swapfile'
    insertafter: 'EOF'
    line: '/swapfile none swap sw 0 0'
  when: swapfile.stat.exists

- name: set vm.swappiness
  lineinfile:
    dest: "/etc/sysctl.conf"
    state: present
    regexp: "^vm.swappiness"
    line: "vm.swappiness={{ swappiness }}"
```

swappiness の値は group_vars とかに書いておけば OK
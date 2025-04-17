#cloud-config
instance-id: ${HOSTNAME}
local-hostname: ${HOSTNAME}

users:
  - name: ubuntu
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
    plain_text_passwd: "ubuntu"
    lock_passwd: false

ssh_pwauth: true
disable_root: false

network:
  version: 2
  ethernets:
    nics:
      match:
        name: ens*
      dhcp-identifier: mac
      dhcp4: yes
      dhcp6: yes


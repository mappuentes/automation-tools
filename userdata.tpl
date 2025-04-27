#cloud-config
instance-id: ${HOSTNAME}
local-hostname: ${HOSTNAME}

users:
  - name: ubuntu
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
    plain_text_passwd: "ubuntu"
    lock_passwd: false
    ssh_authorized_keys:
      - ${SSH_PUBLIC_KEY}

ssh_pwauth: true
disable_root: false

write_files:
  - path: /etc/netplan/50-cloud-init.yaml
    permissions: '0644'
    content: |
      network:
        version: 2
        ethernets:
          ens3:
            addresses:
              - ${IP_ADDRESS}/8
            gateway4: 10.0.0.1
            nameservers:
              addresses:
                - 8.8.8.8
                - 8.8.4.4
runcmd:
  - netplan apply

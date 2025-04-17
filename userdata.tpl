instance-id: ${HOSTNAME}
local-hostname: ${HOSTNAME}
users:
  - name: ubuntu
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
    plain_text_passwd: "ubuntu"  # Aquí se establece la contraseña del usuario
    lock_passwd: false
ssh_pwauth: true  # Habilitar la autenticación por contraseña
disable_root: false  # Si quieres habilitar acceso root (opcional) 
network:
  version: 2
  ethernets:
    nics:
      match:
        name: ens*
      dhcp-identifier: mac
      dhcp4: yes
      dhcp6: yes

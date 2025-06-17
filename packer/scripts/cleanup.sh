#!/bin/bash -eux

echo "==> eliminar claves SSH utilizadas durante la construccion"
rm -f /home/ubuntu/.ssh/authorized_keys
rm -f /root/.ssh/authorized_keys

echo "==> limpiar el identificador unico de la maquina"
truncate -s 0 /etc/machine-id

echo "==> eliminar el contenido de /tmp y /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "==> truncar los registros generados durante la instalacion"
find /var/log -type f -exec truncate --size=0 {} \;

echo "==> limpiar el historial de bash"
rm -f ~/.bash_history

echo "==> eliminar /usr/share/doc/"
rm -rf /usr/share/doc/*

echo "==> eliminar /var/cache"
find /var/cache -type f -exec rm -rf {} \;

echo "==> limpiar apt"
apt-get -y autoremove
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

echo "==> forzar la generacion de una nueva semilla aleatoria"
rm -f /var/lib/systemd/random-seed

echo "==> borrar el historial para que no quede rastro de la instalacion"
rm -f /root/.wget-hsts

export HISTSIZE=0

echo "==> reiniciar cloud-init"
sudo rm -f /etc/cloud/cloud.cfg.d/99-installer.cfg
sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
sudo cloud-init clean



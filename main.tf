terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

provider "libvirt" {
  alias = "gaspar"
  uri   = "qemu:///system"
}
provider "libvirt" {
  alias = "melchor"
  uri   = "qemu+ssh://administrador@10.0.0.11/system?keyfile=~/.ssh/id_rsa_melchor"
}

variable "vm_master" {
  description = "The name of the virtual machine"
  default     = "master"
  type        = string
}

variable "vm_worker1" {
  description = "The name of the virtual machine"
  default     = "worker1"
  type        = string
}

variable "vm_worker2" {
  description = "The name of the virtual machine"
  default     = "worker2"
  type        = string
}

variable "vm_master_ip" {
  default = "10.0.0.100"
}
variable "vm_worker1_ip" {
  default = "10.0.0.101"
}

variable "vm_worker2_ip" {
  default = "10.0.0.102"
}

variable "ssh_ansible_key_master" {
  default = file("~/.ssh/id_rsa_ansible_master.pub")
}

variable "ssh_ansible_key_worker1" {
  default = file("~/.ssh/id_rsa_ansible_worker1.pub")
}

variable "ssh_ansible_key_worker2" {
  default = file("~/.ssh/id_rsa_ansible_worker2.pub")
}

resource "libvirt_volume" "master-qcow2" {
  provider = libvirt.gaspar
  name     = "masterUbuntu20.04"
  pool     = "default"
  source   = "${path.module}/packer/output-focal/ubuntu-focal.img"
  format   = "qcow2"
}

resource "libvirt_volume" "worker1-qcow2" {
  provider = libvirt.melchor
  name     = "worker1Ubuntu20.04"
  pool     = "default"
  source   = "${path.module}/packer/output-focal/ubuntu-focal.img"
  format   = "qcow2"
}

resource "libvirt_volume" "worker2-qcow2" {
  provider = libvirt.gaspar
  name     = "worker2Ubuntu20.04"
  pool     = "default"
  source   = "${path.module}/packer/output-focal/ubuntu-focal.img"
  format   = "qcow2"
}

data "template_file" "user_data_master" {
  template = file("userdata.tpl")
  vars = {
    HOSTNAME       = var.vm_master
    IP_ADDRESS     = var.vm_master_ip
    SSH_PUBLIC_KEY = var.ssh_ansible_key_master
  }
}

resource "libvirt_cloudinit_disk" "cloudinit_master" {
  provider  = libvirt.gaspar
  name      = "${var.vm_master}-cloudinit.iso"
  user_data = data.template_file.user_data_master.rendered
}

data "template_file" "user_data_worker1" {
  template = file("userdata.tpl")
  vars = {
    HOSTNAME       = var.vm_worker1
    IP_ADDRESS     = var.vm_worker1_ip
    SSH_PUBLIC_KEY = var.ssh_ansible_key_worker1
  }
}

resource "libvirt_cloudinit_disk" "cloudinit_worker1" {
  provider  = libvirt.melchor
  name      = "${var.vm_worker1}-cloudinit.iso"
  user_data = data.template_file.user_data_worker1.rendered
}

data "template_file" "user_data_worker2" {
  template = file("userdata.tpl")
  vars = {
    HOSTNAME       = var.vm_worker2
    IP_ADDRESS     = var.vm_worker2_ip
    SSH_PUBLIC_KEY = var.ssh_ansible_key_worker2
  }
}

resource "libvirt_cloudinit_disk" "cloudinit_worker2" {
  provider  = libvirt.gaspar
  name      = "${var.vm_worker2}-cloudinit.iso"
  user_data = data.template_file.user_data_worker2.rendered
}

resource "libvirt_domain" "master" {
  name    = var.vm_master
  memory  = 2048
  vcpu    = 2

  disk {
    volume_id = libvirt_volume.master-qcow2.id
  }

  network_interface {
    bridge    = "br0"
    addresses = [var.vm_master_ip]
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit_master.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}
resource "libvirt_domain" "worker1" {
  provider = libvirt.melchor
  name     = var.vm_worker1
  memory   = 2048
  vcpu     = 2

  disk {
    volume_id = libvirt_volume.worker1-qcow2.id
  }

  network_interface {
    bridge    = "br0"
    addresses = [var.vm_worker1_ip]
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit_worker1.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}

resource "libvirt_domain" "worker2" {
  provider = libvirt.gaspar
  name     = var.vm_worker2
  memory   = 2048
  vcpu     = 2

  disk {
    volume_id = libvirt_volume.worker2-qcow2.id
  }

  network_interface {
    bridge    = "br0"
    addresses = [var.vm_worker2_ip]
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit_worker2.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}

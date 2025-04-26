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
variable "vm_worker" {
  description = "The name of the virtual machine"
  default     = "worker"
  type        = string
}
variable "vm_master_ip" {
  default = "10.0.0.100"
}
variable "vm_worker_ip" {
  default = "10.0.0.101"
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

data "template_file" "user_data_master" {
  template = file("userdata.tpl")
  vars = {
    HOSTNAME   = var.vm_master
    IP_ADDRESS = var.vm_master_ip
  }
}

resource "libvirt_cloudinit_disk" "cloudinit_master" {
  provider  = libvirt.gaspar
  name      = "${var.vm_master}-cloudinit.iso"
  user_data = data.template_file.user_data_master.rendered
}

data "template_file" "user_data_worker" {
  template = file("userdata.tpl")
  vars = {
    HOSTNAME   = var.vm_worker
    IP_ADDRESS = var.vm_worker_ip
  }
}

resource "libvirt_cloudinit_disk" "cloudinit_worker" {
  provider  = libvirt.melchor
  name      = "${var.vm_worker}-cloudinit.iso"
  user_data = data.template_file.user_data_worker.rendered
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
    addresses = ["10.0.0.100"]
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
resource "libvirt_domain" "worker" {
  provider = libvirt.melchor
  name     = var.vm_worker
  memory   = 2048
  vcpu     = 2

  disk {
    volume_id = libvirt_volume.worker1-qcow2.id
  }

  network_interface {
    bridge    = "br0"
    addresses = ["10.0.0.101"]
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit_worker.id

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

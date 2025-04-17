terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

variable "vm_name" {
  description = "The name of the virtual machine"
  default     = "ubuntu"
  type        = string
}

resource "libvirt_volume" "ubuntu-qcow2" {
  name   = "ubuntu20.04"
  pool   = "default"
  source = "${path.module}/packer/output-focal/ubuntu-focal.img"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("userdata.tpl")
  vars = {
    HOSTNAME = var.vm_name
  }
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name      = "${var.vm_name}-cloudinit.iso"
  user_data = data.template_file.user_data.rendered
}

resource "libvirt_domain" "vm" {
  name   = var.vm_name
  memory = 2048
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.ubuntu-qcow2.id
  }

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit.id

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

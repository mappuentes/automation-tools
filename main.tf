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

resource "libvirt_volume" "ubuntu-qcow2" {
  name   = "ubuntu20.04"
  pool   = "default"
  source = "${path.module}/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name      = "cloudinit.iso"
  user_data = data.template_file.user_data.rendered
}

resource "libvirt_domain" "vm" {
  name   = "nodo-prueba"
  memory = "2048"
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.ubuntu-qcow2.id
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit.id

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "vnc"
    listen_type = "address"
  }
}


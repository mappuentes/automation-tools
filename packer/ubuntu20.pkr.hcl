packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

variable "qemu_accelerator" {
  type        = string
  default     = "kvm"
  description = "Variable que permite elegir el accelerator a usar. En Linux se usa kvm y en macOS hvf."
}

variable "ubuntu_version" {
  type        = string
  default     = "focal"
  description = "Variable que permite elegir la version de ubuntu a usar"
}

source "qemu" "ubuntu" {
  accelerator      = var.qemu_accelerator
  cd_files         = ["./cloud-init/*"]
  cd_label         = "cidata"
  disk_compression = true
  disk_image       = true
  disk_size        = "40G"
  headless         = true
  iso_checksum     = "file:https://cloud-images.ubuntu.com/${var.ubuntu_version}/current/SHA256SUMS"
  iso_url          = "https://cloud-images.ubuntu.com/${var.ubuntu_version}/current/${var.ubuntu_version}-server-cloudimg-amd64.img"
  output_directory = "output-${var.ubuntu_version}"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password     = "ubuntu"
  ssh_username     = "ubuntu"
  vm_name          = "ubuntu-${var.ubuntu_version}.img"
  qemuargs = [
    ["-m", "4096M"],
    ["-smp", "4"],
    ["-serial", "mon:stdio"],
  ]
}

build {
  sources = ["source.qemu.ubuntu"]

  provisioner "shell" {
    scripts = [
      "scripts/setup.sh",
      "scripts/cleanup.sh"
    ]
  }
}

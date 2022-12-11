// To get detailed logs, export the following before running packer build:
// export PACKER_LOG_PATH="/var/log/packer.log"
// export PACKER_LOG=10

source "proxmox" "coreos_k3s" {
  // proxmox configuration
  insecure_skip_tls_verify = true
  node = var.proxmox.node
  username = var.proxmox.username
  token = var.proxmox.token
  proxmox_url = var.proxmox.api_url

  # Commands packer enters to boot and start the auto install
  boot_wait = "2s"
  boot_command = [
    "<spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait>",
    "<tab><wait>",
    "<down><down><end>",
    " ignition.config.url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/installer.ign net.ifnames=0",
    "<enter>"
  ]

  # This supplies our installer ignition file
  http_directory = "config"

  # This supplies our template ignition file
  additional_iso_files {
    cd_files = ["./config/template.ign"]
    iso_storage_pool = "local"
    unmount = true
  }

  # CoreOS does not support CloudInit
  cloud_init = false
  qemu_agent = true

  scsi_controller = "virtio-scsi-pci"

  vm_id = "9000"
  cpu_type = "host"
  cores = "2"
  memory = "2048"
  os = "l26"

  vga {
    type = "qxl"
    memory = "16"
  }

  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
  }

  disks {
    disk_size = "45G"
    storage_pool = "local-lvm"
    storage_pool_type = "lvm"
    type = "virtio"
  }

  iso_file = "local:iso/fedora-coreos-37.20221106.3.0-live.x86_64.iso"
  unmount_iso = true
  template_name = "coreos-37.20221106.3.0"
  template_description = "k3s-${var.k3s.version} running on Fedora CoreOS"

  ssh_host = "192.168.1.200"
  ssh_username = "core"
  ssh_private_key_file = "~/.ssh/id_rsa"
  ssh_timeout = "20m"
}

build {
  sources = ["source.proxmox.coreos_k3s"]

  provisioner "shell" {
    inline = [
      "sudo mkdir /tmp/iso",
      "sudo mount /dev/sr1 /tmp/iso -o ro",
      "sudo coreos-installer install /dev/vda --ignition-file /tmp/iso/template.ign",
      # Packer's shutdown command doesn't seem to work, likely because we run qemu-guest-agent
      # inside a docker container.
      # This will shutdown the VM after 1 minute, which is less than the duration that Packer
      # waits for its shutdown command to complete, so it works out.
      "sudo shutdown -h +1"
    ]
  }
}

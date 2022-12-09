resource "proxmox_vm_qemu" "k3s-test-worker" {
  name = "k3s-test-worker"
  desc = "k3s test worker node"
  target_node = var.proxmox.host
  os_type = "cloud-init"
  full_clone = true
  memory = 2048
  sockets = 1
  cores = 2
  cpu = "host"
  scsihw = "virtio-scsi-pci"
  clone = "ubuntu-2204-cloudinit-template"
  agent = 1

  network {
    model = "virtio"
    bridge = "vmbr0"
    tag = 80
  }

  disk {
    type = "virtio"
    storage = "local-lvm"
    size = "51200M"
  }

  # Cloud-init section
  ipconfig0 = "ip=192.168.80.101/24,gw=192.168.80.1"
  ssh_user = "ubuntu"
  sshkeys = file("${path.module}/files/id_rsa.pub")
}

resource "proxmox_vm_qemu" "k3s-test-worker" {
  name = "k3s-test-worker"
  desc = "k3s test worker node"
  target_node = var.proxmox.node
  os_type = "centos"
  full_clone = true
  memory = 6144
  sockets = 1
  cores = 4
  cpu = "host"
  scsihw = "virtio-scsi-pci"
  # clone = "ubuntu-2204-cloudinit-template"
  clone = "coreos-37.20221106.3.0"
  agent = 1

  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  disk {
    type = "virtio"
    storage = "local-lvm"
    size = "45G"
  }
}

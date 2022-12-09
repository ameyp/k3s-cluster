# Disabled because Google charges for a static/ephemeral IP, so the VM is not truly free.
# resource "google_compute_network" "k3s" {
#   project = var.project
#   name = "k3s-network"
#   auto_create_subnetworks = false
#   mtu = 1460
# }

# resource "google_compute_subnetwork" "k3s" {
#   project = var.project
#   name = "k3s-subnet"
#   ip_cidr_range = "10.0.1.0/24"
#   region = "us-west1"
#   network = google_compute_network.k3s.id
# }

# resource "google_compute_firewall" "k3s" {
#   project = var.project
#   name = "k3s-firewall"
#   network = google_compute_network.k3s.name

#   allow {
#     protocol = "tcp"
#     ports = ["22", "6443"]
#   }

#   target_tags = ["k3s"]

#   direction = "INGRESS"
#   source_ranges = ["0.0.0.0/0"]
# }

# resource "google_compute_instance" "k3s" {
#   project = var.project
#   name = "k3s-controller"
#   machine_type = "e2-micro"
#   zone = "us-west1-b"
#   tags = ["ssh", "k3s"]

#   metadata = {
#     "ssh-keys" = format("ubuntu:%s", file("${path.module}/files/id_rsa.pub"))
#   }

#   boot_disk {
#     initialize_params {
#       image = "ubuntu-2204-jammy-v20221201"
#       size = "30"
#       type = "pd-standard"
#     }
#   }

#   scheduling {
#     on_host_maintenance = "MIGRATE"
#     provisioning_model = "STANDARD"
#   }

#   # metadata_startup_script = file("${path.module}/files/startup-script")

#   network_interface {
#     subnetwork = google_compute_subnetwork.k3s.id

#     access_config {
#       # Include this section to give the VM an external IP address
#     }
#   }
# }

module "talos-k8s-cluster" {
  source  = "vdupain/talos-k8s-cluster/proxmox"
  version = "1.6.0"

  cluster = {
    name     = "testcluster"
    network_dhcp = true
    # gateway  = "192.168.10.1"
    # cidr     = 24
    # endpoint = "192.168.10.210"
  }

  vms = {
    "k8s-cp-0" = {
      host_node      = var.PROXMOX_NODENAME
      machine_type   = "controlplane" # or "worker"
      cpu            = 2
      ram_dedicated  = 4096
      os_disk_size   = 10
      data_disk_size = 10
    }
  }

  proxmox = {
    endpoint = "https://${var.PROXMOX_HOST}:8006/"
    api_token = var.PROXMOX_API_TOKEN
    username = var.PROXMOX_USERNAME
    password = var.PROXMOX_PASSWORD
    insecure = true
    ssh_agent = true
  }

}

resource "local_file" "kubeconfig" {
  content = module.talos-k8s-cluster.kubeconfig
  filename = ".kubeconfig.yaml"
  file_permission = "0600"
}

resource "local_file" "talosconfig" {
  content = module.talos-k8s-cluster.talosconfig
  filename = ".talosconfig.yaml"
  file_permission = "0600"
}

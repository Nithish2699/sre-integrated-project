
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "sre_cluster" {
  name     = "sre-cluster"
  location = var.region

  initial_node_count = 1

  #remove_default_node_pool = true

  networking_mode = "VPC_NATIVE"
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  cluster    = google_container_cluster.sre_cluster.name
  location   = var.region

  node_count = 2

  node_config {
    machine_type = "e2-medium"

    disk_type    = "pd-standard"
    disk_size_gb = 50

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}



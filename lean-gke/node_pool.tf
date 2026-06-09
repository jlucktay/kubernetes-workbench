resource "google_container_node_pool" "main" {
  name    = local.name_infix
  cluster = google_container_cluster.main.name
  project = module.google_project_factory.project_id

  location = google_container_cluster.main.location

  initial_node_count = 1

  autoscaling {
    location_policy = "BALANCED"

    min_node_count = 1
    max_node_count = 3
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "e2-medium"

    service_account = google_service_account.main.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    spot = true

    boot_disk {
      disk_type = "pd-standard"

      size_gb = 40
    }

    kubelet_config {
      insecure_kubelet_readonly_port_enabled = "FALSE"
    }

    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }

    labels = {
      "lean-gke.jlucktay.dev/cluster-name"     = google_container_cluster.main.name
      "lean-gke.jlucktay.dev/cluster-location" = google_container_cluster.main.location
      "lean-gke.jlucktay.dev/project"          = module.google_project_factory.project_id
    }
  }

  upgrade_settings {
    strategy = "SURGE"

    max_surge       = 1
    max_unavailable = 1
  }
}

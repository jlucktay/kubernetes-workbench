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

    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }
  }

  upgrade_settings {
    strategy = "SURGE"

    max_surge       = 1
    max_unavailable = 1
  }
}

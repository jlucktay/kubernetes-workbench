data "google_compute_zones" "available" {
  project = module.google_project_factory.project_id
  region  = var.region
}

resource "random_shuffle" "zone" {
  input = data.google_compute_zones.available.names

  result_count = 1
}

resource "google_container_cluster" "main" {
  name    = local.name_infix
  project = module.google_project_factory.project_id

  deletion_protection = false

  # Set to a single zone to have a (free tier) Standard zonal cluster.
  location = one(random_shuffle.zone.result)

  # Nodes for the zonal cluster can also be in other zones in the same region, but this set can't overlap.
  node_locations = setsubtract(data.google_compute_zones.available.names, random_shuffle.zone.result)

  # We can't create a cluster with no node pool defined, but we want to only use separately managed node pools.
  # So we create the smallest possible default node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = module.google_network.network_self_link
  subnetwork = one(module.google_network.subnets_self_links)

  # Access control
  control_plane_endpoints_config {
    dns_endpoint_config {
      allow_external_traffic = true
    }
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_auth_cidr_ranges

      content {
        cidr_block   = cidr_blocks.value["cidr_block"]
        display_name = cidr_blocks.value["display_name"]
      }
    }
  }

  # Networking
  ip_allocation_policy {
    cluster_secondary_range_name  = local.pods_range_name
    services_secondary_range_name = local.svc_range_name
  }

  # Cost saving
  # https://hodovi.cc/blog/gke-on-a-budget-disabling-expensive-defaults-for-leaner-clusters/
  logging_service    = "none"
  monitoring_service = "none"

  addons_config {
    gke_backup_agent_config {
      enabled = false
    }
  }

  cost_management_config {
    enabled = false
  }

  network_policy {
    enabled = false
  }

  vertical_pod_autoscaling {
    enabled = false
  }
}

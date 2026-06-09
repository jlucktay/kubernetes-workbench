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

  ### Cluster-wide settings
  deletion_protection = false

  # Set to a single zone to have a (free tier) Standard zonal cluster.
  location = one(random_shuffle.zone.result)

  # Weekly upgrade cadence.
  release_channel {
    channel = "RAPID"
  }

  gke_auto_upgrade_config {
    patch_mode = "ACCELERATED"
  }

  ### Networking
  network    = module.google_network.network_id
  subnetwork = one(module.google_network.subnets_ids)

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = local.pods_range_name
    services_secondary_range_name = local.services_range_name

    stack_type = "IPV4"

    network_tier_config {
      network_tier = "NETWORK_TIER_STANDARD"
    }
  }

  ### Node setup
  # Nodes for the zonal cluster can also be in other zones in the same region, but this set can't overlap.
  node_locations = setsubtract(data.google_compute_zones.available.names, random_shuffle.zone.result)

  # We can't create a cluster with no node pool defined, but we want to only use separately managed node pools.
  # So we create the smallest possible default node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  cluster_autoscaling {
    enabled = false
  }

  ### Security and encryption
  datapath_provider            = "ADVANCED_DATAPATH"
  in_transit_encryption_config = "IN_TRANSIT_ENCRYPTION_INTER_NODE_TRANSPARENT"

  ### Access control
  anonymous_authentication_config {
    mode = "LIMITED"
  }

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

  ### Cost saving
  # https://hodovi.cc/blog/gke-on-a-budget-disabling-expensive-defaults-for-leaner-clusters/
  logging_service    = "none"
  monitoring_service = "none"

  enable_tpu = false

  addons_config {
    dns_cache_config {
      enabled = false
    }

    gce_persistent_disk_csi_driver_config {
      enabled = false
    }

    gke_backup_agent_config {
      enabled = false
    }
  }

  cost_management_config {
    enabled = false
  }

  default_snat_status {
    disabled = true
  }

  network_policy {
    enabled = false
  }

  vertical_pod_autoscaling {
    enabled = false
  }
}

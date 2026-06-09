locals {
  pods_range_name     = format("%s-pods", local.name)
  services_range_name = format("%s-services", local.name)
}

module "google_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 18.1"

  project_id   = module.google_project_factory.project_id
  network_name = local.name

  subnets = [
    {
      subnet_name           = local.name
      subnet_ip             = "172.27.0.0/16"
      subnet_region         = var.region
      subnet_private_access = true
    },
  ]

  secondary_ranges = {
    (local.name) = [
      {
        range_name    = local.pods_range_name
        ip_cidr_range = "172.28.0.0/16"
      },
      {
        range_name    = local.services_range_name
        ip_cidr_range = "172.29.0.0/16"
      },
    ]
  }
}

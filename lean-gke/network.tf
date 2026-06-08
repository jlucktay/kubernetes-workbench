locals {
  pods_range_name = format("%s-ip-range-pods", local.name)
  svc_range_name  = format("%s-ip-range-svc", local.name)
}

module "google_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 18.1"

  project_id   = module.google_project_factory.project_id
  network_name = local.name

  subnets = [
    {
      subnet_name           = local.name
      subnet_ip             = "10.0.0.0/16"
      subnet_region         = var.region
      subnet_private_access = true
    },
  ]

  secondary_ranges = {
    (local.name) = [
      {
        range_name    = local.pods_range_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = local.svc_range_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

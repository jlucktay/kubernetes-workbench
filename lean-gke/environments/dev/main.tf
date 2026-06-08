module "this" {
  source = "../.."

  billing_account = var.billing_account
  organisation_id = var.organisation_id
  folder_id       = var.folder_id

  environment = var.environment
  name_prefix = var.name_prefix

  region = var.region

  master_auth_cidr_ranges = var.master_auth_cidr_ranges
}

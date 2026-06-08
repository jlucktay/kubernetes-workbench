locals {
  name_infix = "lean-gke"
  name       = format("%s-%s-%s", var.name_prefix, local.name_infix, var.environment)
}

module "google_project_factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 18.0"

  billing_account = var.billing_account
  org_id          = var.organisation_id
  folder_id       = var.folder_id

  name       = format("Lean GKE - %s", var.environment)
  project_id = local.name

  create_project_sa = false
  random_project_id = true

  random_project_id_length = 7

  default_service_account = "deprivilege"
  deletion_policy         = "DELETE"

  disable_dependent_services  = true
  disable_services_on_destroy = true

  activate_apis = [
    "container.googleapis.com",
  ]
}

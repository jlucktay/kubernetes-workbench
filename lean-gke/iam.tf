resource "google_service_account" "main" {
  account_id = "compute"
  project    = module.google_project_factory.project_id
}

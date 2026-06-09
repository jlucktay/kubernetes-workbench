output "cmd_credentials" {
  description = "Command line to retrieve credentials for the GKE cluster."

  value = format(
    "gcloud container clusters get-credentials %s --dns-endpoint --location=%s --project=%s",
    google_container_cluster.main.name,
    google_container_cluster.main.location,
    google_container_cluster.main.project,
  )
}

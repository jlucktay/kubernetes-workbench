output "cmd_credentials" {
  description = "Command line to retrieve credentials for the GKE cluster."

  value = module.this.cmd_credentials
}

output "cmd_set_project" {
  description = "Command line to set default Google Cloud CLI project to that of the GKE cluster."

  value = module.this.cmd_set_project
}

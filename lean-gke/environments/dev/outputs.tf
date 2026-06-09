output "cmd_credentials" {
  description = "Command line to retrieve credentials for the GKE cluster."

  value = module.this.cmd_credentials
}

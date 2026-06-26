locals {
  include_security_rule_allow_home = anytrue([for macr in var.master_auth_cidr_ranges : contains(["Home"], macr.display_name)])

  security_rule_allow_home = {
    description = "Allowlist for 'Home' IP address"

    action   = "allow"
    priority = 1000

    src_ip_ranges = [for macr in var.master_auth_cidr_ranges : macr.cidr_block if macr.display_name == "Home"]
  }

  security_rule_rate_limit = {
    description = "Rate limiting to prevent abuse and mitigate Brute Force / DDoS, with ban if fingerprinted client crosses threshold"

    action   = "rate_based_ban"
    priority = 2000

    src_ip_ranges = ["*"]

    rate_limit_options = {
      exceed_action = "deny(429)"

      # JA4 TLS/SSL fingerprint if the client connects using HTTPS, HTTP/2 or HTTP/3.
      # If not available, the key type defaults to ALL.
      # For more information about JA4, see:
      # - the rules language reference: https://docs.cloud.google.com/armor/docs/rules-language-reference#attributes
      # - https://github.com/FoxIO-LLC/ja4
      enforce_on_key = "TLS_JA4_FINGERPRINT"

      # Allow 100 requests per second per fingerprint.
      rate_limit_http_request_count        = 6000
      rate_limit_http_request_interval_sec = 60

      ban_duration_sec              = 600
      ban_http_request_count        = 1000
      ban_http_request_interval_sec = 300
    }
  }

  security_rules = merge(
    {
      "rate_limit" = local.security_rule_rate_limit,
    },
    local.include_security_rule_allow_home ? {
      "allow_home" = local.security_rule_allow_home,
    } : {}
  )
}

module "google_cloud_armor" {
  source  = "GoogleCloudPlatform/cloud-armor/google"
  version = "~> 8.1"

  project_id  = module.google_project_factory.project_id
  name        = local.name
  description = "WAF and DDoS protection policy for GKE"

  type = "CLOUD_ARMOR"

  # Default: deny all traffic not explicitly matched by other rules.
  default_rule_action = "deny(403)"

  layer_7_ddos_defense_enable          = true
  layer_7_ddos_defense_rule_visibility = "STANDARD"

  security_rules = local.security_rules

  pre_configured_rules = {
    "sqli_protection" = {
      description = "OWASP Top 10: Block SQL injection (SQLi) attacks"

      action   = "deny(403)"
      priority = 3000

      target_rule_set = "sqli-v33-stable"
    }

    "xss_protection" = {
      description = "OWASP Top 10: Block Cross-Site Scripting (XSS) attacks"

      action   = "deny(403)"
      priority = 3001

      target_rule_set = "xss-v33-stable"
    }

    "rce_protection" = {
      description = "OWASP Top 10: Block Remote Code Execution (RCE)"

      action   = "deny(403)"
      priority = 3002

      target_rule_set = "rce-v33-stable"
    }
  }
}

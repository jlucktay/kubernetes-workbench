variable "billing_account" {
  description = "The ID of the billing account that the Google Cloud project will be attached to, in the format of 'A1B2C3-D4E5F6-G7H8I9'."
  type        = string

  validation {
    condition     = can(regex("^[0-9A-Z]{6}-[0-9A-Z]{6}-[0-9A-Z]{6}$", var.billing_account))
    error_message = "The 'var.billing_account' input variable must be in the format of 'A1B2C3-D4E5F6-G7H8I9'."
  }
}

variable "organisation_id" {
  description = "The numeric ID of the Google Cloud organisation that the project will be part of."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.organisation_id))
    error_message = "The 'var.organisation_id' input variable must be numeric."
  }
}

variable "folder_id" {
  description = "The numeric ID of the folder that the Google Cloud project will be stored under in the organisation."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.folder_id))
    error_message = "The 'var.folder_id' input variable must be numeric."
  }
}

variable "environment" {
  description = "The environment that this project represents, e.g. 'dev', 'staging', 'prod'."
  type        = string
}

variable "region" {
  description = "Google Cloud region to provision resources in."
  type        = string
}

variable "master_auth_cidr_ranges" {
  description = "CIDR ranges that can access the Kubernetes master."

  type = list(
    object({
      display_name = string
      cidr_block   = string
    })
  )

  validation {
    condition     = alltrue([for macr in var.master_auth_cidr_ranges : length(macr.display_name) > 0])
    error_message = "The 'display_name' field for all items in the 'var.master_auth_cidr_ranges' input variable list must be a string longer than zero characters."
  }

  validation {
    condition     = alltrue([for macr in var.master_auth_cidr_ranges : can(cidrnetmask(macr.cidr_block))])
    error_message = "The 'cidr_block' field for all items in the 'var.master_auth_cidr_ranges' input variable list must be given in valid IPv4 CIDR notation."
  }
}

variable "name_prefix" {
  description = "Resource slugs and IDs will be prefixed with this value."
  type        = string
}

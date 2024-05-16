# User / PASS come from PM_USER / PM_PASS env variables
variable "pm_api_url" {
  description = "Adress of proxmox api"
  type        = string
}

variable "instance_config" {
  description = "Path to instance_config yaml"
  type        = string
}

variable "env_defaults" {
  description = "Path to env_defaults yaml"
  type        = string
}

variable "password" {
  description = "Password for the container"
  type        = string
  default     = null
}

variable "working_dir" {
  description = "Directory to find and create files"
  type        = string
}

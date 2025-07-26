variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "región donde se localiza el grupo de recursos."
}

variable "acr_repositorios" {
  type = list(string)
  default = ["cp2"]
}


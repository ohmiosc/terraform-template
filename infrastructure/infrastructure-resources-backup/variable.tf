variable "region" {
  default     = "us-east-1"
  type        = string
  description = "AWS Region"
}

variable "product" {
  default     = "infrastructure"
  type        = string
  description = "The name of the product."
}

variable "environment" {
  default     = "production"
  type        = string
  description = "The envrionment where it will be deployed"

}

variable "environment_prefix" {
  default     = "prod"
  type        = string
  description = "The envrionment prefix where it will be deployed"
}

variable "service" {
  default     = "resources-backup"
  type        = string
  description = "The name service create"
}
### CRITERIO DEL FILTRO X TAG ####
variable "filter_key_tag" {
  default     = "tag:ssm"
  type        = string
  description = "The key Tag"
}

variable "filter_value_tag" {
  default     = "shutdown"
  type        = string
  description = "The value Tag"
}
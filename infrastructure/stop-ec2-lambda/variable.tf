variable "region" {
  default     = "eu-west-1"
  type        = string
  description = "AWS Region"
}

variable "product" {
  default     = "test"
  type        = string
  description = "The name of the product."
}

variable "environment" {
  default     = "development"
  type        = string
  description = "The envrionment where it will be deployed"

}

variable "environment_prefix" {
  default     = "dev"
  type        = string
  description = "The envrionment prefix where it will be deployed"
}

variable "service" {
  default     = "service"
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
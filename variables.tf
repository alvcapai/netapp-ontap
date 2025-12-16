variable "ibmcloud_api_key" {
  description = "Chave de API da IBM Cloud."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Região onde os recursos serão criados."
  type        = string
  default     = "us-south"
}

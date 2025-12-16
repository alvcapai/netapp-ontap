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

variable "zone" {
  description = "Zona onde a instância será criada."
  type        = string
  default     = "us-south-1"
}

variable "resource_group_name" {
  description = "Nome do resource group."
  type        = string
  default     = "netapp-rg"
}

variable "vpc_name" {
  description = "Nome da VPC."
  type        = string
  default     = "netapp-vpc"
}

variable "subnet_cidr" {
  description = "CIDR da subnet."
  type        = string
  default     = "10.10.1.0/24"
}

variable "ssh_key_name" {
  description = "Nome da chave SSH cadastrada no IBM Cloud."
  type        = string
  validation {
    condition     = var.ssh_key_name != ""
    error_message = "Defina ssh_key_name."
  }
}

variable "ssh_public_key" {
  description = "Conteúdo da chave pública SSH."
  type        = string
  validation {
    condition     = var.ssh_public_key != ""
    error_message = "Defina ssh_public_key."
  }
}

variable "use_existing_ssh_key" {
  description = "Se true, reutiliza a chave pelo nome; se false, cria usando ssh_public_key."
  type        = bool
  default     = true
}
variable "instance_name" {
  description = "Nome da instância."
  type        = string
  default     = "netapp-instance"
}

variable "instance_profile" {
  description = "Perfil da instância."
  type        = string
  default     = "bx2-4x16"
}

variable "instance_image_name" {
  description = "Nome da imagem base da instância."
  type        = string
  default     = "ibm-ubuntu-22-04-5-minimal-amd64-3"
}

variable "cos_instance_name" {
  description = "Nome da instância de Cloud Object Storage."
  type        = string
  default     = "netapp-cos"
}

variable "cos_bucket_name" {
  description = "Nome do bucket para armazenar imagens."
  type        = string
  default     = "images-netapp"
}

variable "converter_output_object_key" {
  description = "Nome do objeto QCOW2 gerado ao enviar para o COS."
  type        = string
  default     = "converted.qcow2"
}

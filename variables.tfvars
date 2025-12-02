###############################################
# IBM Cloud - Credenciais e Região
###############################################

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

###############################################
# Configuração da VPC e Rede
###############################################

variable "vpc_name" {
  description = "Nome da VPC para o ambiente ONTAP."
  type        = string
  default     = "ontap-vpc"
}

variable "mgmt_subnet_cidr" {
  description = "CIDR da subnet de gerenciamento."
  type        = string
  default     = "10.10.1.0/24"
}

variable "data_subnet_cidr" {
  description = "CIDR da subnet de dados."
  type        = string
  default     = "10.10.2.0/24"
}

variable "zone" {
  description = "Zona da VPC onde os recursos serão provisionados."
  type        = string
  default     = "us-south-1"
}

###############################################
# Chaves SSH
###############################################

variable "ssh_key_name" {
  description = "Nome da chave SSH cadastrada no IBM Cloud."
  type        = string
}

###############################################
# ONTAP Nodes
###############################################

variable "deploy_ontap_nodes" {
  description = "Quantidade de nós ONTAP (1 = single, 2 = HA)."
  type        = number
  default     = 1
  validation {
    condition     = var.deploy_ontap_nodes == 1 || var.deploy_ontap_nodes == 2
    error_message = "Somente valores 1 ou 2 são permitidos."
  }
}

variable "ontap_image_id" {
  description = "ID da imagem customizada ONTAP Select no IBM Cloud."
  type        = string
}

variable "ontap_profile" {
  description = "Flavor/profile do VSI para rodar ONTAP."
  type        = string
  default     = "bx2-8x32"
}

variable "boot_volume_size" {
  description = "Tamanho do disco de boot para o ONTAP."
  type        = number
  default     = 100
}

###############################################
# Discos de dados (volumes para agregados ONTAP)
###############################################

variable "data_disks_per_node" {
  description = "Quantidade de discos de dados por nó ONTAP."
  type        = number
  default     = 3
}

variable "data_disk_size" {
  description = "Tamanho de cada volume de dados em GB."
  type        = number
  default     = 500
}

variable "data_disk_profile" {
  description = "Perfil do volume (general-purpose, 5iops-tier, etc.)."
  type        = string
  default     = "general-purpose"
}

###############################################
# Segurança
###############################################

variable "allowed_ssh_cidr" {
  description = "CIDR permitido para acessar o SSH."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_https_cidr" {
  description = "CIDR permitido para acessar System Manager ONTAP."
  type        = string
  default     = "0.0.0.0/0"
}

###############################################
# NFS / SMB / iSCSI Ports
###############################################

variable "enable_nfs" {
  description = "Habilitar portas NFS no Security Group"
  type        = bool
  default     = false
}

variable "enable_smb" {
  description = "Habilitar SMB (CIFS)."
  type        = bool
  default     = false
}

variable "enable_iscsi" {
  description = "Habilitar iSCSI (porta 3260)."
  type        = bool
  default     = false
}

###############################################
# Tags e Organização
###############################################

variable "environment" {
  description = "Tag para identificar ambiente (lab, dev, prod)."
  type        = string
  default     = "lab"
}

variable "resource_prefix" {
  description = "Prefixo para identificar os recursos do cluster."
  type        = string
  default     = "ontap"
}

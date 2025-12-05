###############################################
# IBM Cloud - Credenciais e Região
###############################################

variable "ibmcloud_api_key" {
  description = "Chave de API da IBM Cloud."
  type        = string
  sensitive   = true
}

variable "cos_only" {
  description = "Se true, cria apenas COS; execute novamente com false após enviar a imagem para continuar o deploy."
  type        = bool
  default     = false
}

variable "region" {
  description = "Região onde os recursos serão criados."
  type        = string
  default     = "us-south"
}

variable "resource_group_name" {
  description = "Nome do resource group a ser criado e usado em todos os recursos."
  type        = string
  default     = "ontap-rg"
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
  default     = ""
  validation {
    condition     = var.cos_only || var.ssh_key_name != ""
    error_message = "Defina ssh_key_name para implantar a infraestrutura."
  }
}

variable "ssh_public_key" {
  description = "Conteúdo da chave pública SSH."
  type        = string
  default     = ""
  validation {
    condition     = var.cos_only || var.ssh_public_key != ""
    error_message = "Defina ssh_public_key para implantar a infraestrutura."
  }
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
  default     = ""
  validation {
    condition     = var.cos_only || var.ontap_image_id != ""
    error_message = "Defina ontap_image_id para implantar a infraestrutura."
  }
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

###############################################
# Cloud Object Storage para imagem ONTAP
###############################################

variable "cos_instance_name" {
  description = "Nome da instância de Cloud Object Storage."
  type        = string
  default     = "ontap-cos"
}

variable "cos_bucket_name" {
  description = "Nome do bucket onde a imagem ONTAP será enviada."
  type        = string
  default     = "ontap-image-bucket"
}

variable "cos_resource_group" {
  description = "Nome do resource group para a instância de COS."
  type        = string
  default     = "Default"
}

variable "cos_location" {
  description = "Localização da instância de COS (normalmente 'global')."
  type        = string
  default     = "global"
}

variable "ontap_image_object_key" {
  description = "Nome do objeto (key) da imagem ONTAP no bucket COS."
  type        = string
  default     = "ontap-image.qcow2"
}

variable "ontap_image_file" {
  description = "Caminho local para o arquivo de imagem ONTAP a ser enviado ao COS."
  type        = string
  default     = ""
}

variable "upload_local_image" {
  description = "Se true, envia o arquivo local ontap_image_file para o COS."
  type        = bool
  default     = false
}

###############################################
# Conversão OVA -> QCOW2 (máquina helper)
###############################################

variable "converter_instance_name" {
  description = "Nome da instância helper para converter OVA em QCOW2."
  type        = string
  default     = "ontap-image-converter"
}

variable "converter_profile" {
  description = "Perfil da instância helper."
  type        = string
  default     = "bx2-4x16"
}

variable "converter_base_image_name" {
  description = "Nome da imagem base (ex: Ubuntu) para a instância helper."
  type        = string
  default     = "ibm-ubuntu-22-04-3-minimal-amd64-3"
}

variable "converter_ssh_key_name" {
  description = "Nome da chave SSH para acessar a instância helper."
  type        = string
  default     = ""
  validation {
    condition     = var.cos_only || var.converter_ssh_key_name != ""
    error_message = "Defina converter_ssh_key_name para implantar a instância helper."
  }
}

variable "converter_ssh_public_key" {
  description = "Conteúdo da chave pública para a instância helper."
  type        = string
  default     = ""
  validation {
    condition     = var.cos_only || var.converter_ssh_public_key != ""
    error_message = "Defina converter_ssh_public_key para implantar a instância helper."
  }
}

variable "converter_subnet" {
  description = "Subnet ID para a instância helper (use a mgmt subnet)."
  type        = string
  default     = ""
}

variable "converter_security_group" {
  description = "Security group ID para a instância helper."
  type        = string
  default     = ""
}

variable "converter_zone" {
  description = "Zona para a instância helper (normalmente igual à zona principal)."
  type        = string
  default     = "us-south-1"
}

variable "converter_source_ova_url" {
  description = "URL HTTP/HTTPS do OVA de origem para converter."
  type        = string
  default     = ""
  validation {
    condition     = var.cos_only || var.converter_source_ova_url != "" || (var.converter_source_bucket != "" && var.converter_source_object_key != "")
    error_message = "Defina converter_source_ova_url ou (converter_source_bucket e converter_source_object_key) para a origem do OVA."
  }
}

variable "converter_source_bucket" {
  description = "Bucket COS onde o OVA de origem está armazenado (alternativa ao converter_source_ova_url)."
  type        = string
  default     = ""
}

variable "converter_source_object_key" {
  description = "Key do OVA de origem no COS (alternativa ao converter_source_ova_url)."
  type        = string
  default     = ""
}

variable "converter_output_object_key" {
  description = "Key do objeto QCOW2 gerado no COS."
  type        = string
  default     = "ontap-image.qcow2"
}

variable "converter_cos_bucket" {
  description = "Bucket destino no COS para o QCOW2 gerado."
  type        = string
  default     = ""
  validation {
    condition     = var.cos_only || var.converter_cos_bucket != ""
    error_message = "Defina converter_cos_bucket com o bucket de destino."
  }
}

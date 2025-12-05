resource "ibm_is_vpc" "ontap_vpc" {
  count          = local.infra_count
  name           = var.vpc_name
  resource_group = ibm_resource_group.rg.id
}

resource "ibm_is_vpc_address_prefix" "mgmt" {
  count          = local.infra_count
  name           = "${var.resource_prefix}-mgmt-prefix"
  zone           = var.zone
  vpc            = ibm_is_vpc.ontap_vpc[0].id
  cidr           = var.mgmt_subnet_cidr
}

resource "ibm_is_vpc_address_prefix" "data" {
  count          = local.infra_count
  name           = "${var.resource_prefix}-data-prefix"
  zone           = var.zone
  vpc            = ibm_is_vpc.ontap_vpc[0].id
  cidr           = var.data_subnet_cidr
}

resource "ibm_is_subnet" "mgmt" {
  count           = local.infra_count
  name            = "${var.resource_prefix}-mgmt-subnet"
  vpc             = ibm_is_vpc.ontap_vpc[0].id
  zone            = var.zone
  ipv4_cidr_block = var.mgmt_subnet_cidr
  resource_group  = ibm_resource_group.rg.id
}

resource "ibm_is_subnet" "data" {
  count           = local.infra_count
  name            = "${var.resource_prefix}-data-subnet"
  vpc             = ibm_is_vpc.ontap_vpc[0].id
  zone            = var.zone
  ipv4_cidr_block = var.data_subnet_cidr
  resource_group  = ibm_resource_group.rg.id
}

resource "ibm_is_security_group" "ontap_sg" {
  count          = local.infra_count
  name           = "${var.resource_prefix}-sg"
  vpc            = ibm_is_vpc.ontap_vpc[0].id
  resource_group = ibm_resource_group.rg.id
}

# SSH
resource "ibm_is_security_group_rule" "ssh_in" {
  count     = local.infra_count
  group     = ibm_is_security_group.ontap_sg[0].id
  direction = "inbound"
  remote    = var.allowed_ssh_cidr
  tcp {
    port_min = 22
    port_max = 22
  }
}

# HTTPS (System Manager ONTAP)
resource "ibm_is_security_group_rule" "https_in" {
  count     = local.infra_count
  group     = ibm_is_security_group.ontap_sg[0].id
  direction = "inbound"
  remote    = var.allowed_https_cidr
  tcp {
    port_min = 443
    port_max = 443
  }
}

# Optional data protocols
resource "ibm_is_security_group_rule" "nfs_in" {
  count     = local.infra_count == 1 && var.enable_nfs ? 1 : 0
  group     = ibm_is_security_group.ontap_sg[0].id
  direction = "inbound"
  remote    = var.allowed_https_cidr
  tcp {
    port_min = 2049
    port_max = 2049
  }
}

resource "ibm_is_security_group_rule" "smb_in" {
  count     = local.infra_count == 1 && var.enable_smb ? 1 : 0
  group     = ibm_is_security_group.ontap_sg[0].id
  direction = "inbound"
  remote    = var.allowed_https_cidr
  tcp {
    port_min = 445
    port_max = 445
  }
}

resource "ibm_is_security_group_rule" "iscsi_in" {
  count     = local.infra_count == 1 && var.enable_iscsi ? 1 : 0
  group     = ibm_is_security_group.ontap_sg[0].id
  direction = "inbound"
  remote    = var.allowed_https_cidr
  tcp {
    port_min = 3260
    port_max = 3260
  }
}

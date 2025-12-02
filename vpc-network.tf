resource "ibm_is_vpc" "ontap_vpc" {
  name = var.vpc_name
}

resource "ibm_is_subnet" "mgmt" {
  name            = "${var.resource_prefix}-mgmt-subnet"
  vpc             = ibm_is_vpc.ontap_vpc.id
  zone            = var.zone
  ipv4_cidr_block = var.mgmt_subnet_cidr
}

resource "ibm_is_subnet" "data" {
  name            = "${var.resource_prefix}-data-subnet"
  vpc             = ibm_is_vpc.ontap_vpc.id
  zone            = var.zone
  ipv4_cidr_block = var.data_subnet_cidr
}

resource "ibm_is_security_group" "ontap_sg" {
  name = "${var.resource_prefix}-sg"
  vpc  = ibm_is_vpc.ontap_vpc.id
}

# SSH
resource "ibm_is_security_group_rule" "ssh_in" {
  group     = ibm_is_security_group.ontap_sg.id
  direction = "inbound"
  remote    = var.allowed_ssh_cidr
  tcp {
    port_min = 22
    port_max = 22
  }
}

# HTTPS (System Manager ONTAP)
resource "ibm_is_security_group_rule" "https_in" {
  group     = ibm_is_security_group.ontap_sg.id
  direction = "inbound"
  remote    = var.allowed_https_cidr
  tcp {
    port_min = 443
    port_max = 443
  }
}

# Optional data protocols
resource "ibm_is_security_group_rule" "nfs_in" {
  count     = var.enable_nfs ? 1 : 0
  group     = ibm_is_security_group.ontap_sg.id
  direction = "inbound"
  remote    = var.allowed_https_cidr
  tcp {
    port_min = 2049
    port_max = 2049
  }
}

resource "ibm_is_security_group_rule" "smb_in" {
  count     = var.enable_smb ? 1 : 0
  group     = ibm_is_security_group.ontap_sg.id
  direction = "inbound"
  remote    = var.allowed_https_cidr
  tcp {
    port_min = 445
    port_max = 445
  }
}

resource "ibm_is_security_group_rule" "iscsi_in" {
  count     = var.enable_iscsi ? 1 : 0
  group     = ibm_is_security_group.ontap_sg.id
  direction = "inbound"
  remote    = var.allowed_https_cidr
  tcp {
    port_min = 3260
    port_max = 3260
  }
}

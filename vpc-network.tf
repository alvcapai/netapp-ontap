resource "ibm_is_vpc" "ontap_vpc" {
  name = "ontap-vpc"
}

resource "ibm_is_subnet" "mgmt" {
  name            = "ontap-mgmt-subnet"
  vpc             = ibm_is_vpc.ontap_vpc.id
  zone            = "us-south-1"
  ipv4_cidr_block = "10.10.1.0/24"
}

resource "ibm_is_subnet" "data" {
  name            = "ontap-data-subnet"
  vpc             = ibm_is_vpc.ontap_vpc.id
  zone            = "us-south-1"
  ipv4_cidr_block = "10.10.2.0/24"
}

resource "ibm_is_security_group" "ontap_sg" {
  name = "ontap-sg"
  vpc  = ibm_is_vpc.ontap_vpc.id
}

# SSH
resource "ibm_is_security_group_rule" "ssh_in" {
  group     = ibm_is_security_group.ontap_sg.id
  direction = "inbound"
  tcp {
    port_min = 22
    port_max = 22
  }
}

# HTTPS (System Manager ONTAP)
resource "ibm_is_security_group_rule" "https_in" {
  group     = ibm_is_security_group.ontap_sg.id
  direction = "inbound"
  tcp {
    port_min = 443
    port_max = 443
  }
}

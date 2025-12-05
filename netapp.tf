data "ibm_is_ssh_key" "ssh" {
  name = var.ssh_key_name
}

resource "ibm_is_instance" "ontap_node1" {
  name    = "${var.resource_prefix}-ontap-node1"
  image   = var.ontap_image_id
  profile = var.ontap_profile
  zone    = var.zone

  primary_network_interface {
    subnet           = ibm_is_subnet.mgmt.id
    security_groups  = [ibm_is_security_group.ontap_sg.id]
  }

  network_interfaces {
    subnet          = ibm_is_subnet.data.id
    security_groups = [ibm_is_security_group.ontap_sg.id]
  }

  vpc  = ibm_is_vpc.ontap_vpc.id
  keys = [data.ibm_is_ssh_key.ssh.id]

  boot_volume {
    name = "${var.resource_prefix}-ontap-node1-boot"
    capacity = var.boot_volume_size
  }

  user_data = file("${path.module}/cloud-init-ontap-node1.yaml")
}

resource "ibm_is_volume" "ontap_node1_data" {
  count    = var.data_disks_per_node
  name     = "${var.resource_prefix}-ontap-node1-data-${count.index + 1}"
  profile  = var.data_disk_profile
  capacity = var.data_disk_size
  zone     = var.zone
}

resource "ibm_is_volume_attachment" "ontap_node1_data_attach" {
  count    = var.data_disks_per_node
  instance = ibm_is_instance.ontap_node1.id
  volume   = ibm_is_volume.ontap_node1_data[count.index].id
}

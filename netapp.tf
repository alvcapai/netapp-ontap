resource "ibm_is_ssh_key" "ssh" {
  count          = local.ontap_count
  name           = var.ssh_key_name
  public_key     = var.ssh_public_key
  resource_group = ibm_resource_group.rg.id
}

resource "ibm_is_instance" "ontap_node1" {
  count   = local.ontap_count
  name    = "${var.resource_prefix}-ontap-node1"
  image   = var.ontap_image_id
  profile = var.ontap_profile
  zone    = var.zone

  primary_network_interface {
    subnet          = ibm_is_subnet.mgmt[0].id
    security_groups = [ibm_is_security_group.ontap_sg[0].id]
  }

  network_interfaces {
    subnet          = ibm_is_subnet.data[0].id
    security_groups = [ibm_is_security_group.ontap_sg[0].id]
  }

  vpc            = ibm_is_vpc.ontap_vpc[0].id
  keys           = [ibm_is_ssh_key.ssh[0].id]
  resource_group = ibm_resource_group.rg.id

  boot_volume {
    name = "${var.resource_prefix}-ontap-node1-boot"
    size = var.boot_volume_size
  }

  user_data = file("${path.module}/cloud-init-ontap-node1.yaml")
}

resource "ibm_is_volume" "ontap_node1_data" {
  count    = local.ontap_enabled ? var.data_disks_per_node : 0
  name     = "${var.resource_prefix}-ontap-node1-data-${count.index + 1}"
  profile  = var.data_disk_profile
  capacity = var.data_disk_size
  zone     = var.zone
  resource_group = ibm_resource_group.rg.id
}

resource "ibm_is_instance_volume_attachment" "ontap_node1_data_attach" {
  count    = local.ontap_enabled ? var.data_disks_per_node : 0
  instance = ibm_is_instance.ontap_node1[0].id
  volume   = ibm_is_volume.ontap_node1_data[count.index].id
}

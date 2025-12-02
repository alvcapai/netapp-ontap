resource "ibm_is_instance" "ontap_node1" {
  name    = "ontap-node1"
  image   = var.ontap_image_id   # imagem customizada com ONTAP/ontap-select
  profile = "bx2-8x32"
  zone    = "us-south-1"

  primary_network_interface {
    subnet         = var.mgmt_subnet_id
    security_groups = [var.sg_id]
  }

  vpc  = var.vpc_id
  keys = [var.ssh_key_id]

  boot_volume {
    name = "ontap-node1-boot"
    size = 100
  }

  user_data = file("${path.module}/cloud-init-ontap-node1.yaml")
}

# Volumes de dados
resource "ibm_is_volume" "ontap_node1_data1" {
  name    = "ontap-node1-data1"
  profile = "general-purpose"
  capacity = 500
  zone     = "us-south-1"
}

resource "ibm_is_volume_attachment" "ontap_node1_data1_attach" {
  instance = ibm_is_instance.ontap_node1.id
  volume   = ibm_is_volume.ontap_node1_data1.id
}

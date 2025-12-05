data "ibm_is_image" "converter_base" {
  name = var.converter_base_image_name
}

resource "ibm_is_ssh_key" "converter_key" {
  name       = var.converter_ssh_key_name
  public_key = var.converter_ssh_public_key
}

locals {
  converter_subnet_id = var.converter_subnet != "" ? var.converter_subnet : ibm_is_subnet.mgmt.id
  converter_sg_id     = var.converter_security_group != "" ? var.converter_security_group : ibm_is_security_group.ontap_sg.id
}

resource "ibm_is_instance" "converter" {
  name    = var.converter_instance_name
  image   = data.ibm_is_image.converter_base.id
  profile = var.converter_profile
  zone    = var.converter_zone

  primary_network_interface {
    subnet          = local.converter_subnet_id
    security_groups = [local.converter_sg_id]
  }

  vpc  = ibm_is_vpc.ontap_vpc.id
  keys = [ibm_is_ssh_key.converter_key.id]

  user_data = templatefile("${path.module}/templates/converter-cloud-init.sh.tmpl", {
    source_ova_url       = var.converter_source_ova_url
    output_object_key    = var.converter_output_object_key
    bucket_name          = var.converter_cos_bucket
    region               = var.region
    cos_instance_crn     = ibm_resource_instance.cos.crn
    api_key              = var.ibmcloud_api_key
  })
}

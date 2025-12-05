data "ibm_is_image" "converter_base" {
  count = local.infra_count
  name  = var.converter_base_image_name
}

locals {
  converter_subnet_id = local.infra_enabled ? coalesce(
    var.converter_subnet != "" ? var.converter_subnet : null,
    try(ibm_is_subnet.mgmt[0].id, null),
  ) : null

  converter_sg_id = local.infra_enabled ? coalesce(
    var.converter_security_group != "" ? var.converter_security_group : null,
    try(ibm_is_security_group.ontap_sg[0].id, null),
  ) : null
}

resource "ibm_is_instance" "converter" {
  count   = local.infra_count
  name    = var.converter_instance_name
  image   = data.ibm_is_image.converter_base[0].id
  profile = var.converter_profile
  zone    = var.converter_zone

  primary_network_interface {
    subnet          = local.converter_subnet_id
    security_groups = [local.converter_sg_id]
  }

  vpc  = ibm_is_vpc.ontap_vpc[0].id
  keys = [local.ssh_key_id]
  resource_group = ibm_resource_group.rg.id

  user_data = local.infra_enabled ? templatefile("${path.module}/templates/converter-cloud-init.sh.tmpl", {
    source_ova_url           = var.converter_source_ova_url
    source_ova_bucket        = var.converter_source_bucket
    source_ova_object_key    = var.converter_source_object_key
    output_object_key        = var.converter_output_object_key
    bucket_name              = var.converter_cos_bucket
    region                   = var.region
    cos_instance_crn         = ibm_resource_instance.cos.crn
    api_key                  = var.ibmcloud_api_key
  }) : null
}

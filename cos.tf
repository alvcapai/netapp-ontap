data "ibm_resource_group" "cos_rg" {
  name = var.cos_resource_group
}

resource "ibm_resource_instance" "cos" {
  name              = var.cos_instance_name
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = var.region
  resource_group_id = data.ibm_resource_group.cos_rg.id
}

resource "ibm_cos_bucket" "ontap_image" {
  bucket_name          = var.cos_bucket_name
  resource_instance_id = ibm_resource_instance.cos.guid
  region_location      = var.region
  storage_class        = "standard"
  force_delete         = true
}

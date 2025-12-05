resource "ibm_resource_instance" "cos" {
  name              = var.cos_instance_name
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = var.cos_location
  resource_group_id = ibm_resource_group.rg.id
}

resource "ibm_cos_bucket" "ontap_image" {
  bucket_name          = var.cos_bucket_name
  resource_instance_id = ibm_resource_instance.cos.crn
  region_location      = var.region
  storage_class        = "standard"
  force_delete         = true
}

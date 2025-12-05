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

resource "ibm_cos_bucket_object" "ontap_image_object" {
  count      = var.upload_local_image ? 1 : 0
  bucket_crn = ibm_cos_bucket.ontap_image.crn
  key        = var.ontap_image_object_key
  file_path  = var.ontap_image_file
  etag       = var.upload_local_image ? filemd5(var.ontap_image_file) : null
  bucket_location = var.region
}

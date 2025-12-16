output "floating_ip" {
  description = "Floating IP address attached to the instance."
  value       = ibm_is_floating_ip.vm_fip.address
}

output "cos_bucket_name" {
  description = "Nome do bucket COS para uploads."
  value       = ibm_cos_bucket.images.bucket_name
}

output "cos_upload_url" {
  description = "Endpoint público HTTPS para upload (s3 API)."
  value       = "https://s3.${var.region}.cloud-object-storage.appdomain.cloud/${ibm_cos_bucket.images.bucket_name}"
}

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

output "cos_hmac_access_key" {
  description = "HMAC access key para uploads autenticados no COS."
  value       = local.cos_hmac_access_key
  sensitive   = true
}

output "cos_hmac_secret_key" {
  description = "HMAC secret key para uploads autenticados no COS."
  value       = local.cos_hmac_secret_key
  sensitive   = true
}

output "secret_manager_hmac_secret_id" {
  description = "ID do segredo HMAC no Secrets Manager."
  value       = ibm_sm_arbitrary_secret.cos_hmac.id
}

output "secret_manager_hmac_secret_name" {
  description = "Nome do segredo HMAC no Secrets Manager."
  value       = ibm_sm_arbitrary_secret.cos_hmac.name
}

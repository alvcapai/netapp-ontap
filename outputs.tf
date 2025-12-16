output "floating_ip" {
  description = "Floating IP address attached to the instance."
  value       = ibm_is_floating_ip.vm_fip.address
}

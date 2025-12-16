locals {
  # When cos_only is true, skip provisioning network/compute helpers.
  infra_enabled = !var.cos_only
  infra_count   = local.infra_enabled ? 1 : 0
  ontap_enabled = local.infra_enabled && var.deploy_ontap
  ontap_count   = local.ontap_enabled ? 1 : 0

  # SSH keys: allow helper to reuse main key when converter-specific key is not provided.
  converter_uses_main_key  = (var.converter_ssh_key_name == "" || var.converter_ssh_public_key == "") || (var.converter_ssh_key_name == var.ssh_key_name)
  converter_ssh_key_name   = var.converter_ssh_key_name != "" ? var.converter_ssh_key_name : var.ssh_key_name
  converter_ssh_public_key = var.converter_ssh_public_key != "" ? var.converter_ssh_public_key : var.ssh_public_key

  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : var.cos_resource_group
}

locals {
  # When cos_only is true, skip provisioning network/compute helpers.
  infra_enabled = !var.cos_only
  infra_count   = local.infra_enabled ? 1 : 0
  ontap_enabled = local.infra_enabled && var.deploy_ontap
  ontap_count   = local.ontap_enabled ? 1 : 0
  ssh_key_create_count = var.use_existing_ssh_key ? 0 : local.infra_count

  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : var.cos_resource_group
}

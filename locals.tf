locals {
  # When cos_only is true, skip provisioning network/compute helpers.
  infra_enabled = !var.cos_only
  infra_count   = local.infra_enabled ? 1 : 0

  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : var.cos_resource_group
}

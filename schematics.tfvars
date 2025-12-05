# This file is intentionally empty so values can be injected directly in IBM Schematics
# workspace variables (UI/API).
# 
# Stage 1 (COS only): set cos_only=true and provide ibmcloud_api_key plus COS values.
# Stage 2 (full deploy after uploading the image to COS): set cos_only=false and provide:
#   - ibmcloud_api_key (Secure String)
#   - ssh_key_name
#   - ssh_public_key
#   - ontap_image_id
#   - converter_ssh_key_name
#   - converter_ssh_public_key
#   - converter_source_ova_url
#   - converter_cos_bucket
#
# Optional overrides you may also set in the workspace:
#   region, zone, vpc_name, mgmt_subnet_cidr, data_subnet_cidr, resource_prefix,
#   ontap_profile, boot_volume_size, data_disks_per_node, data_disk_size,
#   data_disk_profile, allowed_ssh_cidr, allowed_https_cidr,
#   enable_nfs, enable_smb, enable_iscsi

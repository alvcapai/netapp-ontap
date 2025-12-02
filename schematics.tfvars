# Required values for IBM Schematics / terraform -var-file=schematics.tfvars
# Copy to schematics.tfvars and fill with your real values (mark ibmcloud_api_key as secure in Schematics).

ibmcloud_api_key = "<your_ibm_cloud_api_key>"
ssh_key_name     = "<your_ssh_key_name_in_ibm_cloud>"
ontap_image_id   = "<your_custom_ontap_image_id>"

# Optional overrides (uncomment to change defaults)
# region            = "us-south"
# zone              = "us-south-1"
# vpc_name          = "ontap-vpc"
# mgmt_subnet_cidr  = "10.10.1.0/24"
# data_subnet_cidr  = "10.10.2.0/24"
# resource_prefix   = "ontap"
# ontap_profile     = "bx2-8x32"
# boot_volume_size  = 100
# data_disks_per_node = 3
# data_disk_size      = 500
# data_disk_profile   = "general-purpose"
# allowed_ssh_cidr    = "0.0.0.0/0"
# allowed_https_cidr  = "0.0.0.0/0"
# enable_nfs          = false
# enable_smb          = false
# enable_iscsi        = false

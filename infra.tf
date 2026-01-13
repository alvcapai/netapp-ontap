locals {
  resource_group_name = var.resource_group_name
}

resource "ibm_resource_group" "rg" {
  name = local.resource_group_name
}

data "ibm_is_image" "base" {
  name = var.instance_image_name
}

data "ibm_is_ssh_key" "ssh" {
  count = var.use_existing_ssh_key ? 1 : 0
  name  = var.ssh_key_name
}

resource "ibm_is_ssh_key" "ssh" {
  count          = var.use_existing_ssh_key ? 0 : 1
  name           = var.ssh_key_name
  public_key     = var.ssh_public_key
  resource_group = ibm_resource_group.rg.id
}

resource "ibm_is_vpc" "vpc" {
  name           = var.vpc_name
  resource_group = ibm_resource_group.rg.id
}

resource "ibm_is_vpc_address_prefix" "subnet_prefix" {
  name = "${var.vpc_name}-prefix"
  zone = var.zone
  vpc  = ibm_is_vpc.vpc.id
  cidr = var.subnet_cidr
}

resource "ibm_is_subnet" "subnet" {
  name            = "${var.vpc_name}-subnet"
  vpc             = ibm_is_vpc.vpc.id
  zone            = var.zone
  ipv4_cidr_block = var.subnet_cidr
  resource_group  = ibm_resource_group.rg.id
  depends_on      = [ibm_is_vpc_address_prefix.subnet_prefix]
}

resource "ibm_is_security_group" "sg" {
  name           = "${var.vpc_name}-sg"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = ibm_resource_group.rg.id
}

resource "ibm_is_security_group_rule" "ssh_in" {
  group     = ibm_is_security_group.sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_instance" "vm" {
  name      = var.instance_name
  image     = data.ibm_is_image.base.id
  profile   = var.instance_profile
  zone      = var.zone
  user_data = local.converter_cloud_init

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet.id
    security_groups = [ibm_is_security_group.sg.id]
  }

  vpc            = ibm_is_vpc.vpc.id
  keys           = [local.ssh_key_id]
  resource_group = ibm_resource_group.rg.id
}

resource "ibm_is_floating_ip" "vm_fip" {
  name           = "${var.instance_name}-fip"
  target         = ibm_is_instance.vm.primary_network_interface[0].id
  resource_group = ibm_resource_group.rg.id
}

resource "ibm_resource_instance" "cos" {
  name              = var.cos_instance_name
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = ibm_resource_group.rg.id
}

resource "ibm_cos_bucket" "images" {
  bucket_name          = var.cos_bucket_name
  resource_instance_id = ibm_resource_instance.cos.crn
  region_location      = var.region
  storage_class        = "standard"
  force_delete         = true
}

resource "ibm_resource_instance" "secrets_manager" {
  name              = var.secret_manager_instance_name
  service           = "secrets-manager"
  plan              = "standard"
  location          = var.region
  service_endpoints = "private"
  resource_group_id = ibm_resource_group.rg.id
  lifecycle {
    replace_triggered_by = [terraform_data.secrets_manager_recreate]
  }
}

resource "terraform_data" "secrets_manager_recreate" {
  input = var.secrets_manager_recreate_token
}

resource "ibm_resource_key" "cos_hmac" {
  name                 = "${var.cos_instance_name}-hmac"
  resource_instance_id = ibm_resource_instance.cos.id
  role                 = "Writer"
  parameters = {
    HMAC = true
  }
}

resource "time_sleep" "wait_for_sm_endpoint" {
  depends_on      = [ibm_resource_instance.secrets_manager]
  create_duration = var.secrets_manager_endpoint_wait
}

resource "ibm_sm_arbitrary_secret" "cos_hmac" {
  instance_id     = ibm_resource_instance.secrets_manager.guid
  secret_group_id = "default"
  name            = "${var.cos_instance_name}-hmac"
  depends_on      = [time_sleep.wait_for_sm_endpoint]
  payload = jsonencode({
    access_key_id     = local.cos_hmac_access_key
    secret_access_key = local.cos_hmac_secret_key
    endpoint          = "https://s3.${var.region}.cloud-object-storage.appdomain.cloud/${ibm_cos_bucket.images.bucket_name}"
    bucket            = ibm_cos_bucket.images.bucket_name
    region            = var.region
  })
}

locals {
  converter_cloud_init = <<-EOT
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - qemu-utils
      - python3
      - python3-pip
    write_files:
      - path: /usr/local/bin/convert-upload.sh
        permissions: '0755'
        owner: root:root
        content: |
          #!/usr/bin/env bash
          set -euo pipefail
          if [[ $# -lt 1 ]]; then
            echo "Usage: $0 /path/to/image.ova [output-object-key]" >&2
            exit 1
          fi
          OVA_PATH="$1"
          OBJ_KEY="$${2:-${var.converter_output_object_key}}"
          REGION="${var.region}"
          BUCKET="${var.cos_bucket_name}"
          COS_CRN="${ibm_resource_instance.cos.crn}"
          API_KEY="${var.ibmcloud_api_key}"
          export API_KEY COS_CRN REGION BUCKET OBJ_KEY
          
          if [[ ! -f "$OVA_PATH" ]]; then
            echo "File not found: $OVA_PATH" >&2
            exit 1
          fi
          
          TMPDIR=$(mktemp -d)
          cleanup() { rm -rf "$TMPDIR"; }
          trap cleanup EXIT
          
          tar -xf "$OVA_PATH" -C "$TMPDIR"
          SRC_DISK=$(ls "$TMPDIR"/*.vmdk | head -n1)
          if [[ -z "$SRC_DISK" ]]; then
            echo "No VMDK found in extracted OVA" >&2
            exit 1
          fi
          
          OUT_PATH="$TMPDIR/$OBJ_KEY"
          qemu-img convert -f vmdk -O qcow2 "$SRC_DISK" "$OUT_PATH"
          
          export OUT_PATH
          python3 - <<'PYCODE'
          import ibm_boto3
          from ibm_botocore.client import Config
          import os
          
          api_key = os.environ["API_KEY"]
          cos_crn = os.environ["COS_CRN"]
          region = os.environ["REGION"]
          bucket = os.environ["BUCKET"]
          obj_key = os.environ["OBJ_KEY"]
          out_path = os.environ["OUT_PATH"]
          
          cos = ibm_boto3.client(
              "s3",
              ibm_api_key_id=api_key,
              ibm_service_instance_id=cos_crn,
              config=Config(signature_version="oauth"),
              region_name=region,
          )
          
          print(f"Uploading {out_path} to {bucket}/{obj_key}")
          cos.upload_file(Filename=out_path, Bucket=bucket, Key=obj_key)
          print("Upload completed.")
          PYCODE
    runcmd:
      - pip3 install --upgrade pip ibm-cos-sdk ibm-cos-sdk-s3transfer
  EOT

  ssh_key_id = var.use_existing_ssh_key ? data.ibm_is_ssh_key.ssh[0].id : ibm_is_ssh_key.ssh[0].id

  cos_hmac_creds      = jsondecode(ibm_resource_key.cos_hmac.credentials_json)
  cos_hmac_access_key = local.cos_hmac_creds["cos_hmac_keys"]["access_key_id"]
  cos_hmac_secret_key = local.cos_hmac_creds["cos_hmac_keys"]["secret_access_key"]
}

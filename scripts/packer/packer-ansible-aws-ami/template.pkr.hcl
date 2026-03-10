packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

locals {
  build_timestamp = "{{timestamp}}"
}

variable "script_root_path" {
  type    = string
  default = "/tmp"
}

# ─── SOURCE ────────────────────────────────────────────────────────────────────
# Builds an EBS-backed AMI in the VPC/subnet/SG discovered via tag filters.
# Change the tag values in the filters to match your own Terraform-managed infra.

source "amazon-ebs" "app" {
  instance_type = var.instance_type

  vpc_filter {
    filters = {
      "tag:Terraform"   : "true"
      "tag:Environment" : var.environment
      "tag:Name"        : "myapp-${var.environment}-vpc"   # <-- update tag value
    }
  }

  subnet_filter {
    filters = {
      "tag:Type" : "public"
    }
    most_free = true
    random    = false
  }

  security_group_filter {
    filters = {
      "tag:Name" : "myapp-api-${var.environment}-instance-sg"   # <-- update tag value
    }
  }

  # Always resolve to the latest Ubuntu 24.04 LTS arm64 image at build time
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # Canonical's official AWS account
    most_recent = true
  }

  ssh_username = "ubuntu"
  ami_name     = "myapp-backend-api-${local.build_timestamp}"   # <-- update prefix

  # IAM instance profile must allow: S3 GetObject, CloudWatch PutMetricData
  iam_instance_profile = "PackerInstanceRole"

  tags = {
    Name        = "myapp-backend-api-${local.build_timestamp}"
    PackerBuild = "true"
    Environment = var.environment
    Project     = "myapp-backend"   # <-- update
  }
}

# ─── BUILD ─────────────────────────────────────────────────────────────────────

build {
  sources = ["source.amazon-ebs.app"]

  # 1. Wait for cloud-init, then install Ansible on the instance
  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait",
      "sudo apt-get update",
      "sudo apt-get install -y python3 python3-pip ansible"
    ]
  }

  # 2. Install and configure CloudWatch Agent (metrics: CPU, memory, disk)
  provisioner "ansible-local" {
    playbook_file = "./ansible/cloudwatch-agent.yml"
  }

  # 3. Upload supporting files (systemd unit files, scripts, etc.) to /tmp
  provisioner "file" {
    source      = "${path.root}/files/"
    destination = var.script_root_path
  }

  # 4. Run master Ansible playbook — provisions everything in order:
  #    os-dependencies → services → fluent-bit → app-setup → fluent-bit-app-config
  provisioner "ansible-local" {
    playbook_dir  = "./ansible"
    playbook_file = "./ansible/site.yml"
    extra_arguments = [
      "--extra-vars",
      "\"project_dir_name=${var.project_dir_name} app_repo=${var.app_repo} s3_bucket_name=${var.s3_bucket_name} deploy_env=${var.environment} github_pat=${var.github_pat} script_root_path=${var.script_root_path}\""
    ]
  }
}

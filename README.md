# DevOps Knowledgebase

A public collection of articles, reusable scripts, and infrastructure templates documenting how I design and build DevOps systems. Everything here is written to be practical and adoptable — not just theory.

---

## 📄 Articles

In-depth write-ups covering patterns, implementations, and real-world decisions.

| Article | Description |
|---------|-------------|
| [Immutable Infrastructure Deployment Pipeline](articles/immutable-infrastructure-implementation.md) | Multi-repo GitHub Actions pipeline using Packer + Ansible + Terraform with cross-repo dispatch and unified Slack thread tracking |
| [AWS GitHub OIDC Implementation](articles/aws-github-oicd-implementation.md) | How to configure GitHub Actions to authenticate to AWS using OIDC — no static credentials |
| [Automate Jenkins Setup on AWS EC2](articles/automate-jenkins-setup-on-aws-ec2.md) | Full automated Jenkins installation and configuration on an EC2 instance |
| [Jenkins Setup](articles/jenkins-setup.md) | Jenkins configuration reference and setup notes |
| [Point-to-Site VPN](articles/point-to-site-vpn.md) | Configuring a Point-to-Site VPN for secure remote access |
| [Cloud Resume Challenge — Part 1](articles/cloud-resume-challenge-1.md) | Building the frontend and hosting on AWS |
| [Cloud Resume Challenge — Part 2](articles/cloud-resume-challenge-2.md) | Backend API, DynamoDB, and CI/CD pipeline |

---

## 🛠️ Scripts & Templates

Copy-paste-ready, production-grade templates. Each has a README explaining how to adapt it.

### Pipeline — GitHub Actions
| Template | Description |
|----------|-------------|
| [Immutable Deployment — App Repo Trigger](scripts/pipeline/github-actions/app-repo-trigger.yml) | Entry point workflow — determines environment, opens Slack thread, cross-repo dispatches to Packer |
| [Immutable Deployment — Packer AMI Build](scripts/pipeline/github-actions/packer-build-ami.yml) | Builds an AWS AMI via Packer, then dispatches to the infra repo |
| [Immutable Deployment — Terraform Apply](scripts/pipeline/github-actions/infra-terraform-apply.yml) | Targeted `terraform apply` to spin up new EC2 from the new AMI and update DNS |
| [Jenkinsfile](scripts/pipeline/Jenkinsfile) | Declarative Jenkins pipeline reference |

### Packer + Ansible
| Template | Description |
|----------|-------------|
| [packer-ansible-aws-ami](scripts/packer/packer-ansible-aws-ami/) | Full Packer template + Ansible playbooks for baking a production-ready AWS AMI — includes OS setup, CloudWatch, Fluent Bit, app clone, Python venv, and systemd services |

### Terraform
| Template | Description |
|----------|-------------|
| [simple-ec2](scripts/terraform/simple-ec2/) | Single EC2 instance with security group |
| [two-tier-app-infra](scripts/terraform/two-tier-app-infra/) | Full two-tier architecture (load balancer + EC2 + RDS) |
| [eks-cluster](scripts/terraform/eks-cluster/) | EKS cluster with managed node groups |
| [jenkins-aws-ec2](scripts/terraform/jenkins-aws-ec2/) | EC2 infrastructure for a Jenkins controller |
| [infrastructure](scripts/terraform/infrastructure/) | Full production infrastructure template |

### Bash
| Script | Description |
|--------|-------------|
| [docker-setup.sh](scripts/bash/docker-setup.sh) | Installs Docker and Docker Compose on Ubuntu |
| [jenkins-setup.sh](scripts/bash/jenkins-setup.sh) | Automated Jenkins installation script |
| [jenkins-slave-setup.sh](scripts/bash/jenkins-slave-setup.sh) | Sets up a Jenkins agent/slave node |

---

## 🏠 Homelab

Documentation for my self-hosted lab environment.

| Section | Description |
|---------|-------------|
| [Proxmox](homelab/proxmox/) | Proxmox VE host configuration and notes |
| [Jellyfin](homelab/jellyfin/) | Self-hosted media server setup |

---

## About

I'm a DevOps engineer focused on cloud infrastructure, CI/CD automation, and platform engineering. This repo is my public reference for patterns and implementations I've designed and built in production.

Connect with me on [LinkedIn](https://www.linkedin.com/in/gabbyti) or explore the articles above to see how these systems are designed.

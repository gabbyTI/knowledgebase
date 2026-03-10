# Packer + Ansible — AWS AMI Baking Template

A production-ready template for building AWS AMIs using **HashiCorp Packer** with **Ansible** as the provisioner. Designed to work as the middle stage of an immutable deployment pipeline — Packer bakes the image, Terraform deploys infrastructure from it.

See [`articles/immutable-infrastructure-implementation.md`](../../../articles/immutable-infrastructure-implementation.md) for the full pipeline context.

---

## What Gets Baked Into the AMI

The Ansible playbooks run in this order (orchestrated by `ansible/site.yml`):

| Order | Playbook | What it does |
|-------|----------|-------------|
| 1 | `cloudwatch-agent.yml` | Installs AWS CloudWatch Agent (CPU, memory, disk metrics) |
| 2 | `os-dependencies.yml` | Python 3.11, Redis, AWS CLI, system packages |
| 3 | `services.yml` | Copies systemd unit files, enables + starts services |
| 4 | `fluent-bit.yml` | Installs Fluent Bit log agent with auto-restart on config change |
| 5 | `app-setup.yml` | Clones the app repo, syncs env files from S3, creates venv, installs Python deps, runs framework management commands |
| 6 | `fluent-bit-app-config.yml` | Deploys app-specific Fluent Bit log config (must run after app-setup) |

---

## File Structure

```
packer-ansible-aws-ami/
├── template.pkr.hcl                    ← Packer build template (source + provisioners)
├── variables.pkr.hcl                   ← Variable declarations with validation
├── variables.auto.pkrvars.hcl.example  ← Copy to variables.auto.pkrvars.hcl and fill in
└── ansible/
    ├── site.yml                        ← Master playbook — imports all others in order
    ├── cloudwatch-agent.yml
    ├── os-dependencies.yml
    ├── services.yml
    ├── fluent-bit.yml
    ├── app-setup.yml
    └── fluent-bit-app-config.yml
```

> **`files/` directory** (not included here): Packer uploads `files/` to `/tmp` on the build instance before Ansible runs. It should contain:
> - `systemd/` — your `.service` unit files (referenced by `services.yml`)
> - Any other static files your Ansible playbooks reference via `script_root_path`

---

## Prerequisites

1. **AWS IAM** — An instance profile (`PackerInstanceRole`) attached to the build instance with permissions for S3 read and CloudWatch write
2. **VPC/subnet/SG tagged correctly** — The template uses tag-based filters to locate the VPC, public subnet, and security group. Update the tag values in `template.pkr.hcl` to match your Terraform-managed infra
3. **S3 bucket** — Environment files (`.env`) must be pre-uploaded to `s3://<bucket>/<environment>/envs/`
4. **GitHub PAT** — Read access to the app repository (used by Ansible to clone it)

---

## Usage

### Local / Manual Build

```bash
# Copy and fill in the example vars file
cp variables.auto.pkrvars.hcl.example variables.auto.pkrvars.hcl
# edit variables.auto.pkrvars.hcl with your values

# Validate
packer init . && packer validate .

# Build
packer init . && packer build .
```

### In CI (GitHub Actions)

The `variables.auto.pkrvars.hcl` file is written dynamically by the GitHub Actions workflow using values from repository variables and secrets — it is never committed to the repo. See [`scripts/pipeline/github-actions/packer-build-ami.yml`](../../pipeline/github-actions/packer-build-ami.yml).

---

## Adapting to Your Stack

| Thing to change | Where |
|---|---|
| Service names | `ansible/services.yml` → `services:` list |
| Python version | `ansible/os-dependencies.yml` and `ansible/app-setup.yml` → `python_version` var |
| Framework management commands | `ansible/app-setup.yml` → "Framework management commands" section |
| AMI name prefix | `template.pkr.hcl` → `ami_name` and `tags` |
| VPC/SG tag values | `template.pkr.hcl` → `vpc_filter`, `security_group_filter` |
| Instance architecture | `template.pkr.hcl` → `source_ami_filter` name + `variables.pkr.hcl` → `instance_type` default |

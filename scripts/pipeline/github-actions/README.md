# GitHub Actions — Immutable Deployment Pipeline

Generic, copy-paste-ready workflow templates for a **multi-repo immutable deployment pipeline** using GitHub Actions, HashiCorp Packer, and Terraform.

## How They Fit Together

```
app-repo-trigger.yml
  → triggers → packer-build-ami.yml
                  → triggers → infra-terraform-apply.yml
```

## Files

| File | Repo it lives in | Purpose |
|------|-----------------|---------|
| `app-repo-trigger.yml` | `app-repo` | Entry point — determines environment, opens Slack thread, cross-repo dispatches to packer |
| `packer-build-ami.yml` | `packer-repo` | Validates + builds AWS AMI with app pre-installed, then dispatches to infra |
| `infra-terraform-apply.yml` | `infra-repo` | Runs targeted `terraform apply` to spin up new EC2 from the new AMI and update DNS |

## Usage

1. Copy each file into its respective repository under `.github/workflows/`
2. Replace all `# <-- replace` comments with your actual repo/file names
3. Set the required secrets and variables in each repo's GitHub settings
4. Set up an IAM role trusted by GitHub Actions OIDC in your AWS account (`GithubOICD`)
5. Set up a Slack bot and create the three custom actions: `slack-post-message`, `slack-update-thread`, `slack-update-message`

## Full Documentation

See [`articles/immutable-infrastructure-implementation.md`](../../articles/immutable-infrastructure-implementation.md) for the complete write-up including architecture diagram, design decisions, and the Slack thread continuity pattern.

# AWS OIDC Authentication for GitHub Actions

This guide provides a step-by-step process to set up GitHub Actions to authenticate with AWS using OpenID Connect (OIDC). This eliminates the need for storing long-term AWS credentials in GitHub Secrets.

## Step 1: Create an AWS IAM OIDC Identity Provider

Run the following AWS CLI command to establish GitHub as an OIDC provider in AWS:

```sh
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list $(curl -s https://token.actions.githubusercontent.com/.well-known/openid-configuration | jq -r .jwks_uri | xargs curl -s | jq -r .keys[0].x5c[0] | openssl x509 -inform DER -noout -fingerprint | cut -d"=" -f2)
```

Alternatively, you can create the OIDC provider via the AWS Console:
1. Go to **IAM** → **Identity Providers** → **Add provider**.
2. Choose **OpenID Connect**.
3. Enter `https://token.actions.githubusercontent.com` as the provider URL.
4. Set `sts.amazonaws.com` as the audience.
5. Retrieve the thumbprint from the GitHub OIDC URL and add it.
6. Click **Create provider**.

## Step 2: Create an IAM Role for GitHub Actions

Create an IAM Role with a trust policy that allows GitHub Actions to assume the role via OIDC.

### Create the Trust Policy
Create a JSON file `github-oidc-trust-policy.json` with the following content:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:sub": "repo:your-org/your-repo:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

Replace `YOUR_AWS_ACCOUNT_ID`, `your-org`, and `your-repo` accordingly.

Now create the IAM Role using AWS CLI:

```sh
aws iam create-role \
  --role-name GitHubOIDCRole \
  --assume-role-policy-document file://github-oidc-trust-policy.json
```

## Step 3: Attach Permissions to the IAM Role

Create a JSON file `github-oidc-policy.json` with the necessary permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "ec2:*",
        "iam:PassRole",
        "ssm:GetParameters",
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
```

Attach the policy to the IAM role:

```sh
aws iam put-role-policy \
  --role-name GitHubOIDCRole \
  --policy-name GitHubActionsPolicy \
  --policy-document file://github-oidc-policy.json
```

## Step 4: Configure GitHub Actions to Use OIDC

Modify your GitHub Actions workflow file (e.g., `.github/workflows/deploy.yml`) to authenticate using OIDC:

```yaml
name: Deploy with Terraform and Packer

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    permissions:
      id-token: write  # Enables OIDC token requests
      contents: read

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/GitHubOIDCRole
          aws-region: us-east-2

      - name: Verify AWS Identity
        run: aws sts get-caller-identity

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -out=tfplan

      - name: Terraform Apply
        run: terraform apply tfplan
```

Replace `YOUR_AWS_ACCOUNT_ID` with your actual AWS account ID.

## Conclusion

Now, your GitHub Actions workflow can securely authenticate with AWS without using static credentials, leveraging OIDC for authentication. This setup is useful for Terraform, Packer, and other AWS-related automation tasks.


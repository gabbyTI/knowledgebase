## Table of Content

- [Table of Content](#table-of-content)
- [1. Introduction](#1-introduction)
- [2. The Deployments](#2-the-deployments)
  - [2.1. Infrastructure CI/CD pipeline](#21-infrastructure-cicd-pipeline)
  - [2.2. Frontend CI/CD Pipeline](#22-frontend-cicd-pipeline)
  - [2.3. Backend CI/CD Pipeline](#23-backend-cicd-pipeline)
- [3. What's Next](#3-whats-next)
- [4. Conclusion](#4-conclusion)

## 1. Introduction

In [part one](https://dev.to/gabbyti/cloud-resume-challenge-azure-edition-part-1-fgb), we covered the basics of my Cloud Resume Challenge journey. Now, let's dive into the heart of the challenge: deployment pipelines. These are the backbone of our cloud setup, making deployment smooth and efficient. Join me as we explore how these pipelines work and how they make our deployment process easier.

## 2. The Deployments

### 2.1. Infrastructure CI/CD pipeline

To streamline our infrastructure management, I've implemented a pipeline using GitHub Actions. Here's the breakdown of our workflow:

1. **Initialization**: We kick off by initializing Terraform, ensuring all necessary configurations and plugins are set up correctly.
2. **Planning**: Terraform meticulously plans the proposed changes, outlining what will be added, modified, or destroyed in our infrastructure.
3. **Validation**: Once the plan is generated, Terraform validates it against our existing infrastructure, ensuring compatibility and compliance without making any actual modifications.
4. **Applying Changes**: With the validated plan, Terraform proceeds to apply the changes, seamlessly updating our infrastructure to reflect the desired state.

Here is the workflow flow file:

```yaml
name: CI
on:
  push:
    branches: [main]

permissions:
  contents: 'read'
  id-token: 'write'

env:
  ARM_CLIENT_ID: '${{ secrets.AZURE_CLIENT_ID }}'
  ARM_CLIENT_SECRET: '${{ secrets.AZURE_CLIENT_SECRET }}'
  ARM_SUBSCRIPTION_ID: '${{ secrets.AZURE_SUBSCRIPTION_ID }}'
  ARM_TENANT_ID: '${{ secrets.AZURE_TENANT_ID }}'

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v3

      - name: Initialize terraform configuration
        run: terraform init

      - name: Validate terraform configuration
        run: terraform validate

      - name: Plan terraform configuration
        run: terraform plan -refresh=false

      - name: Apply terraform configuration
        run: terraform apply -refresh=false -auto-approve
```

_Note_: I used a service principal details and environment varaibles to authenticate terraform to azure. Read more about that [**HERE**](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash#specify-service-principal-credentials-in-environment-variables).

### 2.2. Frontend CI/CD Pipeline

For the deployment pipeline for the frontend, i have used github actions workflows. The workflow includes the following steps:

1. **Azure Login**: Authenticates access to the Azure environment.
2. **Delete Previous Content**: Clears out existing website content to ensure a clean deployment.
3. **Upload New Content**: Transfers the updated website content to the Azure platform.
4. **Purge Azure CDN**: Refreshes the Azure CDN to reflect the latest changes.
5. **Azure Logout**: Safely terminates the Azure session.

Here is the workflow flow file:

```yaml
name: Cloud Resume Deployment
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - name: Delete previous content
        uses: azure/CLI@v1
        with:
          inlineScript: |
            az storage blob delete-batch --account-name ${{ vars.STORAGE_ACCOUNT_NAME }} --auth-mode key --source '$web'

      - name: Upload to blob storage
        uses: azure/CLI@v1
        with:
          inlineScript: |
            az storage blob upload-batch --account-name ${{ vars.STORAGE_ACCOUNT_NAME }} --auth-mode key -d '$web' -s .

      - name: Purge CDN endpoint
        uses: azure/CLI@v1
        with:
          inlineScript: |
            az cdn endpoint purge --content-paths  "/*" --profile-name ${{ vars.CDN_PROFILE_NAME }} --name ${{ vars.CDN_ENDPOINT_NAME }} --resource-group ${{ vars.RESOURCE_GROUP }}
        # Azure logout
      - name: logout
        run: |
          az logout
        if: always()
```

### 2.3. Backend CI/CD Pipeline

I decided to switch it up a bit and used azure DevOps for deploying to the Azure functions. The script steps:

1. **Installing Dependencies**: Ensuring all necessary dependencies are set up and ready to go.
2. **Publishing Deployment Artifact**: Packaging everything up neatly for deployment to Azure Functions.

Here is the pipeline file:

```
name: Cloud Resume Deployment
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - name: Delete previous content
        uses: azure/CLI@v1
        with:
          inlineScript: |
            az storage blob delete-batch --account-name ${{ vars.STORAGE_ACCOUNT_NAME }} --auth-mode key --source '$web'

      - name: Upload to blob storage
        uses: azure/CLI@v1
        with:
          inlineScript: |
            az storage blob upload-batch --account-name ${{ vars.STORAGE_ACCOUNT_NAME }} --auth-mode key -d '$web' -s .

      - name: Purge CDN endpoint
        uses: azure/CLI@v1
        with:
          inlineScript: |
            az cdn endpoint purge --content-paths  "/*" --profile-name ${{ vars.CDN_PROFILE_NAME }} --name ${{ vars.CDN_ENDPOINT_NAME }} --resource-group ${{ vars.RESOURCE_GROUP }}
        # Azure logout
      - name: logout
        run: |
          az logout
        if: always()

```

The remaining steps are configured in Azure DevOps by creating a release pipeline. Here is mine shown below:

![AZURE DEVOPS RELEASE PIPELINE](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/j71g95ile5815oimgp5e.png)

## 3. What's Next

While the project is mostly complete, there's always room for improvement. Here are some areas I'll be focusing on to enhance my knowledge and experience:

- Implementing unit testing for Python code.
- Conducting code scans with SonarQube or Synk for security and quality assurance.
- Modularizing infrastructure to make it more reusable and scalable.
- Privatizing Azure infrastructure behind a VNet (Virtual Network) for enhanced security.
- Setting up a DNS Zone and managing my custom domain for better branding and accessibility.

## 4. Conclusion

That wraps up part two of our Cloud Resume Challenge journey! We've dived deep into the deployment pipelines, seeing how they make our cloud setup smooth and efficient. From initializing Terraform to deploying our frontend and backend, each step has been crucial in streamlining our deployment process.

But our journey doesn't end here. We've outlined some areas for improvement, like implementing unit testing, conducting code scans, and making our infrastructure more modular and secure. These steps will help us further enhance our project and deepen our understanding of cloud technologies.

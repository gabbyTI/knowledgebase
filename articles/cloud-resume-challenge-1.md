## Table of Content

- [Table of Content](#table-of-content)
- [1. Introduction](#1-introduction)
- [2. The Certification](#2-the-certification)
- [3. The HTML, CSS \& JavaScript Frontend](#3-the-html-css--javascript-frontend)
- [4. Backend Code: Python Counter API](#4-backend-code-python-counter-api)
  - [4.1. Prerequisite](#41-prerequisite)
  - [4.2. Setup](#42-setup)
  - [4.3. Running Azure Function Locally](#43-running-azure-function-locally)
- [5. Terraform IaC](#5-terraform-iac)
- [6. Conclusion](#6-conclusion)

## 1. Introduction

The Cloud Resume Challenge offers a really cool and hands-on way to dive into cloud technologies. I recently took on the Azure-focused version, and it was a fantastic journey through Microsoft's cloud platform. In this blog post, I'll share my experience and the awesome skills I picked up along the way. Here are some useful links:

- [The Website](https://gabriel-cloud-resume.azureedge.net/)
- [Frontend Code](https://github.com/gabbyTI/cloud_resume)
- [Backend Code: Python API](https://github.com/gabbyTI/python-counter-api)
- [Terraform IaC](https://github.com/gabbyTI/cloud-resume-azure-infrastructure)

Below is a diagram of the entire system, showing all tools used in for this challenge and how it was implemented.

![Cloud Resume Challenge System Design](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/5gjnkdhq5ugek8z04jrs.png)

## 2. The Certification

First requirement for this challenge was to get the fundamental azure certification (AZ900). I studied for this with the [Microsoft learn](https://learn.microsoft.com/en-us/training/paths/microsoft-azure-fundamentals-describe-cloud-concepts/) website and it was helpful. A quick tip, the exam is a little bit more practical than you would expect, so as you go through the modules, practice on the azure portal (even as little as searching for the azure services).

## 3. The HTML, CSS & JavaScript Frontend

Don't know about you, but i used an existing HTML & CSS template for the website, mostly to speed up my development. You can check out the template right [HERE](https://www.themezy.com/free-website-templates/151-ceevee-free-responsive-website-template).
I wrote a JavaScript file where i call my python counter API, here is the code below:

```javascript
// Function to fetch visitor count from the API
function getVisitorCount() {
  fetch('https://<PYTHON_COUNTER_API_BASE_URL>/api/getvisitorcount', {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  })
    .then((response) => response.json())
    .then((data) => {
      // Update the counter on the webpage
      console.log('HEREEEE');
      document.querySelector('.counter').textContent = data.count;

      // Call updateVisitorCount with the current count
      updateVisitorCount();
    })
    .catch((error) => {
      console.error('Error fetching visitor count:', error);
    });
}

// Function to update visitor count on the API
function updateVisitorCount() {
  fetch('https://<PYTHON_COUNTER_API_BASE_URL>/api/updatevisitorcount', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({}),
  })
    .then((response) => response.json())
    .then((data) => {
      console.log('Visitor count updated successfully:', data);
    })
    .catch((error) => {
      console.error('Error updating visitor count:', error);
    });
}

// Fetch the visitor count and update on page load
document.addEventListener('DOMContentLoaded', getVisitorCount);
```

## 4. Backend Code: Python Counter API

I had some trouble when trying to write this initially, so much so, i had to rewrite the azure functions in NodeJS([here](https://github.com/gabbyTI/node-counter-api)) which worked fine, Then went back to it and discovered it was a python version constraint with the azure-functions-core-tools i had downloaded. Here is a little documentation on my backend

### 4.1. Prerequisite

1. Python v10 or higher
2. Azure CosmosDB for Table database connection string
3. Azure CLI
4. Install latest azure-functions-core-tools

```bash
npm install -g azure-functions-core-tools
```

### 4.2. Setup

4.2.1. Clone repository

```bash
git clone https://github.com/gabbyTI/python-counter-api.git
```

4.2.2. Initialize the azure function to create the

```bash
cd python-counter-api
func init
```

4.2.3. Install dependencies

```bash
pip install -r requirements.txt
```

4.2.4. Add connection string and table name to the local.settings.json file(this is created after the 2nd steps)

```json
{
  ...
  "Values": {
    ...
    "conn_str": "your connection string",
    "table_name": "your table name"
  }
}
```

### 4.3. Running Azure Function Locally

4.2.1. Login to Azure

```bash
az login
```

4.2.2. Start the azure function locally

```bash
func start -p 7071
```

## 5. Terraform IaC

Provisioning the infrastructure for this challenge was done entirely with terraform IaC tool. This was the most fun for me during this challenge because of there was much i learnt from this stage. I would say the best is the knowledge of how to use the comprehensive terraform provider documentations. I created the following resources with terraform

- Resource Group: containing all resources
- Azure Function
- ComosDB for Table API
- Storage Account & Static Website Container
- CDN Profile & Endpoint

I also implemented a remote backend for for my terraform state in a separate storage account and on a different resource group that i created manually. Checkout out my terraform scripts repository [**HERE**](https://github.com/gabbyTI/cloud-resume-azure-infrastructure)

## 6. Conclusion

As we come to the end of this part of our journey, I've decided to split it into two parts to make sure we can really dive deep into everything we've experienced. In this first part, we've gone over some of the most exciting moments and things I've learned along the way. From getting my Azure certification to putting together a cool website, it's been quite the ride with its fair share of challenges and triumphs.

But hold onto your hats because the fun isn't over yet! In the next part, we'll dig even deeper into the deployment pipelines that made all of this possible. We'll take a closer look at how these pipelines were set up and fine-tuned to make our deployment process smoother than ever. So get ready for more insights and behind-the-scenes action as we continue this adventure together!
[_Go to part two_](https://dev.to/gabbyti/cloud-resume-challenge-azure-edition-part-2-1ke)

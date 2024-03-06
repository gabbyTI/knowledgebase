## Table of Contents

- [Table of Contents](#table-of-contents)
- [Introduction](#introduction)
- [Understanding Point-to-Site (P2S) VPN Connection](#understanding-point-to-site-p2s-vpn-connection)
  - [P2S Example Sceneraio](#p2s-example-sceneraio)
- [Setting up P2S VPN Connection in Azure](#setting-up-p2s-vpn-connection-in-azure)
- [Step by step P2S VPN implementation](#step-by-step-p2s-vpn-implementation)
  - [Create resource group](#create-resource-group)
  - [Create virtual network](#create-virtual-network)
  - [Create gateway subnet](#create-gateway-subnet)
  - [Create virtual network gateway](#create-virtual-network-gateway)
  - [Point-to-Site Configuration](#point-to-site-configuration)
  - [Authorize the Azure VPN application](#authorize-the-azure-vpn-application)
  - [Download VPN Client Configuration](#download-vpn-client-configuration)
  - [Install the Azure VPN client](#install-the-azure-vpn-client)
  - [Import VPN Client Configuration](#import-vpn-client-configuration)
  - [Connect to the VPN](#connect-to-the-vpn)
- [Create Virtual Machine](#create-virtual-machine)
- [Logging into VM with Private IP](#logging-into-vm-with-private-ip)
- [Conclusion](#conclusion)

## Introduction

In a world where remote work has become a norm, ensuring secure and reliable access to company infrastructure has become increasingly important, Cloud solutions like Microsoft Azure offer tools for establishing secure connections between remote users and resources hosted in the cloud. One such tool is the Point-to-Site (P2S) VPN, a mechanism that enables individual devices to securely connect to your azure infrastructure.

In this guide, we'll walk through the process of setting up a Point-to-Site VPN connection in Azure, providing step-by-step instructions to on how you can establish a secure link between your local device and your Azure infrastructure.

## Understanding Point-to-Site (P2S) VPN Connection

Before diving into the setup process, let's briefly explain what a Point-to-Site VPN connection is and how it functions. In a Point-to-Site VPN configuration, individual client devices establish encrypted connections to a virtual network in Azure. This enables remote users to securely access resources such as Azure Virtual Machines, Azure SQL Databases, and other services within the virtual network, as if they were directly connected to it.

### P2S Example Sceneraio

A company XYZ has an Azure virtual machine (VM) resource that has both a public & private IP address and is secured behind a virtual private network. Usually, logging into the VM is done with the public IP address but this is unsecure because it goes through the internet. So the company decides to get rid of the public IP entirely and requies staff to access the VM with only the private IP.

When trying to access the VM with private IP, the staff encounter a connection error because that private IP address is not discoverable from outside the Azure virtual network. This means that attempting to access the VM solely via its private IP address from an external network, such as the internet or another corporate network, won't establish a connection due to network isolation.

To address this problem and make sure the staff can securely reach the VM, Company XYZ opts to set up a Point-to-Site (P2S) VPN connection in Azure. With this setup, our team members can safely connect to the Azure virtual network where the VM is located from anywhere they have internet access.

## Setting up P2S VPN Connection in Azure

We will go over setting up everything from scratch, including the virtual machine. Here are resources and tools that will be used in this setup:

- Resource Group
- Virtual Machine
- Virtual Network (VNet) and Subnets
- Virtual Network Gateway
- Azure VPN Client

## Step by step P2S VPN implementation

### Create resource group

Create a resource group with name "RGTEST1". This is the resource group that you will create every other resource in.
![Azure Resource group](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/yd8ts0jwd9w8bm9ajfl6.png)

### Create virtual network

Create a virtual network resource in the RGTEST1 resource group

- _**Name**: my-secure-vnet_
  ![Create a virtual network resource](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/04fo672j6fx6c485oiju.gif)

### Create gateway subnet

Create a gateway subnet in the "my-secure-vnet" virtual network
![Create a gateway subnet](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ou5b37qzrayuud9aey8g.gif)

### Create virtual network gateway

Create a virtual network gateway resource with the following details:
_**Name**: secure-vnet-gtw_
_**SKU**: VpnGw1_
_**Gateway Type**: VPN_
_**Generation**: Generation 1_
_**Virtual Network**: my-secure-vnet_
_**Public IP address name**: vnet-gtw-ip_
_**Enable active-active mode**: Disabled_
![Create a virtual network gateway](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/b4v64n73rixhptemxijp.png)

> :warning: **Price alert**: virtual network gateway is **NOT** free. Except the SKU type **VpnGw1** that is only free for the 1st 12 months of your azure free account subscription.
> :warning: **DELETE ALL RESOURCES AFTER PRACTICE**

### Point-to-Site Configuration

In the virtual network gateway resource, navigate to and click **_point-to-site-configuration_** under **_settings_** section in the left menu. Click on **_Configure now_**. You should see something like this:
![Configure P2S](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/wx6jbz2hvq8fm25zpxn9.png)
Use the details below to complete the configuration:

- _**Address pool** (can be any valid address range of your choice): 10.1.3.0/27_
- _**Tunnel type**: OpenVPN(SSL)_
- _**Authentication type**: Azure Active Directory_
- _**Tenant ID**: https://login.microsoftonline.com/<**YOUR_TENANT_ID**>/ (for your tenant id go to **Microsoft Entra ID** -> **Properties**)_
- _**Audience** (same for everyone): 41b23e61-6c1e-4545-b367-cd054e0ed4b4_
- _**Issuer**: https://sts.windows.net/<**YOUR_TENANT_ID**>/_

Click Save

![p2s config](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/elhor0pf8r1f820pyma7.png)

> **Note**:
> The trailing **" / "** is required
> Saving can take up to 30 minutes

### Authorize the Azure VPN application

Make sure you are signed into to your azure portal as a Global administrator.
Copy the link below.
Replace <**YOUR_TENANT_ID**> with your Azure tenant ID.

```
https://login.microsoftonline.com/<YOUR_TENANT_ID>/oauth2/authorize?client_id=41b23e61-6c1e-4545-b367-cd054e0ed4b4&response_type=code&redirect_uri=https://portal.azure.com&nonce=1234&prompt=admin_consent
```

You will be prompted to sign in again, sign in with the global administrator user. You should then see this
![Authorize the Azure VPN application](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/6ebr24215q4oxikowdbd.png)
Click "Accept"

### Download VPN Client Configuration

When the P2S configuration is done saving, refresh the page and click the Download VPN Client button
![Download VPN Client](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/xxx9q0mvet27cuugld5t.png)
A zipped file is downloaded, Extract the content to a folder. The contents are as shown below
![extracted contentent](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rv8e5sy26tflip5abts4.png)

### Install the Azure VPN client

Download and install the Azure VPN client from Microsoft Store (for windows PC) and Mac App Store (For Mac)
![az vpn client](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/d0hf19w11dhr5kvts5ln.png)

### Import VPN Client Configuration

Open the Azure VPN client and click the plus sign on the bottom left
![azure client](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/e78qb8q7f8a5omt6ccl2.png)
Click on Import
Navigate to the Extracted content fronme **step 7** and select the file `AzureVPN/azurevpnconfig.xml`.
After Importing, Click Save.
![Importing azure vpn client](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/1isqgc3z2j995t9l1q9d.gif)

### Connect to the VPN

When you click the connect button, you will be prompted to login to your azure account for authentication.
![Connect vpn](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hnut9i9mrroerjmncprs.png)

## Create Virtual Machine

Now that we have our network infrasture setup, we can go ahead and create a virtual machine that will be in the virtual network. I will be creating a windows VM, here are the details i used to create the vm:

Basics Tab

-** resource group**: RGTEST1

- **_Name_**: my-secure-vm
- **_Image_**: Windows Server 2019 Datacenter - x64 Gen2
- **_Size_**: Standard_B2s - 2 vcpus, 4 GiB memory
- **_Username_**: adminUser
- **_Password_**: \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*
- **_Public Inbound Ports_**: Allow Seleted Ports
- **_Select Inbound Ports_**: RDP (3389)

Networking Tab

- **_Virtual network_**: my-secure-vnet _(the vnet we created ealier)_
- **_Public IP_**: None _(We won't be needing a public facing IP address for this vm)_

> :warning: Price Alert: Creating a VM is **NOT** free
> **DELETE ALL RESOURCES AFTER PRACTICE**

Click Create
Go to the newly creted VM resource and get the **Private IP** address
![VM Private IP](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/v2veq98vj7gv5impwxl8.png)

## Logging into VM with Private IP

1. Connect your virtual network with Azure VPN Client
2. Open Remote Desktop Connection
3. Input the Private IP
4. Input Username and Password that we set when creating the VM
   ![Logging into VM with Private IP](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/lzdo5lzmdo3hfhrr1i4m.gif)

## Conclusion

Throughout this guide, we've navigated the process of setting up a Point-to-Site (P2S) VPN connection in Azure. From understanding the concept of P2S VPNs to configuring the necessary resources in Azure and connecting remote devices securely, we've covered the essentials. By implementing this solution, you can ensure secure access to your Azure infrastructure for your remote workforce, enabling seamless collaboration and productivity from any location.

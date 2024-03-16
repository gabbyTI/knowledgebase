#!/bin/bash
#
# Automate Installation of Docker
# Author: Gabriel Ibenye

# Update the apt package index and install packages to allow apt to use a repository over HTTPS
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the stable repository for your architecture (amd64)
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the apt package index again and install the latest version of Docker Engine and containerd
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Verify that Docker Engine is installed correctly
sudo docker --version

# Add your user to the docker group to run Docker commands without sudo
sudo usermod -aG docker ${USER}

echo "User added to the docker group. Logging out and back in to apply changes..."

echo "Docker setup completed."

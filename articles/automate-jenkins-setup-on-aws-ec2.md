- [Introduction](#introduction)
- [The Bash Script](#the-bash-script)
  - [docker-setup.sh](#docker-setupsh)
  - [jenkins-slave-setup.sh](#jenkins-slave-setupsh)
  - [jenkins-setup.sh](#jenkins-setupsh)
- [Terraform IaC Scripts](#terraform-iac-scripts)
  - [main.tf](#maintf)
  - [output.tf](#outputtf)
- [Conclusion](#conclusion)

## Introduction

Hey there! Welcome to the world of automation where we make tedious tasks disappear with the magic of scripts and infrastructure as code. Today, I'm going to share with you a practical solution for automating the setup of a Jenkins server and a slave node on AWS using Terraform and Bash scripts.

Forget about manual configurations and hours of tinkering. With the scripts I've crafted, you'll breeze through the process of provisioning an AWS EC2 instance and configuring Jenkins, all in a few simple steps.

No lengthy theoretical discussions here—just pure, hands-on automation goodness. So, let's dive straight into the action and see how Terraform and Bash can revolutionize your CI/CD pipeline setup.

![Image of files](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rvuubkeyfkzobe8rqmvi.png)

## The Bash Script

We have three bash scripts that will be used in this setup:

- Script to setup up Jenkins
- Script to install Docker
- Script to setup Jenkins slave server

### docker-setup.sh

```bash
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

```

### jenkins-slave-setup.sh

```bash
#!/bin/bash
#
# Automate Jenkins Slave Node Setup
# Author: Gabriel Ibenye
#
#######################################
# Print a message in a given color.
# Arguments:
#   Color. eg: green, red
#######################################
function print_color() {
  NC='\033[0m' # No Color

  case $1 in
  "green") COLOR='\033[0;32m' ;;
  "red") COLOR='\033[0;31m' ;;
  "*") COLOR='\033[0m' ;;
  esac

  echo -e "${COLOR} $2 ${NC}"
}

echo "---------------- JENKINS SLAVE NODE SETUP ------------------"

print_color "green" "Update apt repository. "
sudo apt update

print_color "green" "Installing Java(openjdk-17-jre)"
sudo apt install openjdk-17-jre -y

echo "---------------- SETUP COMPLETE ------------------"

```

### jenkins-setup.sh

```bash
#!/bin/bash
#
# Automate Installation of Jenkins
# Author: Gabriel Ibenye

#######################################
# Print a message in a given color.
# Arguments:
#   Color. eg: green, red
#######################################
function print_color() {
  NC='\033[0m' # No Color

  case $1 in
  "green") COLOR='\033[0;32m' ;;
  "red") COLOR='\033[0;31m' ;;
  "*") COLOR='\033[0m' ;;
  esac

  echo -e "${COLOR} $2 ${NC}"
}

#######################################
# Check the status of a given service. If not active exit script
# Arguments:
#   Service Name. eg: firewalld, mariadb
#######################################
function check_service_status() {
  service_is_active=$(sudo systemctl is-active $1)

  if [ $service_is_active = "active" ]; then
    echo "$1 is active and running"
  else
    echo "$1 is not active/running"
    exit 1
  fi
}

#######################################
# Check if a given service is enabled to run on boot. If not enabled exit script
# Arguments:
#   Service Name. eg: jenkins, mariadb
#######################################
function check_service_enable() {
  service_is_enabled=$(sudo systemctl is-enabled $1)

  if [ $service_is_enabled = "enabled" ]; then
    echo "$1 is enabled"
  else
    echo "$1 is not enabled"
    exit 1
  fi
}

#######################################
# Check the status of a firewalld rule. If not configured exit.
# Arguments:
#   Port Number. eg: 3306, 80
#######################################
function is_firewalld_rule_configured() {

  firewalld_ports=$(sudo firewall-cmd --list-all --zone=public | grep ports)

  if [[ $firewalld_ports == *$1* ]]; then
    echo "FirewallD has port $1 configured"
  else
    echo "FirewallD port $1 is not configured"
    exit 1
  fi
}

echo "---------------- Adding Debian package repository of Jenkins to apt repository ------------------"

print_color "green" "Download jenkins debian package repository. "
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

print_color "green" "Adding jenkins debian package to apt repository. "
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list >/dev/null

print_color "green" "Update apt repository. "
sudo apt update

print_color "green" "Installing fontconfig"
sudo apt install fontconfig -y

print_color "green" "Installing Java(openjdk-17-jre)"
sudo apt install openjdk-17-jre -y

print_color "green" "Installing Jenkins"
sudo apt install jenkins -y

print_color "green" "Enable jenkins service to run on boot"
sudo systemctl enable jenkins

print_color "green" "Starting jenkins service"
sudo systemctl start jenkins

# check Jenkins is enable
check_service_enable jenkins

# check Jenkins is running
check_service_status jenkins

print_color "green" "Opening jenkins default port (8080)"
sudo ufw allow 8080

print_color "green" "Opening OpenSSH port"
sudo ufw allow OpenSSH

print_color "green" "Enable Firewall"
yes | sudo ufw enable

echo "---------------- SETUP COMPLETE ------------------"

```

## Terraform IaC Scripts

With the IaC tool terraform, we will be provisioning 2 basic ec2 instances with a security group.

> Prerequisite: you should have your ssh private and public keys setup locally. To create these you can run the `ssh-keygen` command. Default location of the keys is `~/.ssh/` or in windows os `c:/users/<user>/.ssh/`.

### main.tf

```terraform
resource "aws_instance" "primary" {
  ami           = "ami-0e83be366243f524a"
  instance_type = "t2.micro"
  #running script
  user_data = file("path/to/bash/jenkins-setup.sh")
  tags = {
    "Name" = "Jenkins Server"
  }
  key_name               = aws_key_pair.web.id
  vpc_security_group_ids = [aws_security_group.primary.id]
}

resource "aws_instance" "slave" {
  ami           = "ami-0e83be366243f524a"
  instance_type = "t2.micro"
  #running script
  user_data = "${file("path/to/bash/jenkins-slave-setup.sh")}${file("path/to/bash/docker-setup.sh")}"
  tags = {
    "Name" = "Jenkins Slave"
  }
  key_name               = aws_key_pair.web.id
  vpc_security_group_ids = [aws_security_group.primary.id]
}

#Enabling ssh access
resource "aws_key_pair" "web" {
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "primary" {
  # SSH Port
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins port
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound connection over the internet
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
/**
* Creating node on jenkins
* First create a credential to login with username and private key
* Create the private key and public key on the jenkins slave (ssh-keygen)
* Use the private key on the jenkins credential you were creating earlier
* Copy and paste the public key into the authorized_keys file (~/.ssh/authorized_keys) of the slave server
* In the jenkins credentials select Non verifying Verification Strategy
*/
```

### output.tf

```terraform
output "jenkins_server_ip" {
  value = aws_instance.primary.public_ip
}
output "jenkins_slave_ip" {
  value = aws_instance.slave.public_ip
}
```

## Conclusion

In a nutshell, automating Jenkins setup on AWS with Terraform and Bash is a game-changer. Say goodbye to manual headaches and hello to streamlined processes. With just a few commands, you're up and running, saving time and hassle. Keep exploring and tweaking to fit your needs.
Happy automating!

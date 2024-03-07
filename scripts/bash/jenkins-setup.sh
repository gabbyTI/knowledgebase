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

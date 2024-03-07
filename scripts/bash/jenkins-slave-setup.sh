#!/bin/bash
#
# Automate Installation of Jenkins
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

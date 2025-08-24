output "ssh_private_key" {
  value     = tls_private_key.ssh_key.private_key_openssh
  sensitive = true
}

output "ssh_public_key" {
  value     = tls_private_key.ssh_key.public_key_openssh
  sensitive = true
}

output "eip" {
  value = aws_eip.eip.public_ip
}
output "nat_instance_id" {
  description = "ID of the NAT instance (from ASG)"
  value       = aws_autoscaling_group.nat_asg.name
}

output "nat_eni_id" {
  description = "ID of the NAT instance ENI"
  value       = aws_network_interface.nat_eni.id
}

output "nat_private_ip" {
  description = "Private IP of the NAT instance"
  value       = aws_network_interface.nat_eni.private_ip
}

output "nat_public_ip" {
  description = "Public IP of the NAT instance"
  value       = var.eip_allocation_id != null ? data.aws_eip.existing[0].public_ip : aws_eip.nat_eip[0].public_ip
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.nat_asg.name
}

data "aws_eip" "existing" {
  count = var.eip_allocation_id != null ? 1 : 0
  id    = var.eip_allocation_id
}
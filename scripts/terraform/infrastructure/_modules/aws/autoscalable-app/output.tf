output "alb_dns_name" {
  value = module.alb.lb_dns_name
}

#zoneid output
output "alb_zone_id" {
  value = module.alb.lb_zone_id
}

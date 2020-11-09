output "delegation_sets" {
  value = aws_route53_delegation_set.delegation-set.name_servers
}

output "master-zone" {
  value = element(concat(aws_route53_zone.master-zone.*.zone_id, list("")), 0)
}

resource aws_route53_delegation_set "delegation-set" {
  lifecycle {
    create_before_destroy = true
  }

  reference_name = var.reference_name
}

resource aws_route53_zone "master-zone" {
  name              = var.domain_name
  delegation_set_id = aws_route53_delegation_set.delegation-set.id

  tags = {
    Name    = var.domain_name
    Purpose = "Master zone"
  }
}

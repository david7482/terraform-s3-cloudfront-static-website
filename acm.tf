resource "aws_acm_certificate" "cert" {
  provider          = aws.us-east-1
  domain_name       = var.fqdn
  validation_method = "DNS"

  tags = merge(
    var.tags,
    {
      "Name" = var.website_name
    },
  )
}

resource "aws_route53_record" "cert_validation" {
  provider = aws.us-east-1
  name     = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type     = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id  = data.aws_route53_zone.main.id
  records  = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl      = 60
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
resource "aws_route53_zone" "war_pianka_io" {
  name = "war.pianka.io"
}

resource "aws_route53_record" "naked" {
  zone_id = aws_route53_zone.war_pianka_io.zone_id
  name    = "war.pianka.io"
  type    = "A"
  ttl     = 15

  records = ["54.177.96.16"]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.war_pianka_io.zone_id
  name    = "db.war.pianka.io"
  type    = "A"

  alias {
    name                   = aws_db_instance.warnet.address
    zone_id                = aws_db_instance.warnet.hosted_zone_id
    evaluate_target_health = true
  }
}

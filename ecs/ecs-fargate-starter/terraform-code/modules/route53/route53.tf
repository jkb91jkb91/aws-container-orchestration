
data "aws_route53_zone" "this" {
    name = var.hosted_zone_name
    private_zone = false
}

resource "aws_route53_record" "alias" {
    zone_id = data.aws_route53_zone.this.zone_id
    name = var.hosted_zone_name
    type = "A"

alias {
    name = var.loadb_name
    zone_id = "Z35SXDOTRQ7X7K"
    evaluate_target_health = true
 }
}

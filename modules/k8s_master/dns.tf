data "aws_instance" "master" {
  depends_on = ["aws_autoscaling_group.master"]
  instance_tags {
    "aws:autoscaling:groupName" = "${aws_autoscaling_group.master.name}"
    Name                        = "k8s-${var.name}-master"
    Version                     = "${var.version}"
  }

  filter {
    name = "instance-state-name"

    values = [
      "running",
    ]
  }
}

resource "aws_route53_record" "api" {
  zone_id = "${var.dns_zone_id}"
  name    = "api.${var.name}.${var.datacenter}"
  type    = "A"
  ttl     = "300"
  records = ["${data.aws_instance.master.private_ip}"]
}

// Master
# IAM Profile to add access to cloud-provider features.
resource "aws_iam_instance_profile" "masters" {
  name = "kube_${var.name}_masters"
  role = "${aws_iam_role.masters.name}"
  path = "/kube/${var.name}/"
}

resource "aws_iam_role" "masters" {
  name               = "kube_${var.name}_masters"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_policy")}"
  path               = "/kube/${var.name}/"
}

resource "aws_iam_role_policy" "masters" {
  name   = "kube_${var.name}_masters"
  role   = "${aws_iam_role.masters.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters_policy")}"
}

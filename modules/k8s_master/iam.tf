// Master
# IAM Profile to add access to cloud-provider features.
resource "aws_iam_instance_profile" "masters" {
  name = "k8s-${var.name}-masters"
  role = "${aws_iam_role.masters.name}"
  path = "/k8s/"
}

resource "aws_iam_role" "masters" {
  name               = "k8s-${var.name}-masters"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_policy")}"
  path               = "/k8s/"
}

resource "aws_iam_role_policy" "masters" {
  name   = "k8s-${var.name}-masters"
  role   = "${aws_iam_role.masters.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters_policy")}"
}

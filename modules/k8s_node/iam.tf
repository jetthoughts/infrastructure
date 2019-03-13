// Nodes
# IAM Profile to add access to cloud-provider features.
resource "aws_iam_instance_profile" "nodes" {
  name = "kube_${var.name}_nodes"
  role = "${aws_iam_role.nodes.name}"
  path = "/kube/${var.name}/"
}

resource "aws_iam_role" "nodes" {
  name               = "kube_${var.name}_nodes"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_policy")}"
  path               = "/kube/${var.name}/"
}

resource "aws_iam_role_policy" "nodes" {
  name   = "kube_${var.name}_nodes"
  role   = "${aws_iam_role.nodes.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes_policy")}"
}

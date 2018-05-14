// Nodes
# IAM Profile to add access to cloud-provider features.
resource "aws_iam_instance_profile" "nodes" {
  name = "k8s-nodes-${var.name}"
  role = "${aws_iam_role.nodes.name}"
  path = "/k8s/"
}

resource "aws_iam_role" "nodes" {
  name               = "k8s-nodes-${var.name}"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_policy")}"
  path               = "/k8s/"
}

resource "aws_iam_role_policy" "nodes" {
  name   = "k8s-nodes-${var.name}"
  role   = "${aws_iam_role.nodes.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes_policy")}"
}

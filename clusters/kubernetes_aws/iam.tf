// Master
# IAM Profile to add access to cloud-provider features.
resource "aws_iam_instance_profile" "masters" {
  name = "k8s-masters"
  role = "${aws_iam_role.masters.name}"
}

resource "aws_iam_role" "masters" {
  name               = "k8s-masters"
  assume_role_policy = "${file("data/aws_iam_role_policy")}"
}

resource "aws_iam_role_policy" "masters" {
  name   = "k8s-masters"
  role   = "${aws_iam_role.masters.name}"
  policy = "${file("data/aws_iam_role_policy_masters_policy")}"
}

// Nodes
# IAM Profile to add access to cloud-provider features.
resource "aws_iam_instance_profile" "nodes" {
  name = "k8s-nodes"
  role = "${aws_iam_role.nodes.name}"
}

resource "aws_iam_role" "nodes" {
  name               = "k8s-nodes"
  assume_role_policy = "${file("data/aws_iam_role_policy")}"
}

resource "aws_iam_role_policy" "nodes" {
  name   = "k8s-nodes"
  role   = "${aws_iam_role.nodes.name}"
  policy = "${file("data/aws_iam_role_policy_nodes_policy")}"
}

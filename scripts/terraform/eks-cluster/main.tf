data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks" {
  name               = "eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role" "nodegroup" {
  name = "eks-nodegroup-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "primary_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "primary_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "primary_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodegroup.name
}

resource "aws_iam_role_policy_attachment" "primary_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodegroup.name
}

resource "aws_iam_role_policy_attachment" "primary_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodegroup.name
}

resource "aws_eks_cluster" "primary" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.primary_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.primary_AmazonEKSVPCResourceController,
  ]
}

# Define the EKS node group
resource "aws_eks_node_group" "primary" {
  cluster_name    = aws_eks_cluster.primary.name
  node_group_name = "eks-project-node-group"
  node_role_arn   = aws_iam_role.nodegroup.arn
  subnet_ids      = [var.subnet_ids[1]] # Specify the subnet ID(s) where the nodes will be deployed
  instance_types  = ["m5.large"]

  scaling_config {
    desired_size = 1 # Specify the desired number of nodes
    max_size     = 5 # Specify the maximum number of nodes
    min_size     = 1 # Specify the minimum number of nodes
  }

  depends_on = [
    aws_iam_role_policy_attachment.primary_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.primary_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.primary_AmazonEC2ContainerRegistryReadOnly,
  ]

}

/** How to connect to cluster
*
* aws eks update-kubeconfig --name eks_project
* kubectl config set-context <context-name>
*
*
*/

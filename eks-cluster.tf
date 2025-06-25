// Define an IAM role for the EKS cluster control plane
resource "aws_iam_role" "eks_cluster" {
  name = "devops-tech-test-eks-cluster-role"

  // Specify the permissions for assuming this role
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

// Attach AmazonEKSClusterPolicy to the IAM role created for EKS cluster
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

// Attach AmazonEKSServicePolicy to the IAM role created for EKS cluster
resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

// Create an EKS cluster
resource "aws_eks_cluster" "aws_eks" {
  name     = "devops-tech-test"
  role_arn = aws_iam_role.eks_cluster.arn

  // Configure VPC for the EKS cluster
  vpc_config {
    subnet_ids = ["subnet-0c7d382e75b53a87a", "subnet-079b546b6b81e2ce2"]
  }

  // Add tags to the EKS cluster for identification
  tags = {
    Name = "devops-tech-test"
  }
}

// Define an IAM role for EKS worker nodes
resource "aws_iam_role" "eks_nodes" {
  name = "devops-tech-test-eks-node-group-role"

  // Specify the permissions for assuming this role
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

// Attach AmazonEKSWorkerNodePolicy to the IAM role created for EKS worker nodes
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

// Attach AmazonEKS_CNI_Policy to the IAM role created for EKS worker nodes
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

// Attach AmazonEC2ContainerRegistryReadOnly to the IAM role created for EKS worker nodes
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

// Create an EKS node group
resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "system"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = ["subnet-0c7d382e75b53a87a", "subnet-079b546b6b81e2ce2"]
  // Configure scaling options for the node group
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  instance_types = ["t3.medium"]

  // Ensure that the creation of the node group depends on the IAM role policies being attached
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_user" "eks_iam_user" {
  name = "eks-iam-user"
}

// Attach AmazonEKSClusterPolicy to the IAM role created for eks-iam-user
resource "aws_iam_user_policy_attachment" "eks_cluster_policy" {
  user       = aws_iam_user.eks_iam_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

// Attach AmazonEKSWorkerNodePolicy to the IAM role created for eks-iam-user
resource "aws_iam_user_policy_attachment" "eks_worker_node_policy" {
  user       = aws_iam_user.eks_iam_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

// Attach AmazonEKS_CNI_Policy to the IAM role created for eks-iam-user
resource "aws_iam_user_policy_attachment" "eks_cni_policy" {
  user       = aws_iam_user.eks_iam_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

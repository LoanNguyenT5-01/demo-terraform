# Create ECR Repository
resource "aws_ecr_repository" "main_repository" {
  name                 = "my-application-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "ECR-Repository"
  }
}

# Create EKS Cluster
resource "aws_eks_cluster" "main_eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnet.*.id
  }

  tags = {
    Name = "EKS-Cluster"
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
      }
    ]
  })
}

# Policy IAM Role for EKS
resource "aws_iam_role_policy_attachment" "eks_policy_attach" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create Subnet for EKS Cluster
resource "aws_subnet" "eks_subnet" {
  count                   = 2 # Create 2 subnet
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
}

# Create VPC cho EKS Cluster
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "EKS-VPC"
  }
}

# Get Availability Zones
data "aws_availability_zones" "available" {}

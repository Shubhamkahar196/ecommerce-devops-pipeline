module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.name
  kubernetes_version = "1.31"

  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  


  eks_managed_node_groups = {
    ecommerce-demo-ng = {
      min_size       = 2
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      disk_size      = 35

      tags = {
        Name        = "ecommerce-ng"
        Environment = "dev"
      }
    }
  }

  tags = {
    Environment = "dev"
    Project     = "ecommerce"
  }
}

data "aws_instances" "eks_nodes" {
  instance_tags = {
    "eks:cluster-name" = module.eks.cluster_name
  }
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
  depends_on = [module.eks]
}
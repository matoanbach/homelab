1. What do the declarations, such as name, cidr, and azs, in the following Terraform code represent and what purpose do they serve?
```
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"
 
  name = var.vpc_name
  cidr = var.vpc_cidr
 
  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets
 
  enable_nat_gateway = var.vpc_enable_nat_gateway
 
  tags = var.vpc_tags
}
```
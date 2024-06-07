
################################################################################
# VPC for both regions
################################################################################


module "primary_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.primary_vpc_cidr

  azs              = local.primary_azs
  public_subnets   = [for k, v in local.primary_azs : cidrsubnet(local.primary_vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.primary_azs : cidrsubnet(local.primary_vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.primary_azs : cidrsubnet(local.primary_vpc_cidr, 8, k + 6)]

  create_database_subnet_group = true

  tags = local.tags
}


module "secondary_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = { aws = aws.region2 }

  name = local.name
  cidr = local.secondary_vpc_cidr

  azs              = local.secondary_azs
  public_subnets   = [for k, v in local.secondary_azs : cidrsubnet(local.secondary_vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.secondary_azs : cidrsubnet(local.secondary_vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.secondary_azs : cidrsubnet(local.secondary_vpc_cidr, 8, k + 6)]

  create_database_subnet_group = true

  tags = local.tags
}



# resource "aws_db_subnet_group" "this" {
#   name       = "mssql-region-1"
#   subnet_ids = var.subnet_ids_region1

#   tags = {
#     Name = "mssql-region-1"
#   }
# }

# resource "aws_db_subnet_group" "this2" {
#   name       = "mssql-region-2"
#   subnet_ids = var.subnet_ids_region2

#   provider = aws.region2

#   tags = {
#     Name = "mssql-region-2"
#   }
# }

module "security_group_region1" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "Replica MSSQL security group"
  vpc_id      = module.primary_vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "MSSQL access from within VPC"
      cidr_blocks = module.primary_vpc.vpc_cidr_block
      
    },
  ]

  tags = local.tags
}


module "security_group_region2" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.region2
  }

  name        = local.name
  description = "Replica MSSQL security group"
  vpc_id      = module.secondary_vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "MSSQL access from within VPC"
      cidr_blocks = module.secondary_vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}
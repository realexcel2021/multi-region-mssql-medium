provider "aws" {
  region = local.region1
}

provider "aws" {
  alias  = "region2"
  region = local.region2
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "primary" {}
data "aws_availability_zones" "secondary" {
  provider = aws.region2
}

locals {
  name    = "replica-mssql"
  region1 = "us-east-1"
  region2 = "us-east-2"

  tags = {
    Name       = local.name
  }

  
  primary_vpc_cidr = "10.0.0.0/16"
  primary_azs      = slice(data.aws_availability_zones.primary.names, 0, 3)

  secondary_vpc_cidr = "10.1.0.0/16"
  secondary_azs      = slice(data.aws_availability_zones.secondary.names, 0, 2)

  engine                = "sqlserver-ee"
  engine_version        = "15.00"
  family                = "sqlserver-ee-15.0" # DB parameter group
  major_engine_version  = "15.00"         # DB option group
  instance_class        = "db.t3.xlarge"
  allocated_storage     = 20
  max_allocated_storage = 100
  port                  = 1433
}

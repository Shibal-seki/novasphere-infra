module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "novasphere-${var.environment}"
  cidr = var.vpc_cidr

  azs = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  enable_nat_gateway      = false
  create_igw              = true
  map_public_ip_on_launch = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
}

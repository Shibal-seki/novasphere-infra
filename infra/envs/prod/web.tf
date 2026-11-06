# Image Amazon Linux 2023
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Profil IAM existant dans AWS Academy
data "aws_iam_instance_profile" "lab" {
  name = "LabInstanceProfile"
}

# Module personnel publie sur GitHub
module "web_stack" {
  source = "git::https://github.com/Shibal-seki/terraform-aws-web-stack.git?ref=v1.0.0"

  name                  = "novasphere"
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnets
  ami_id                = data.aws_ami.al2023.id
  instance_type         = var.instance_type
  instance_profile_name = data.aws_iam_instance_profile.lab.name
  desired_capacity      = var.desired_capacity
  depends_on            = [aws_ssm_parameter.db_password]

  user_data = templatefile("${path.module}/bootstrap.sh.tftpl", {
    environment = var.environment
  })
}

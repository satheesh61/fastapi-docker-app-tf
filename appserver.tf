
resource "aws_key_pair" "api_app_kp_01" {
    public_key = var.ec2_public_key
    key_name = "api-app-kp-01"
}
module "api_app_server_sg_01" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~>4.15.0"
  name   = "${local.api_name}-sg-01"
  vpc_id = module.api_demo_vpc.vpc_id
  ingress_with_source_security_group_id = [

  ]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "22"
      description = "allow 22 port to Instance connect "
      cidr_blocks = "0.0.0.0/0"        # update with your IP
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "allow http port to connect with API "
      cidr_blocks = "0.0.0.0/0"        # update with your IP
    },
    
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = -1
      description = "allow all traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  tags = merge(
    local.common_tags
  )
}

module "api_app_server_ec2_01"{
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~>5.6.0"
  name                        = "${local.api_name}-ec2-01"
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3a.medium" 
  availability_zone           = element(module.api_demo_vpc.azs, 0)
  subnet_id                   = element(module.api_demo_vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.api_app_server_sg_01.security_group_id]
  key_name                    = aws_key_pair.api_app_kp_01.key_name
  associate_public_ip_address = true
  disable_api_stop            = false
  iam_instance_profile        = aws_iam_instance_profile.fastapi_demo_instance_profile.name
  user_data_base64            = base64encode(var.ec2_userdata.userdata)
  user_data_replace_on_change = true
  enable_volume_tags = true
  #root_volume_size        = 20
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 20
    },
  ]

  tags = merge(
      local.common_tags,
      {"${var.ec2_tag_key}" = "${var.ec2_tag_value}"},
  ) 
  }


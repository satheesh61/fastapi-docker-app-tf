locals {
  api_name = "fast-api-demo"
  region = "ap-south-1"
  vpc_cidr = "10.10.0.0/16"
  public_subnets  = ["10.10.1.0/24", "10.10.2.0/24","10.10.3.0/24"]
  private_subnets = ["10.10.4.0/24", "10.10.5.0/24","10.10.6.0/24"]
  common_tags = {
    demo = local.api_name,
    map-migrated = "d-server-01w1643zlizp1x"
  }
}

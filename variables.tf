variable "project_name" {
    type = string
    description = "Enter the codepipeline project name"
}

variable "codestarconnection_name" {
    type    = string
    description = "codestar connection name"
  }
variable "github_owner" {
    type = string
    description = "Git hub owner name"
  
}
variable "tags" {
    type = map(string)
    description = "Enter all the tags values"
}

variable "s3_bucket_name"{
    type = string
    description = "Enter the S3 Bucket name"
}

variable "githubrepo_name" {
    type = string
    description = "Enter the githubrepo name in this format organiztion/reponame"
}
variable "backend_ecr_repo"{
    type = string
    description = "Enter the backend repo name"
}

variable "apicodebuild_name" {
    type = string
    description = "Enter the API code build project name"
}
variable "codedeploy_name" {
    type = string
    description = "Enter the code deploy project name"
}
variable "codedeploy_groupname" {
    type = string
    description = "Enter the code deploy group name"
}

variable "ec2_tag_key" {
    type = string
    description = "Enter tag key to filter the Ec2 instance"
}

variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type = string
  default = "eks-terraform-key"
}

variable "ec2_tag_value" {
    type = string
    description = "Enter tag value to filter the Ec2 instance"  
}
variable "ec2_ami" {
    type = string
    description = "Enter Ami ID of the Ec2 instance"  
}
variable "ec2_public_key" {
    type = string
    description = "Enter oublic key value of the Ec2 instance"
}
variable "ec2_userdata" {
  description = "Teleport Userdata"
  type        = map

  default = {
  userdata = <<-EOT
  #!/bin/bash
  sudo yum update
  sudo amazon-linux-extras install docker
  sudo systemctl start docker
  sudo usermod -a -G docker ec2-user
  sudo su ec2-user
  sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  docker-compose version
  sudo yum install ruby -y
  sudo yum install wget -y
  cd /home/ec2-user
  wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
  sudo chmod +x ./install
  sudo ./install auto
  sudo systemctl start docker
  EOT
  }
}




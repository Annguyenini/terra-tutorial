terraform {
  required_providers {
    aws ={
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance""example"{
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.nano"
  tags = {
      Name = "ubuntu-server"
    }
}

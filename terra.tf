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
data "aws_vpc" "default"{
  default = true
}
//create group
resource "aws_security_group" "custom" {
  name ="ssh"
  description = "allow ssh"
  vpc_id = data.aws_vpc.default.id
}
//create allow 22 inbound rule for group
resource "aws_security_group_rule" "allow_SSH" {
  type = "ingress"
  description = "SSH ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.custom.id
}
//create allow 80 inbound rule for group
resource "aws_security_group_rule" "allow_80" {
  type="ingress"
  description = "allow http"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.custom.id
}
//create outbound rule for group
resource "aws_security_group_rule" "allow_all_trafic_out_bound" {
  type = "egress"
  description = "Allow all traffic outbound"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
security_group_id = aws_security_group.custom.id
}
resource "aws_key_pair" "deployer"{
  key_name = "test"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCi0cdkS1olCcMNa2l1hWp+KkvRHSzztlecYSdp7XGdVW3cX6044bPY0VAw+nT7pAp9lXmMw3iEepXdp2CKjD8SvPKH23YwwVTCHcS1ykpcO9dfqExvvTyXieizQpXOMLUjbjme1u6mpIofQqztaGCbWknoKpsazQUSDNQmQKRf5Se4UCHEeYGRAoGj/hDegRN3KwePLKlMH4EaUK0G0KELaWTEO7HKsv8uEE288UYUYB1o8SJZ4FOk+EtBmXlcMIyRpweLF9+fJYyLF4GtHKW978S3Hw/S+rQCe6zns1cZV93O8iI4Ri4ItQ1oECaFn5sGUBuKbaaZWSEbOF/VEkRLUW7SdfqgZhCjnuL5p4085dHW+Whm0qCf9ZIy8TJxBFLNOmTyszbJ/VFkTKwAnt6rcyILgwe3fGs9PW14uwa6UOPQJAVRgaAfq5gXUW+GLVm298thHXtc3a3aCU9rJluwJ8Fg+fTEm/AauEhvjwWCJ6YYfIH59UmrFXkMDrp3/XRAJYJ71V/J2PRf/16HCp0TzxGnPfhg+Z1J51xU9OcHSstBtWG04yvYp4k0E9++CXoJqJiyVgOolHc6fqpSSIuRLqfOpkyH1Wb1Av426xw/+LZcZ/EAxsUJmXlvHh+4jWab7Ne5QsKZAhkgbSRWB5GUDq7NGjLLGbogoR5+zJBcYw== annguyen@AnLap"
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

resource "aws_instance" "example"{
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.deployer.key_name
  user_data = file("${path.module}/init.sh")
  tags = {
      Name = var.instance_name
    }
  vpc_security_group_ids = [aws_security_group.custom.id]
}

resource "aws_eip" "static_ip"{
  instance = aws_instance.example.id

  tags = {
    Name = "my-static-ip"
  }
}
output "static_ip" {
  value = aws_eip.static_ip
}


# AWS provider
provider "aws" {
  region = "us-east-1" 
}

# Creating VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

# Three subnets in different AZs
resource "aws_subnet" "subnet1" {
  count = 3
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.${4 + count.index}.0/24"
  availability_zone = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)
  tags = {
    Name = "Subnet-${count.index + 1}"
  }
}

#Two instances in two different subnets
resource "aws_instance" "instance1" {
  count = 2
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"     
  subnet_id     = element(aws_subnet.subnet1[*].id, count.index % 2)
  tags = {
    Name = "Instance-${count.index + 1}"
  }
}

# security group to allow necessary traffic
resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# Find the latest Ubuntu Server 24.04 LTS AMI from Canonical
# This replaces manually selecting Ubuntu in the AWS Console
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get a list of available availability zones in the selected AWS region
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC for the Minecraft server
resource "aws_vpc" "minecraft_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "minecraft_igw" {
  vpc_id = aws_vpc.minecraft_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create a public subnet for the EC2 instance
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.minecraft_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Create a public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.minecraft_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.minecraft_igw.id
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security group for SSH and Minecraft Java Edition traffic
resource "aws_security_group" "minecraft_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH and Minecraft Java Edition traffic"
  vpc_id      = aws_vpc.minecraft_vpc.id

  # Allows SSH so Ansible can configure the instance
  ingress {
    description = "SSH access for Ansible configuration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Allows Minecraft Java Edition connections
  # Port 25565 is the default Minecraft Java server port
  ingress {
    description = "Minecraft Java Edition port"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = [var.allowed_minecraft_cidr]
  }

  # Allows the server to download updates, Java, and the Minecraft server jar
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# Upload your local public SSH key to AWS.
# Terraform uses the .pub file
resource "aws_key_pair" "minecraft_key" {
  key_name   = "${var.project_name}-key"
  public_key = file(pathexpand(var.public_key_path))
}

# Create the EC2 instance that will run the Minecraft server
resource "aws_instance" "minecraft_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.minecraft_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.minecraft_key.key_name

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name = var.project_name
  }
}
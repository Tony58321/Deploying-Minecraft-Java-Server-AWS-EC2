variable "aws_region" {
  description = "AWS region where the Minecraft server will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used for AWS resources."
  type        = string
  default     = "minecraft-java-server"
}

variable "instance_type" {
  description = "EC2 instance type for the Minecraft server."
  type        = string
  default     = "t2.medium"
}

variable "public_key_path" {
  description = "Path to the local public SSH key Terraform will upload to AWS."
  type        = string
  default     = "C:/2025-26/System Admin/AWS/minecraft-key.pub"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the server. For a lab/demo, 0.0.0.0/0 is acceptable."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_minecraft_cidr" {
  description = "CIDR block allowed to connect to the Minecraft server."
  type        = string
  default     = "0.0.0.0/0"
}
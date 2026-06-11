# Deploying a Minecraft Java Server on AWS EC2

## Background

This project automates the deployment of a Minecraft Java Edition server on AWS EC2. In Part 1, the server was deployed manually using the AWS Management Console, SSH, Java installation commands, Minecraft server setup, and a systemd service. In this project, those manual steps are converted into scripts so the infrastructure and server configuration can be recreated automatically.

## Tools Used

- AWS CLI
- Terraform
- Ansible
- Bash
- nmap
- Minecraft Java Edition

## Requirements

Before running this project, the user needs:

- An AWS Academy or standard AWS account
- AWS CLI configured with valid credentials
- Terraform installed
- Ansible installed
- nmap installed
- A local SSH key pair
- Git installed

## Project Structure

```text
deploying-minecraft-java-server-aws-ec2/
├── README.md
├── terraform/
│   ├── provider.tf
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ansible/
│   └── playbook.yml
├── scripts/
│   ├── setup.sh
│   ├── provision.sh
│   ├── configure.sh
│   ├── verify.sh
│   └── destroy.sh
└── docs/
    └── pipeline-diagram.md
```
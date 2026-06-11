# Deploying a Minecraft Java Server on AWS EC2

## Background

This project automates the deployment of a Minecraft Java Edition server on AWS EC2. In Part 1, the server was deployed manually using the AWS Management Console, SSH, Java installation commands, Minecraft server setup, and a systemd service. In this project, those manual steps are converted into scripts so the infrastructure and server configuration can be recreated automatically.

Terraform provisions the AWS infrastructure and Ansible configures the EC2 instance. Ansible installs Java, downloads the Minecraft server, and sets up the systemd service that starts automatically. Everything runs from the command line without opening the AWS Management Console.

## Requirements
### Tools Used
The following tools must be installed before running the project:

| Tool | Version Used | Install |
|------|-------------|---------|
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.6.0 | `brew install terraform` or [download](https://developer.hashicorp.com/terraform/install) |
| [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html) | >= 2.14 | `sudo apt install ansible -y` |
| [nmap](https://nmap.org/download) | any | `sudo apt install nmap -y` |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) | >= 2.0 | see link |
| SSH | any | pre-installed on Linux/macOS/WSL |
| [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) (Windows only) | >= 2 | `wsl --install` in PowerShell as Administrator |

> **Windows users:** These scripts must be run from [WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/install) with Ubuntu. Git Bash alone is not sufficient because Ansible does not run natively on Windows.

### AWS Credentials
This project requires valid AWS credentials. If using AWS Academy Learner Lab, start your lab session and copy the credentials from AWS Details > AWS CLI.

Inside WSL/Ubuntu, create the credentials file:

```bash
mkdir -p ~/.aws
nano ~/.aws/credentials
```

Paste your credentials in this format:
 
```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
aws_session_token = YOUR_SESSION_TOKEN
```
 
Then create the config file:
 
```bash
nano ~/.aws/config
```
 
```ini
[default]
region = us-east-1
output = json
```
 
> **Note:** AWS Academy credentials expire at the end of each lab session. You will need to replace the contents of `~/.aws/credentials` each time you start a new session.
 
> **Never commit AWS credentials to GitHub.**

### SSH Key Setup
 
This project expects an SSH key pair at:
 
```text
~/.ssh/minecraft-key.pem   # private key (used by SSH and Ansible)
~/.ssh/minecraft-key.pub   # public key (uploaded to AWS by Terraform)
```
 
If you already have the `.pem` file, generate the public key with:
 
```bash
ssh-keygen -y -f ~/.ssh/minecraft-key.pem > ~/.ssh/minecraft-key.pub
chmod 400 ~/.ssh/minecraft-key.pem
```
 
---

## Project Structure

```text
deploying-minecraft-java-server-aws-ec2/
├── README.md
├── terraform/
│   ├── provider.tf       # AWS provider and Terraform version config
│   ├── main.tf           # VPC, subnet, security group, EC2 instance
│   ├── variables.tf      # Input variables
│   └── outputs.tf        # Public IP, server address, nmap command
├── ansible/
│   └── playbook.yml      # Installs Java, Minecraft, and systemd service
└── scripts/
    ├── setup.sh          # Checks required tools and SSH key
    ├── provision.sh      # Runs Terraform to create AWS infrastructure
    ├── configure.sh      # Runs Ansible to configure the server
    ├── verify.sh         # Verifies port 25565 is open with nmap
    └── destroy.sh        # Tears down all AWS infrastructure
```

---
 
## Pipeline
 
```text
User runs scripts
        │
        ▼
setup.sh checks tools and SSH key
        │
        ▼
provision.sh → Terraform creates:
  - VPC, subnet, internet gateway, route table
  - Security group (ports 22 and 25565)
  - EC2 key pair and Ubuntu EC2 instance (t2.medium)
        │
        ▼
configure.sh → Ansible connects over SSH and:
  - Installs Java 25 (Eclipse Temurin)
  - Downloads the Minecraft server JAR
  - Accepts the EULA
  - Creates and enables a systemd service
        │
        ▼
verify.sh → nmap confirms port 25565 is open
        │
        ▼
Connect from Minecraft Java Edition
```

---

## How to Run

Run all commands from the root of the repository inside WSL/Ubuntu.

### Step 1 — Check Required Tools
 
```bash
./scripts/setup.sh
```
 
Verifies that Terraform, Ansible, nmap, SSH, and your SSH private key are all present. Fix any missing tools before continuing.
 
### Step 2 — Provision AWS Infrastructure
 
```bash
./scripts/provision.sh
```
 
Runs `terraform init`, `terraform fmt`, `terraform validate`, and `terraform apply` to create the AWS resources. When finished, Terraform prints the EC2 public IP address.
 
### Step 3 — Configure the Server
 
```bash
./scripts/configure.sh
```
 
Reads the public IP from Terraform output, builds an Ansible inventory file, and runs the Ansible playbook. The playbook installs Java 25, downloads the Minecraft server JAR, accepts the EULA, and starts the `systemd` service.
 
### Step 4 — Verify the Server
 
```bash
./scripts/verify.sh
```
 
Runs an nmap scan against TCP port `25565`. A successful result looks like:
 
```text
PORT      STATE SERVICE   VERSION
25565/tcp open  minecraft Minecraft 26.1.2 (Protocol: 127, Message: A Minecraft Server, Users: 0/20)
```
 
### Step 5 — Connect from Minecraft Java Edition
 
Open Minecraft Java Edition and go to **Multiplayer > Add Server**.
 
Get the server address from Terraform:
 
```bash
terraform -chdir=terraform output minecraft_server_address
```
 
Enter that address (format: `PUBLIC_IP:25565`) as the server address and connect.
 
### Step 6 — Destroy Resources
 
When finished, tear down all AWS resources to avoid unnecessary charges:
 
```bash
./scripts/destroy.sh
```
 
---
 
## Security Notes
 
SSH and Minecraft traffic are open to `0.0.0.0/0` for lab and demo purposes. For a production server, restrict SSH to a trusted IP address using the `allowed_ssh_cidr` variable in `terraform/variables.tf`.
 
The following files should never be committed to GitHub:
 
```text
*.pem
terraform.tfstate
terraform.tfstate.backup
.aws/
ansible/inventory.ini
```
 
---
 
## Troubleshooting
 
**Terraform says credentials are expired**
Start a new AWS Academy lab session, copy the new credentials, and replace `~/.aws/credentials`.
 
**Terraform cannot find the SSH public key**
Run `ls -l ~/.ssh/minecraft-key.pub` to check. If missing, regenerate it:
```bash
ssh-keygen -y -f ~/.ssh/minecraft-key.pem > ~/.ssh/minecraft-key.pub
```
 
**Ansible cannot connect to the instance**
The instance may still be initializing. Wait 30–60 seconds and re-run `./scripts/configure.sh`.
 
**nmap does not show port 25565 as open**
The Minecraft server takes a minute or two to fully start. Wait and re-run `./scripts/verify.sh`. If it still fails, re-run `./scripts/configure.sh`.
 
---
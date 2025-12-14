# 🏗️ Terraform – WordPress Infrastructure (Dev Environment)

This repository contains a **modular Terraform setup** for deploying a **WordPress infrastructure on AWS**.

The current state focuses on a **single development environment (`dev`)**, with a clear separation between:
- Environment-specific configuration
- Reusable Terraform modules

---

## 📁 Project Structure

```text
.
├── envs/
│   └── dev/                    # Development environment
│       ├── main.tf             # Root module – wires all sub-modules together
│       ├── variables.tf        # Input variables for the dev environment
│       ├── outputs.tf          # Outputs exposed from the dev environment
│       ├── providers.tf        # AWS provider configuration
│       ├── versions.tf         # Terraform & provider version constraints
│       ├── terraform.tfvars    # Dev-specific variable values
│       ├── terraform.tfstate   # Terraform state (local, dev only)
│       ├── tfplan              # Saved terraform plan
│       └── .terraform/         # Terraform working directory (generated)
│
├── modules/                    # Reusable Terraform modules
│   ├── vpc/
│   ├── alb/
│   ├── asg-wordpress/
│   ├── efs-wp-content/
│   └── rds-mysql/
│
├── .gitignore
└── README.md
```

---

## 🧩 Terraform Modules

### 🌐 vpc
Responsible for networking primitives:
- VPC
- Subnets
- Network-level outputs required by other modules

This module acts as the foundation for all other infrastructure components.

---

### ⚖️ alb
Creates an **Application Load Balancer** that:
- Exposes WordPress to the internet
- Routes HTTP/HTTPS traffic to EC2 instances
- Integrates with Auto Scaling Group targets (instance mode)

---

### 🚀 asg-wordpress
Deploys WordPress compute using:
- Auto Scaling Group (ASG)
- EC2 instances
- user_data bootstrap script (`user_data_wordpress.sh.tftpl`)

Responsibilities:
- Install Docker & Docker Compose
- Start WordPress containers
- Connect WordPress to RDS and EFS

---

### 📦 efs-wp-content
Creates an **Amazon EFS** file system used for:
- Persistent WordPress `wp-content`
- Shared storage across EC2 instances in the ASG

---

### 🗄️ rds-mysql
Provisions an **Amazon RDS MySQL** database used as:
- WordPress primary database
- Centralized, managed persistence layer

---

## 🚀 Usage (Dev Environment)

```bash
cd envs/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

> ⚠️ Note: The current setup uses a **local Terraform state** and is intended for development only.

---

## 🧹 Destroy Infrastructure

```bash
terraform destroy
```

---

## 📌 Notes

- This repository is structured for **future expansion** (e.g. `staging`, `prod`)
- State management, remote backends, and CI/CD are **not yet implemented**
- Modules are designed to stay reusable across environments

---

## 📄 License

Internal / educational use.

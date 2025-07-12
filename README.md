# Elastic Stack (ELK) on AWS with Terraform

[![Elastic Stack](https://img.shields.io/badge/Elastic%20Stack-8.x-00bfb3?style=flat&logo=elastic-stack)](https://www.elastic.co/blog/category/releases) [![Terraform](https://img.shields.io/badge/Terraform-v1.x-623CE4?logo=terraform&logoColor=white)](https://terraform.io) [![AWS](https://img.shields.io/badge/AWS-EC2%20%7C%20ALB-F7991C?logo=amazon-aws&logoColor=white)](https://aws.amazon.com) [![Build](https://github.com/lafayette/elk-deploy/actions/workflows/terraform.yaml/badge.svg)](https://github.com/lafayette/elk-deploy/actions) ![License](https://img.shields.io/github/license/lafayette/elk-deploy) [![Stars](https://img.shields.io/github/stars/lafayette/elk-deploy?style=social)](https://github.com/lafayette/elk-deploy/stargazers)

Run the latest version of the **Elastic Stack** on **AWS** with **Terraform**.
It leverages the excellent [docker-elk](https://github.com/deviantony/docker-elk) project under the hood to run Elasticsearch, Logstash, Kibana, and Fleet in Docker.
Provision a single‑node Elasticsearch, Logstash, Kibana, and Fleet/APM stack on an EC2 instance, fronted by an Application Load Balancer (ALB) with HTTPS. Ship traces and logs from OpenTelemetry‑instrumented workloads to the stack in minutes.

> _this readme was vibe coded, too lazy to make readmes_

---

## tl;dr

```bash
# clone
 git clone https://github.com/lafayette/elk-deploy.git && cd YOUR_REPO

# deploy
 terraform init            # downloads providers & configures S3 backend
 terraform apply -auto-approve  # 🚀 create AWS resources
```

Grab the passwords from the Discord webhook (if configured) or `/home/ubuntu/docker-elk/.env` over SSH, then visit
`https://monitoring.<domain>` (Kibana) or send OTLP traces to `https://apm.<domain>`.

---

## Philosophy

This repo aims to be the **simplest possible entry‑point** for experimenting with the Elastic Stack on AWS using Infrastructure‑as‑Code.
No external dependencies, no opinionated modules – just a lean Terraform configuration you can copy, tweak, and make **your own**.

---

## Contents

1. [Requirements](#requirements)
   • [Host setup](#host-setup)
   • [AWS prerequisites](#aws-prerequisites)
2. [Usage](#usage)
   • [Bringing up the stack](#bringing-up-the-stack)
   • [Initial setup](#initial-setup)
   • [Cleanup](#cleanup)
3. [Configuration](#configuration)
   • [How to configure Terraform variables](#how-to-configure-terraform-variables)
   • [How to adjust EC2 size / EBS](#how-to-adjust-ec2-size--ebs)
4. [Extensibility](#extensibility)
   • [Adding Beats / Agents](#adding-beats--agents)
5. [Going further](#going-further)

---

## Requirements

### Host setup

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) **v1.x** or newer
- (Optional) [AWS CLI](https://docs.aws.amazon.com/cli/) **v2** for convenience
- Git + your favourite shell

> \[!NOTE]
> You’ll need an AWS account with permissions to create EC2, ALB, EBS, IAM, Route53, and ACM resources.

### AWS prerequisites

| Item                    | Description                                                            |
| ----------------------- | ---------------------------------------------------------------------- |
| **VPC & Subnets**       | Existing VPC ID and at least one public subnet ID                      |
| **Route53 Hosted Zone** | The domain you’ll use for Kibana & APM (e.g. `example.com`)            |
| **ACM Certificate**     | Issued in the same region for `monitoring.<domain>` and `apm.<domain>` |
| **SSH Key Pair**        | To access the EC2 instance if needed                                   |
| **Discord Webhook**     | _(Optional)_ receive passwords in chat                                 |

---

## Usage

### Bringing up the stack

```bash
# 1️⃣ clone repository
 git clone https://github.com/lafayette/elk-deploy.git
 cd YOUR_REPO

# 2️⃣ fill in variables
echo "vpc_id = \"vpc-abc123\"" >> terraform.tfvars
# ...add the rest (see example below)

# 3️⃣ deploy
 terraform init
 terraform apply
```

Terraform creates the infrastructure in \~2 min. The EC2 user‑data installs Docker and boots the containers (another 3‑5 min).
When ready, log into Kibana with **elastic / \<generated‑password>**.

> \[!WARNING]
> AWS costs apply! Destroy the stack when you’re done: `terraform destroy`.

### Initial setup

- **Passwords** – Delivered via Discord webhook or available in `/home/ubuntu/docker-elk/.env` on the EC2 instance.
- **APM / OpenTelemetry** – Point your OTLP exporter/agent to `https://apm.<domain>`.
- **Fleet Server** – Accessible under Kibana ▸ **Fleet**; enroll agents with the provided token.

### Cleanup

```bash
terraform destroy
```

This removes ALB, EC2, EBS, Route53 records, security groups, IAM roles, etc.

---

## Configuration

### How to configure Terraform variables

Variables live in [`variables.tf`](./variables.tf). Provide overrides via `terraform.tfvars` or `-var` flags.

```hcl
# terraform.tfvars (minimal)
vpc_id               = "vpc-0abc123"
public_subnets       = ["subnet-1", "subnet-2"]
alb_sg_id            = "sg-012345"
acm_certificate_arn  = "arn:aws:acm:us-east-1:123:certificate/xyz"
domain_name          = "example.com"
ssh_key_name         = "elk-key"
```

### How to adjust EC2 size / EBS

Edit `locals.tf` and tweak `instance_type` (`t4g.large` by default) or `ebs_volume_size` (GiB).

---

## Extensibility

- **Elastic Agents / Beats** – With Fleet enabled, add agents on other hosts for system metrics, nginx logs, etc.
- **Multiple nodes** – Convert the single EC2 into an Auto Scaling Group or deploy additional data nodes.
- **Custom TLS** – Use ACM Private CA or self‑signed certs if you prefer not to expose domains publicly.

---

## Going further

- [Elastic Observability docs](https://www.elastic.co/observability) – explore APM, logs, metrics in Kibana.
- [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/) – forward traces to Elastic.
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) – add S3 snapshots, CloudWatch alarms, etc.

---

> Made with ❤️ & Terraform

<!-- markdownlint-configure-file
{
  "MD013": false,
  "MD033": {
    "allowed_elements": ["picture", "source", "img"]
  }
}

# Secure AWS Infrastructure Baseline

## Purpose

The purpose of this project is to build a secure AWS infrastructure baseline using Terraform and AWS security best practices.

This baseline is designed to demonstrate how core cloud security controls can be implemented in a practical, repeatable, and audit-ready way. The project focuses on private-by-default architecture, network segmentation, least-privilege access, secure administration, monitoring, encryption, and RMF/NIST-aligned control implementation.

This project is intended to show how security requirements can be translated into actual AWS infrastructure, not just documented as policy.

## Architecture Overview

This architecture uses a multi-AZ VPC design with separate public, private application, and private database tiers.

The public subnets contain internet-facing components such as the Application Load Balancer and NAT Gateways. The private application subnets host EC2-based application workloads that do not allow direct inbound SSH access. Administrative access is designed around IAM roles, instance profiles, Systems Manager Session Manager, and VPC endpoints.

The private database subnets are isolated from direct internet access and do not include a default route to the internet. Database access is controlled through security group trust relationships, allowing traffic only from the private application tier.

The baseline also includes monitoring, logging, and protection controls using CloudTrail, CloudWatch, AWS Config, KMS, S3 encryption, EBS encryption, and CloudTrail log file validation.

The high-level traffic flow is:

Internet traffic reaches the Application Load Balancer in the public subnets.
The ALB forwards approved application traffic to EC2 instances in the private application subnets.
Private application instances communicate with the database tier through controlled security group rules.
Private application subnets use NAT Gateways for controlled outbound internet access.
Administrative access uses SSM instead of direct inbound SSH.
Logging, monitoring, and encryption controls provide auditability and protection across the baseline.

## Security Objectives

This project demonstrates a secure AWS infrastructure baseline focused on translating RMF/NIST security intent into deployable AWS controls.

- Enforce private-by-default infrastructure design
- Segment public, private application, and private data tiers
- Use IAM and SSM for administrative access instead of inbound SSH
- Control traffic flow using route tables, security groups, and NACLs
- Capture audit evidence using CloudTrail, CloudWatch, AWS Config, and S3 log storage
- Protect logs and data using KMS, S3 encryption, EBS encryption, and CloudTrail log validation

## Architecture Diagram

[![AWS Secure Baseline VPC Architecture](docs/aws-secure-baseline-vpc.png)](docs/aws-secure-baseline-vpc.png)


## Services Used

This project uses the following AWS services and security components:

| Service / Component                 | Purpose                                                                                        |
| ----------------------------------- | ---------------------------------------------------------------------------------------------- |
| Amazon VPC                          | Provides the isolated network boundary for the baseline architecture.                          |
| Public Subnets                      | Host internet-facing components such as the ALB and NAT Gateways.                              |
| Private Application Subnets         | Host private EC2 application workloads with no direct inbound SSH access.                      |
| Private Database Subnets            | Host database resources with no direct internet route.                                         |
| Internet Gateway                    | Allows controlled internet access for public subnet resources.                                 |
| NAT Gateway                         | Allows private application workloads to initiate outbound internet connections.                |
| Route Tables                        | Control traffic flow between public, private application, and private database tiers.          |
| Security Groups                     | Enforce stateful workload-level traffic controls between ALB, application, and database tiers. |
| Network ACLs                        | Provide subnet-level network filtering as an additional layer of control.                      |
| IAM Roles / Instance Profiles       | Provide least-privilege permissions for EC2 and Systems Manager access.                        |
| AWS Systems Manager Session Manager | Enables private administrative access without inbound SSH.                                     |
| VPC Endpoints                       | Keep AWS service traffic private for Systems Manager and related services.                     |
| Amazon EC2                          | Represents private application workloads in the baseline.                                      |
| Amazon RDS                          | Represents the private database tier.                                                          |
| AWS CloudTrail                      | Captures account activity and API-level audit logs.                                            |
| Amazon CloudWatch                   | Provides operational visibility, logging, and monitoring support.                              |
| AWS Config                          | Records resource configuration and supports compliance validation.                             |
| Amazon S3                           | Stores logs and security evidence.                                                             |
| AWS KMS                             | Provides encryption key management for protected resources.                                    |
| S3 Encryption                       | Protects stored log and evidence data.                                                         |
| EBS Encryption                      | Protects EC2 volume data.                                                                      |
| CloudTrail Log File Validation      | Strengthens audit integrity by validating CloudTrail log files.                                |
| Terraform                           | Defines and deploys the infrastructure as repeatable infrastructure-as-code.                   |


## Terraform Structure## Terraform Structure

This project is organized by security system to make the infrastructure easier to understand, validate, and explain.

```text
secure-aws-infrastructure-baseline/
├── versions.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars.example
├── network.tf
├── security.tf
├── access.tf
├── monitoring.tf
├── protection.tf
├── outputs.tf
└── docs/
    ├── architecture/
    │   └── aws-secure-baseline-vpc.png
    └── evidence/
        ├── network-system/
        ├── security-system/
        ├── access-system/
        ├── monitoring-system/
        └── protection-system/
```

### File Purpose

| File / Folder              | Purpose                                                                                                          |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `versions.tf`              | Defines the required Terraform and provider versions.                                                            |
| `providers.tf`             | Configures the AWS provider and deployment region.                                                               |
| `variables.tf`             | Defines reusable variables such as region, CIDR ranges, and availability zones.                                  |
| `terraform.tfvars.example` | Provides a safe example variable file without exposing local or sensitive values.                                |
| `network.tf`               | Builds the VPC, subnets, Internet Gateway, NAT Gateways, route tables, and route table associations.             |
| `security.tf`              | Defines security groups and network ACLs for public, private application, and private database tiers.            |
| `access.tf`                | Implements IAM roles, instance profiles, Systems Manager access, EC2 private access patterns, and VPC endpoints. |
| `monitoring.tf`            | Deploys CloudTrail, CloudWatch, AWS Config, logging resources, and compliance-oriented monitoring controls.      |
| `protection.tf`            | Implements KMS, encryption controls, S3 encryption, EBS encryption, and CloudTrail log validation support.       |
| `outputs.tf`               | Displays selected resource outputs useful for validation and review.                                             |
| `docs/`                    | Stores architecture diagrams, traffic flow notes, evidence screenshots, and validation artifacts.                |

## Deployment Steps

> **Note:** This project is intended for demonstration, learning, and portfolio use. Review costs before deployment, especially for NAT Gateways, EC2, CloudTrail, AWS Config, and other billable AWS services.

### 1. Clone the repository

```bash
git clone https://github.com/sharp1/secure-aws-infrastructure-baseline.git
cd secure-aws-infrastructure-baseline
```

### 2. Configure AWS credentials

Ensure the AWS CLI is configured with credentials for the target account.

```bash
aws configure
```

Validate the active identity before deploying:

```bash
aws sts get-caller-identity
```

### 3. Create a local Terraform variable file

Copy the example variable file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update values such as:

```hcl
aws_region = "us-east-1"
vpc_cidr   = "10.0.0.0/16"
az_a       = "us-east-1a"
az_b       = "us-east-1b"
```

Do not commit `terraform.tfvars` if it contains environment-specific or sensitive values.

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Format and validate the configuration

```bash
terraform fmt
terraform validate
```

### 6. Review the Terraform plan

```bash
terraform plan
```

Review the planned resources before applying. Confirm the plan matches the intended architecture and security design.

### 7. Apply the infrastructure

```bash
terraform apply
```

Confirm the apply only after reviewing the resource changes.

### 8. Validate the deployment

After deployment, validate key controls:

```bash
aws ec2 describe-vpcs
aws ec2 describe-subnets
aws ec2 describe-route-tables
aws ec2 describe-security-groups
aws ec2 describe-network-acls
aws ssm describe-instance-information
aws cloudtrail describe-trails
aws configservice describe-configuration-recorders
```

### 9. Destroy resources when finished

To avoid unnecessary AWS costs:

```bash
terraform destroy
```

Confirm that billable resources such as NAT Gateways, EC2 instances, CloudTrail resources, AWS Config resources, and S3 buckets are removed or reviewed after testing.

## Evidence & Validation

Evidence is organized by system to show how each part of the baseline was built, reviewed, and validated.

```text
docs/evidence/
├── network-system/
├── security-system/
├── access-system/
├── monitoring-system/
└── protection-system/
```

### Evidence Categories

| Evidence Folder      | What It Validates                                                                                        |
| -------------------- | -------------------------------------------------------------------------------------------------------- |
| `network-system/`    | VPC, subnets, Internet Gateway, NAT Gateways, route tables, route table associations, and traffic flow.  |
| `security-system/`   | Security groups, NACLs, inbound/outbound rules, segmentation logic, and trust boundaries.                |
| `access-system/`     | IAM roles, instance profiles, SSM Session Manager access, VPC endpoints, and private EC2 administration. |
| `monitoring-system/` | CloudTrail, CloudWatch, AWS Config, S3 log storage, compliance rules, and audit visibility.              |
| `protection-system/` | KMS, encryption controls, S3 encryption, EBS encryption, and CloudTrail log file validation.             |

### Validation Approach

This project validates the baseline through:

* Terraform `fmt`, `validate`, `plan`, and `apply`
* AWS CLI checks against deployed resources
* Console screenshots for major security controls
* Architecture diagrams showing traffic flow and trust boundaries
* Evidence screenshots organized by system
* GitHub-based documentation for repeatability and review

### Example Validation Points

| Control Area          | Validation Example                                                                                                               |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Network Segmentation  | Confirm public, private application, and private database subnets are separated across AZs.                                      |
| Public Routing        | Confirm public route table sends `0.0.0.0/0` to the Internet Gateway.                                                            |
| Private App Routing   | Confirm private application route tables send outbound internet traffic through NAT Gateways.                                    |
| Private DB Isolation  | Confirm private database route table has no default internet route.                                                              |
| Security Group Trust  | Confirm ALB security group allows inbound HTTP/HTTPS, app security group trusts ALB, and DB security group trusts app tier only. |
| No Inbound SSH        | Confirm EC2 administration does not rely on inbound SSH from the internet.                                                       |
| SSM Access            | Confirm private EC2 instances appear as managed instances in Systems Manager.                                                    |
| Audit Logging         | Confirm CloudTrail is enabled and delivering logs to S3.                                                                         |
| Compliance Visibility | Confirm AWS Config recorder, delivery channel, and rules are active.                                                             |
| Encryption            | Confirm KMS, S3 encryption, EBS encryption, and log validation controls are enabled.                                             |

## Lessons Learned

This project reinforced several important cloud security engineering lessons.

### 1. Secure architecture starts with network boundaries

The VPC design establishes the foundation for the rest of the security model. Separating public, private application, and private database tiers makes it easier to reason about traffic flow, restrict exposure, and enforce least privilege.

### 2. Private-by-default requires deliberate routing

A subnet is not truly private just because it has the word “private” in its name. Route tables, NAT Gateways, Internet Gateways, and security controls determine actual exposure. The private database tier should not have a default route to the internet.

### 3. Security groups and NACLs serve different purposes

Security groups provide stateful workload-level control, while NACLs provide stateless subnet-level filtering. Using both requires careful attention to inbound, outbound, and ephemeral port behavior.

### 4. SSM reduces the need for direct administrative exposure

Systems Manager Session Manager allows private EC2 administration without opening inbound SSH to the internet. This supports a stronger administrative access pattern when combined with IAM roles, instance profiles, and VPC endpoints.

### 5. Auditability must be built into the baseline

CloudTrail, AWS Config, CloudWatch, and S3 log storage should not be afterthoughts. Logging and configuration visibility are part of the security architecture and support operational review, compliance evidence, and incident response.

### 6. Encryption strengthens both protection and evidence integrity

KMS, S3 encryption, EBS encryption, and CloudTrail log file validation help protect data and improve trust in audit records.

### 7. Terraform improves repeatability and review

Infrastructure-as-code makes the baseline easier to reproduce, inspect, version, and improve. Organizing Terraform files by system also makes the architecture easier to explain during technical reviews and interviews.

### 8. RMF/NIST requirements become stronger when translated into implementation

Security controls are more valuable when they are connected to actual architecture decisions. This project shows how RMF/NIST-aligned expectations can be translated into AWS infrastructure, Terraform resources, and validation evidence.


# Secure AWS Infrastructure Baseline

## Purpose
## Architecture Overview
## Security Objectives
## Services Used
## Terraform Structure
## Deployment Steps
## Validation Steps
## Controls Implemented
## Cost Notes
## Architecture Diagram
## Lessons Learned

## Security Objectives

- Enforce private-by-default infrastructure design
- Use IAM and SSM for administrative access instead of inbound SSH
- Segment public, application, and data tiers
- Capture audit evidence with CloudTrail and AWS Config
- Encrypt logs and data using KMS, S3 encryption, and EBS encryption
- Support RMF/NIST-aligned control implementation through repeatable Terraform

- ![Secure AWS Infrastructure Baseline Architecture](docs/aws-secure-baseline-vpc.png- )

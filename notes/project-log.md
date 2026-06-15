# Secure AWS Infrastructure Baseline - Project Log

## Project Goal

Build a secure, reproducible AWS infrastructure baseline using private-by-default design, controlled administration through SSM Session Manager, least privilege IAM, VPC endpoints, and infrastructure as code.

## Operating Rules

1. Number every major step.
2. Validate after each build action.
3. Capture evidence.
4. Record errors and fixes.
5. Destroy paid resources when no longer needed.

## Current Phase

Phase 0 - Project Setup

## Build Log

### Step 0.1 - Created baseline folder structure

Status: Complete

Folders created:

- notes
- evidence
- diagrams
- terraform
- scripts

Phase Complete:
Network System
Security System
Access System

Validated:
- VPC deployed
- Subnets deployed
- Route tables associated correctly
- NAT Gateway operational
- Security Groups configured
- NACLs configured
- Evidence captured

Lessons Learned:
- Terraform variable references vs string literals
- NACL subnet associations
- Stateless NACL behavior
- Security Group trust relationships
- Traffic flow between tiers

I implemented a private EC2 administration pattern using IAM, Session Manager, and VPC endpoints

Validated
-IAM Role
-Instance Profile
-Private EC2
-Security Groups
-NACLs
-SSM Endpoints
-Session Manager

Monitoring System started: CloudTrail enabled with S3 log archive.

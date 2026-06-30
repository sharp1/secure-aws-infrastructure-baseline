# Interview Walkthrough

## 60-Second Summary

This project demonstrates a secure AWS infrastructure baseline built with Terraform. It uses a multi-AZ VPC design with public, private application, and private database tiers; IAM/SSM-first administration; CloudTrail, AWS Config, CloudWatch, KMS, encryption, and evidence organized by system.

## Design Decisions

- Private application instances do not allow direct inbound SSH.
- Public subnets contain internet-facing components such as ALB and NAT Gateways.
- Database subnets have no default internet route.
- Security group trust flows from ALB to App to DB.
- Monitoring and encryption controls are built into the baseline instead of added later.

## How I Would Explain It

I started with the network boundary, then layered security groups, NACLs, IAM, SSM access, logging, monitoring, and encryption. The goal was to show how RMF/NIST security intent can become deployable AWS infrastructure using Terraform.

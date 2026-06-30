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


This diagram shows a multi-AZ secure AWS VPC baseline with public, private application, and private database tiers. Public subnets route through the Internet Gateway, private application subnets use NAT Gateways for controlled outbound access, and private database subnets have no default internet route. Security group trust flows from ALB → App → DB.

# RMF / NIST Control Mapping

| Security Objective | AWS Implementation | Evidence |
|---|---|---|
| Least privilege | IAM role + instance profile | Terraform IAM resources |
| Secure administration | SSM Session Manager, no inbound SSH | Security group rules, SSM endpoint config |
| Network segmentation | Public/private/data subnets, route tables, SGs, NACLs | Terraform network/security files |
| Audit logging | CloudTrail, S3 log bucket, AWS Config | CloudTrail and Config resources |
| Encryption | KMS, S3 encryption, EBS encryption | Terraform KMS/S3/EBS resources |

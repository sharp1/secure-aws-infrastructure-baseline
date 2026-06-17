########################
# Protection System
########################
resource "aws_kms_key" "baseline" {
  description             = "KMS key for Secure AWS Infrastructure Baseline"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "secure-baseline_kms-key"
  }

}

resource "aws_kms_alias" "baseline" {
  name          = "alias/secure-baseline"
  target_key_id = aws_kms_key.baseline.key_id

}

##Encryption CloudTrail##
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.baseline.arn
      sse_algorithm     = "aws:kms"
    }
  }

}
##Encryption for AWS Config##
resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.baseline.arn
      sse_algorithm     = "aws:kms"
    }
  }

}
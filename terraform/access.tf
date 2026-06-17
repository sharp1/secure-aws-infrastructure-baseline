######Access System######

resource "aws_iam_role" "ssm_role" {
  name = "ec2-ssm-execution-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}
# Attach the standard AWS-managed policy for SSM
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create the instance Profile needed by EC2
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name

}


data "aws_ami" "amazon_linux_2_ssm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]

  }
}
# Create EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.amazon_linux_2_ssm.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_app_a.id
  vpc_security_group_ids      = [aws_security_group.instance_security_group.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = false

  root_block_device {
    encrypted   = true
    kms_key_id  = aws_kms_alias.baseline.arn
    volume_type = "gp3"

    tags = {
      Name = "secure-baseline-private-ec2-root-volume"
    }
  }

  tags = {
    Name = "secure-baseline-private-ec2"
  }

}





# Create a security group for the EC2 instance

resource "aws_security_group" "instance_security_group" {
  name        = "instance-sg"
  vpc_id      = aws_vpc.main.id
  description = "security group for the EC2 instance"

  # Allow outbound HTTPS traffic
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound traffic"

  }


  tags = {
    Name = "EC2 Instance security group"
  }

}

# Seucurity group for VPC Endpoints
resource "aws_security_group" "vpc_endpoint_security_group" {
  name        = "vpc-endpoint-sg"
  description = "Security group for SSM VPC endpoints"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "secure-baseline-vpc-endpoint-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "enpoint_allow_https_from_instance" {
  security_group_id            = aws_security_group.vpc_endpoint_security_group.id
  referenced_security_group_id = aws_security_group.instance_security_group.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "Allow HTTPS from EC2 instance security group"
}

resource "aws_vpc_security_group_egress_rule" "endpoint_allow_all_egress" {
  security_group_id = aws_security_group.vpc_endpoint_security_group.id
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
  description       = "Allow endpoint return traffic within VPC"

}

# Create VPC Endpoints

locals {
  ssm_endpoints = {
    ssm         = "ssm"
    ssmmessages = "ssmmessages"
    ec2messages = "ec2messages"
  }
}
resource "aws_vpc_endpoint" "ssm_endpoints" {
  for_each = local.ssm_endpoints

  vpc_id              = aws_vpc.main.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_app_a.id,
    aws_subnet.private_app_b.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoint_security_group.id
  ]

  tags = {
    Name = "secure-baseline-${each.key}-endpoint"
  }
}

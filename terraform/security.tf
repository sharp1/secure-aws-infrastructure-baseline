
####################################Security System#################################
#Security Groups

resource "aws_security_group" "alb_sg" {
  name        = "secure-baseline-alb-sg"
  description = "Security group for internet-facing application load balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "secure-baseline-alb-sg"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "secure-baseline-app-sg"
  description = "Security group for private application workloads"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "secure-baseline-app-sg"
  }

}

resource "aws_security_group" "db_sg" {
  name        = "secure-baseline-db-sg"
  description = "Security group for private database workloads"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "secure-baseline-db-sg"
  }

}

#egress rules

resource "aws_vpc_security_group_ingress_rule" "alb_allow_http" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow public HTTP traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_allow_https" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow public HTTPS traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

#App inbound from ALB only

resource "aws_vpc_security_group_ingress_rule" "app_allow_from_alb" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow application traffic from ALB security group"

  referenced_security_group_id = aws_security_group.alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080

}

#DB inbound from App only

resource "aws_vpc_security_group_ingress_rule" "db_allow_from_app" {
  security_group_id = aws_security_group.db_sg.id
  description       = "Allow database traffic from app security group"

  referenced_security_group_id = aws_security_group.app_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432

}

#egress rules

resource "aws_vpc_security_group_egress_rule" "alb_allow_all_egress" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow all outbound traffic from ALB security group"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

}

resource "aws_vpc_security_group_egress_rule" "app_allow_all_egress" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow all outbound traffic from app security group"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

}

resource "aws_vpc_security_group_egress_rule" "db_allow_all_egress" {
  security_group_id = aws_security_group.db_sg.id
  description       = "Allow all outbound traffic from database security group"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

}

/*ALB accepts 80/443 from internet.
App accepts 8080 only from ALB SG.
DB accepts 5432 only from App SG.
No SSH from internet.
No direct internet to app.
No direct internet to DB.*/

#########################NacLs#######################

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-nacl"
  }

}

#Inbound Rule: Allow HTTP
resource "aws_network_acl_rule" "public_inbound_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80

}

#Inbound Rule: Allow HTTPS
resource "aws_network_acl_rule" "public_inbound_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443

}

# Inbound Rule: Allow Return Traffic (Ephemeral Ports)
resource "aws_network_acl_rule" "public_inbound_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 130
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535

}

# Outbound Rule: Allow all Traffic
resource "aws_network_acl_rule" "public_outbound_all" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0

}

# Associate the Nacl with a Subnet
resource "aws_network_acl_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  network_acl_id = aws_network_acl.public.id
}

resource "aws_network_acl_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  network_acl_id = aws_network_acl.public.id
}

# Private App Nacl
resource "aws_network_acl" "private_app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-app-nacl"
  }

}

#Inbound Rule: Allow ALB App port
resource "aws_network_acl_rule" "inbound_private_app" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 8080
  to_port        = 8080

}

#Inbound Rule: Allow ALB App port
resource "aws_network_acl_rule" "inbound_private_app_ephemeral" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535

}

#Outbound Rule allow HTTP
resource "aws_network_acl_rule" "private_app_outbound_http" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}
#Outbound Rule allow HTTPS
resource "aws_network_acl_rule" "private_app_outbound_https" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

#Private DB
resource "aws_network_acl_rule" "private_app_outbound_db" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 5432
  to_port        = 5432


}

resource "aws_network_acl_rule" "private_app_outbound_ephemeral" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 130
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535

}

resource "aws_network_acl_association" "private_app_a" {
  subnet_id      = aws_subnet.private_app_a.id
  network_acl_id = aws_network_acl.private_app.id

}

resource "aws_network_acl_association" "private_app_b" {
  subnet_id      = aws_subnet.private_app_b.id
  network_acl_id = aws_network_acl.private_app.id

}

resource "aws_network_acl_rule" "private_app_inbound_https_from_vpc" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 105
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 443
  to_port        = 443
}

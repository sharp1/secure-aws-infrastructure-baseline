###################Network System#######################

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "secure-baseline-vpc"
  }

}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.az_a
  map_public_ip_on_launch = true

  tags = {
    Name = "secure-baseline-subnet-public_a"
  }

}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_b_cidr
  availability_zone       = var.az_b
  map_public_ip_on_launch = true

  tags = {
    Name = "secure-baseline-subnet-public_b"
  }

}

resource "aws_subnet" "private_app_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_a_cidr
  availability_zone = var.az_a

  tags = {
    Name = "secure-baseline-subnet-private_app_a"
  }

}

resource "aws_subnet" "private_app_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_b_cidr
  availability_zone = var.az_b

  tags = {
    Name = "secure-baseline-subnet-private_app_b"
  }



}

resource "aws_subnet" "private_data_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_data_subnet_a_cidr
  availability_zone = var.az_a

  tags = {
    Name = "secure-baseline-subnet-private_data_a"
  }

}

resource "aws_subnet" "private_data_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_data_subnet_b_cidr
  availability_zone = var.az_b

  tags = {
    Name = "secure-baseline-subnet-private_data_b"
  }

}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "secure-baseline-igw"
  }

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "secure-baseline-public-rt"
  }

}

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_a.id
  }

  tags = {
    Name = "secure-baseline-private-app-rt"

  }

}

resource "aws_route_table" "private_data" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "secure-baseline-private-data-rt"

  }

}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "private_app_a" {
  subnet_id      = aws_subnet.private_app_a.id
  route_table_id = aws_route_table.private_app.id

}

resource "aws_route_table_association" "private_app_b" {
  subnet_id      = aws_subnet.private_app_b.id
  route_table_id = aws_route_table.private_app.id

}

resource "aws_route_table_association" "private_data_a" {
  subnet_id      = aws_subnet.private_data_a.id
  route_table_id = aws_route_table.private_data.id

}

resource "aws_route_table_association" "private_data_b" {
  subnet_id      = aws_subnet.private_data_b.id
  route_table_id = aws_route_table.private_data.id

}

resource "aws_eip" "nat_eip_a" {
  domain = "vpc"

  tags = {
    Name = "secure-baseline-nat-eip-a"
  }
}

resource "aws_nat_gateway" "nat_gateway_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "secure-baseline-nat-gw-a"
  }

  depends_on = [aws_internet_gateway.main]
}

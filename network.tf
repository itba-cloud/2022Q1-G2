resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  for_each = toset(var.aws_availability_zones)
  availability_zone = each.value

  cidr_block = cidrsubnet(var.vpc_cidr, 8, index(var.aws_availability_zones, each.value) * 10)

  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_${each.value}"
  }
}

resource "aws_subnet" "lambda" {
  vpc_id            = aws_vpc.main.id

  for_each = toset(var.aws_availability_zones)
  availability_zone = each.value

  cidr_block = cidrsubnet(var.vpc_cidr, 8, index(var.aws_availability_zones, each.value) * 10 + 1)
  map_public_ip_on_launch = false

  tags = {
    Name = "lambda_private_subnet-${each.value}"
  }
}

resource "aws_subnet" "aurora" {
  vpc_id            = aws_vpc.main.id

  for_each = toset(var.aws_availability_zones)
  availability_zone = each.value

  cidr_block = cidrsubnet(var.vpc_cidr, 8, index(var.aws_availability_zones, each.value) * 10 + 2)
  map_public_ip_on_launch = false

  tags = {
    Name = "aurora_private_subnet-${each.value}"
  }
}

# ---------------------------------------------------------------------------
# Gateways
# ---------------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main_internet_gateway"
  }
}

resource "aws_eip" "nat" {
  for_each = toset(var.aws_availability_zones)
}

resource "aws_nat_gateway" "ngw" {
  for_each = toset(var.aws_availability_zones)

  subnet_id     = aws_subnet.public[each.value].id
  allocation_id = aws_eip.nat[each.value].id
  depends_on = [aws_internet_gateway.igw]
}

# ---------------------------------------------------------------------------
# Routing
# ---------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  for_each = toset(var.aws_availability_zones)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw[each.value].id
  }

  tags = {
    Name = "private-route-table-${each.value}"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_lambda" {
  for_each = toset(var.aws_availability_zones)

  subnet_id      = aws_subnet.lambda[each.value].id
  route_table_id = aws_route_table.private[each.value].id
}

resource "aws_route_table_association" "private_aurora" {
  for_each = toset(var.aws_availability_zones)

  subnet_id      = aws_subnet.aurora[each.value].id
  route_table_id = aws_route_table.private[each.value].id
}

# ---------------------------------------------------------------------------
# Security Groups
# ---------------------------------------------------------------------------
resource "aws_security_group" "http" {
  name        = "http"
  description = "HTTP traffic"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "https" {
  name        = "https"
  description = "HTTPS traffic"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "egress_all" {
  name        = "egress-all"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
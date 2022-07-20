resource "aws_vpc" "main" {
  provider = aws

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------

resource "aws_subnet" "public" {
  provider = aws

  vpc_id = aws_vpc.main.id

  for_each          = toset(local.availability_zone_names)
  availability_zone = each.value

  cidr_block = cidrsubnet(var.vpc_cidr, 8, index(local.availability_zone_names, each.value) * 10)

  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_${each.value}"
  }
}

resource "aws_subnet" "private_app" {
  provider = aws

  vpc_id = aws_vpc.main.id

  for_each          = toset(local.availability_zone_names)
  availability_zone = each.value

  cidr_block              = cidrsubnet(var.vpc_cidr, 8, index(local.availability_zone_names, each.value) * 10 + 1)
  map_public_ip_on_launch = false

  tags = {
    Name = "app_private_subnet-${each.value}"
  }
}

resource "aws_subnet" "private_db" {
  provider = aws

  vpc_id = aws_vpc.main.id

  for_each          = toset(local.availability_zone_names)
  availability_zone = each.value

  cidr_block              = cidrsubnet(var.vpc_cidr, 8, index(local.availability_zone_names, each.value) * 10 + 2)
  map_public_ip_on_launch = false

  tags = {
    Name = "db_private_subnet-${each.value}"
  }
}

# ---------------------------------------------------------------------------
# Gateways
# ---------------------------------------------------------------------------

resource "aws_internet_gateway" "this" {
  provider = aws

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main_internet_gateway"
  }
}

resource "aws_eip" "nat" {
  provider = aws
  for_each = toset(local.availability_zone_names)
}

resource "aws_nat_gateway" "this" {
  provider = aws
  for_each = toset(local.availability_zone_names)

  subnet_id     = aws_subnet.public[each.value].id
  allocation_id = aws_eip.nat[each.value].id
  depends_on    = [aws_internet_gateway.this]
}

# ---------------------------------------------------------------------------
# Routing
# ---------------------------------------------------------------------------

resource "aws_route_table" "public" {
  provider = aws
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table" "private" {
  provider = aws
  vpc_id = aws_vpc.main.id

  for_each = toset(local.availability_zone_names)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this[each.value].id
  }

  tags = {
    Name = "private-route-table-${each.value}"
  }
}

resource "aws_route_table_association" "public" {
  provider = aws
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  provider = aws
  for_each = toset(local.availability_zone_names)

  subnet_id      = aws_subnet.private_app[each.value].id
  route_table_id = aws_route_table.private[each.value].id
}

resource "aws_route_table_association" "private_aurora" {
  provider = aws
  for_each = toset(local.availability_zone_names)

  subnet_id      = aws_subnet.private_db[each.value].id
  route_table_id = aws_route_table.private[each.value].id
}

# ---------------------------------------------------------------------------
# Security Groups
# ---------------------------------------------------------------------------
resource "aws_security_group" "http" {
  provider = aws

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
  provider = aws

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
  provider = aws

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
data aws_availability_zones available {
  state = "available"
}

resource aws_vpc base_vpc {
  tags = {
    Name = "Plain base network"
  }

  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "10.160.0.0/16"
}

resource aws_default_security_group default {
  vpc_id = aws_vpc.base_vpc.id

  # ingress from inside of the security group itself
  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  # egress to world
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output aws_default_security_group_default {
  value = {
    name = aws_default_security_group.default.name,
    id   = aws_default_security_group.default.id,
    arn  = aws_default_security_group.default.arn,
  }
}

# ########################################### #
#  Public                                     #
# ########################################### #
resource aws_subnet public_subnet {
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  cidr_block = cidrsubnet(aws_vpc.base_vpc.cidr_block, 4, 0)
  vpc_id     = aws_vpc.base_vpc.id
}

resource aws_internet_gateway public {
  vpc_id = aws_vpc.base_vpc.id
}

resource aws_route_table public {
  vpc_id = aws_vpc.base_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }
}

resource aws_route_table_association public {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_subnet.id
}

output aws_network_public_subnet {
  value = {
    id = aws_subnet.public_subnet.id
  }
}


# ########################################### #
#  Private                                    #
# ########################################### #
resource aws_eip public {
  vpc = true
}

resource aws_nat_gateway private {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.public.id

  depends_on = [aws_internet_gateway.public]
}

resource aws_subnet private_subnets {
  count = length(data.aws_availability_zones.available.names)

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  cidr_block = cidrsubnet(aws_vpc.base_vpc.cidr_block, 4, 1 + count.index)
  vpc_id     = aws_vpc.base_vpc.id
}

resource aws_route_table private {
  vpc_id = aws_vpc.base_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private.id
  }
}

resource aws_route_table_association private {
  count          = length(aws_subnet.private_subnets.*.id)
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

output aws_network_private_subnets {
  value = [
  for subnet in aws_subnet.private_subnets : {
    id = subnet.id
  }
  ]
}

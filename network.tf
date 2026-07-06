
# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.0.0/18"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.64.0/18"
  availability_zone = "us-east-2b"
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.128.0/18"
  availability_zone = "us-east-2a"

  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.192.0/18"
  availability_zone = "us-east-2b"

  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id
}

# Associate Public Subnets
resource "aws_route_table_association" "subnet1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.route_table.id
}

# Associate Private Subnets
resource "aws_route_table_association" "private1_assoc" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2_assoc" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

# Configure NAT gateways
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "main-nat"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "private"
  }
}

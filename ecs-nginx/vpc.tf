resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

# create Internet Gateway to provide internet access to public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# create a new public route table for using Internet Gateway
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public route"
  }

  depends_on = [
    aws_internet_gateway.igw
  ]
}

# associate public subnets to Internet Gateway
resource "aws_route_table_association" "public_subnet" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public_route.id

  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_eip" "eip" {
  depends_on = [
    aws_route_table_association.public_subnet
  ]
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.eip.id

  subnet_id = aws_subnet.public[0].id

  depends_on = [aws_eip.eip]
}

# create a new private route table for using Nat Gateway
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "private route"
  }

  depends_on = [
    aws_nat_gateway.ngw
  ]
}

# associate private subnets to Nat Gateway
resource "aws_route_table_association" "private_subnet" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private_route.id

  depends_on = [
    aws_nat_gateway.ngw
  ]
}
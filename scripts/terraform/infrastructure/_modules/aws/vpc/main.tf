
# This data source fetches all available AZs in the current AWS region
data "aws_availability_zones" "available" {}

# Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Create Public Subnets
resource "aws_subnet" "public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, var.public_subnet_count + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

# Public Route to the Internet
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway (Optional)
resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1 : 0
  domain       = "vpc"
  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.environment}-nat"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  count = var.private_subnet_count
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-private-rt-${count.index + 1}"
  }
}

# Route for Private Subnets to Use NAT Gateway
resource "aws_route" "nat_gateway" {
  count                  = var.create_nat_gateway ? var.private_subnet_count : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

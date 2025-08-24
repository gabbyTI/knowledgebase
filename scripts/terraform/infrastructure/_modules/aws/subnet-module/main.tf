data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "subnet" {
  count                   = var.subnet_count
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.base_cidr, var.subnet_cidr_bits, count.index + var.cidr_offset)
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-subnet-${count.index}"
  })
}

resource "aws_route_table_association" "subnet_association" {
  count          = var.create_route_table_association ? var.subnet_count : 0
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = var.route_table_id
}
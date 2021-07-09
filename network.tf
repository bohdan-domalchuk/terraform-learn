resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = local.tags
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-central-1a"
  count                   = 1
  map_public_ip_on_launch = true
  tags                    = local.tags
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1b"
  count                   = 1
  tags                    = local.tags
}

resource "aws_nat_gateway" "main" {
  count         = 1
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.gateway]
  tags          = local.tags
}

resource "aws_eip" "nat" {
  count = 1
  vpc   = true
  tags  = local.tags
}

resource "aws_route_table" "private" {
  count  = 1
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags
}

resource "aws_route" "private" {
  count                  = 1
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = 1
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

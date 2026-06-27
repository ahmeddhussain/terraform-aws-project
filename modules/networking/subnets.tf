resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-1-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-2-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "private-subnet-1-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name        = "private-subnet-2-${var.environment}"
    Environment = var.environment
  }
}
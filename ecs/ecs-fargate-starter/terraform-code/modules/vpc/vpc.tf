resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "ECS-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "ECS-igw"
  }
}

# resource "aws_subnet" "main_public" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = var.public_main_subnet_cidr
#   availability_zone       = "us-east-1e"
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "main-public-subnet1"
#   }
# }


#---------------------------------------
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public1_subnet_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public2_subnet_cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet2"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
  }
}


# TYM LOAD BALANCER SUBNETS BEDA PUBLIC USTAW DO TESTOW >>>>>>>>>>>>> ODWROC KOLEJNOSC 3 czyli 1 apply robisz a 2 pozostale komentujesz
# resource "aws_route_table_association" "public_assoc_ec2" {
#   subnet_id      = aws_subnet.main_public.id
#   route_table_id = aws_route_table.public.id
# }
# DAJESZ NETA DLA PUBLIC1
resource "aws_route_table_association" "public_assoc_ec2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
# DAJESZ NETA DLA PUBLIC1
resource "aws_route_table_association" "public_assoc1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}
#####################################################
#####################################################
#----------------------------------------------------
resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private1_subnet_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "private-subnet1"
  }
}
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private2_subnet_cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet2"
  }
}

resource "aws_eip" "nat" {
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "ecs-nat-gateway"
  }
}



resource "aws_route_table_association" "private_1_assoc" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "private_2_assoc" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private1.id
}



resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "private-rt"
  }
}


# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id
#   tags = {
#     Name = "private-rt"
#   }
# }

# resource "aws_route_table_association" "private_assoc" {
#   subnet_id      = aws_subnet.private_1.id
#   route_table_id = aws_route_table.private1.id
# }

# resource "aws_route_table_association" "private_assoc" {
#   subnet_id      = aws_subnet.private_2.id
#   route_table_id = aws_route_table.private.id
# }



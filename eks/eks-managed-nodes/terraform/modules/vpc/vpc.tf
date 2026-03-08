locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment_name
    Cluster     = var.cluster_name
  }
}
############################################################################################
######------------------------------------- VPC -----------------------------------#######
#1 VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block                       = var.vpc_cidr
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false
  tags = merge(local.common_tags, {
    Name = var.vpc_name
  })
}

#1 INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = merge(local.common_tags, {
    Name = "${var.vpc_name}-internet-gateway"
  })
}
############################################################################################
#######---------------------------- PUBLIC RESOURCES --------------------------------#######
#1 PUBLIC SUBNETS CREATION
# resource "aws_subnet" "public_subnet" {
#   vpc_id                  = aws_vpc.eks_vpc.id
#   cidr_block              = var.public_subnet_cidr
#   availability_zone       = var.region
#   map_public_ip_on_launch = true
#   tags = merge(local.common_tags, {
#     Name = "${var.vpc_name}-public-subnet"
#   })
# }

#2 ROUTE TABLE
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.eks_vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
#   tags = merge(local.common_tags, {
#     Name = "${var.vpc_name}-route-table-public"
#   })
# }

#3 PUBLIC SUBNETS ASSOCIATION WITH ROUTE TABLE
# resource "aws_route_table_association" "public_subnet_route_table_association" {
#   subnet_id      = aws_subnet.public_subnet.id
#   route_table_id = aws_route_table.public.id
# }

############################################################################################
######---------------------------- PRIVATE RESOURCES --------------------------------#######
#1 PRIVATE SUBNETS CREATION
resource "aws_subnet" "private_subnet_for_bastion_host" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.private_subnet_for_bastion_cidr
  availability_zone       = var.private_subnet_for_bastion_AZ
  map_public_ip_on_launch = false
  tags = merge(local.common_tags, {
    Name = "${var.vpc_name}-private_subnet_for_bastion"
  })
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.private1_subnet_cidr
  availability_zone       = var.private1_subnet_AZ
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {
    Name = "${var.vpc_name}-private_subnet_2"
  })
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.private2_subnet_cidr
  availability_zone = var.private2_subnet_AZ
  tags = merge(local.common_tags, {
    Name = "${var.vpc_name}-private_subnet_2"
  })
}

#2 ROUTE TABLE
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = merge(local.common_tags, {
    Name = "${var.vpc_name}-private-resources-route-table"
  })
}

#3 PRIVATE SUBNETS ASSOCIATION WITH ROUTE TABLE
resource "aws_route_table_association" "private_subnet1_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet2_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_for_bastion_table_association" {
  subnet_id      = aws_subnet.private_subnet_for_bastion_host.id
  route_table_id = aws_route_table.private_route_table.id
}

#4 NAT GATEWAY
# resource "aws_eip" "nat" {
# tags = merge(local.common_tags, {
#     Name = "${var.vpc_name}-nat-gateway-elastic-ip"
#   }
# }

# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.private_1.id
#   tags = merge(local.common_tags, {
#       Name = "${var.vpc_name}-nat-gateway"
#     }
# }

# resource "aws_route_table" "private1" {
#   vpc_id = aws_vpc.eks_vpc.id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }
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



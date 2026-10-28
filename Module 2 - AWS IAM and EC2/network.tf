# Using locals to remove repeatitive definition of tags or duplicating codes on each resource

locals {
  common_tags = {
    Name      = "CodoMax-resources-main"
    ManagedBy = "Terraform"
    Project   = "CodoMax-vpc-resources"

  }
}

# Creates a VPC

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = merge(local.common_tags, {
    Name = "CodoMax-vpc-resource"
  })

}

# Creates a Subnet and associate a CIDR block

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  tags = merge(local.common_tags, {
    Name = "CodoMax-resources-public"
  })
}


# From here adds IGW Resources

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "CodoMax-resources-main"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "CodoMax-resources-main"

  })

}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

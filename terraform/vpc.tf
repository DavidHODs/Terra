# creates a vpc having ipv4 dns support (otherwise connecting ansible with the ec2 instances will be impossible)
resource "aws_vpc" "terra-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true 
  enable_dns_hostnames = true 
  assign_generated_ipv6_cidr_block = true 
  instance_tenancy = "default"

  tags = {
    Name = "terra-vpc"
  }
}

# creates 3 public ssubnets
resource "aws_subnet" "terra-subnet" {
  vpc_id = aws_vpc.terra-vpc.id
  cidr_block = lookup(var.terra_zone, "cidr")[count.index]
  availability_zone = lookup(var.terra_zone, "zones")[count.index]
  
  map_public_ip_on_launch = true
  count = 3

  tags = {
    "Name" = "terra-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "terra-igw" {
  vpc_id = aws_vpc.terra-vpc.id
  tags = {
    Name = "terra-igw"
  }
}

resource "aws_route_table" "terra-rt" {
    vpc_id = aws_vpc.terra-vpc.id

    route {
        cidr_block = lookup(var.terra_var, "route_table")
        gateway_id = aws_internet_gateway.terra-igw.id
    }

    tags = {
        Name = "terra-rt"
    }
}

resource "aws_route_table_association" "terra-rt-association" {
    subnet_id = aws_subnet.terra-subnet[count.index].id
    route_table_id = aws_route_table.terra-rt.id

    count = 3
}
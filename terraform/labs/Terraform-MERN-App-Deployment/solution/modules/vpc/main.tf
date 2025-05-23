/*
  VPC Module - Creates the core networking infrastructure
  for the MERN stack application.
*/

# Create a Virtual Private Cloud (VPC) with DNS support enabled
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # Defines the IP address range
  enable_dns_support   = true  # Enables DNS resolution in the VPC
  enable_dns_hostnames = true  # Enables DNS hostnames in the VPC
  tags = {
    Name = "mern-vpc"
  }
}

# Create two public subnets in different availability zones for high availability
resource "aws_subnet" "public" {
  count = 2
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet("10.0.0.0/16", 4, count.index)  # Dynamically assign subnet CIDR blocks
  availability_zone = data.aws_availability_zones.available.names[count.index]  # Use different AZs for each subnet
  map_public_ip_on_launch = true  # Automatically assign public IPs to instances
  tags = {
    Name = "mern-public-${count.index}"
  }
}

# Create an Internet Gateway to allow traffic between the VPC and the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Create a route table with a route to the internet via the Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"  # All traffic to destinations not explicitly known
    gateway_id = aws_internet_gateway.igw.id  # Send through the Internet Gateway
  }
}

# Associate the route table with each public subnet
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Output the VPC ID so it can be referenced by other modules
output "vpc_id" {
  value = aws_vpc.main.id
}

# Output the public subnet IDs so they can be referenced by other modules
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

# Data source to get available AWS availability zones in the current region
data "aws_availability_zones" "available" {}
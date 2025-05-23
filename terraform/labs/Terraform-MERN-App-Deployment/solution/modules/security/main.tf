/*
  Security Module - Creates security groups and related security resources
  to control traffic to and from EC2 instances and the Application Load Balancer.
*/

# Security group for EC2 instances
# Controls what traffic is allowed to and from the backend servers
resource "aws_security_group" "instance_sg" {
  name        = "mern-instance-sg"
  description = "Allow SSH, HTTP, and app port"
  vpc_id      = var.vpc_id

  # Allow SSH access for administration and deployment
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting to specific IPs in production
  }

  # Allow access to the backend application port
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (updates, downloads, API calls)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mern-instance-sg"
  }
}

# Security group for the Application Load Balancer
# Controls what traffic is allowed to and from the ALB
resource "aws_security_group" "alb_sg" {
  name        = "mern-alb-sg"
  description = "Allow HTTP to ALB"
  vpc_id      = var.vpc_id

  # Allow HTTP traffic from anywhere to the ALB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (to EC2 instances, health checks)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mern-alb-sg"
  }
}

# Output the EC2 instance security group ID for use in other modules
output "security_group_id" {
  value = aws_security_group.instance_sg.id
}

# Output the ALB security group ID for use in other modules
output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}
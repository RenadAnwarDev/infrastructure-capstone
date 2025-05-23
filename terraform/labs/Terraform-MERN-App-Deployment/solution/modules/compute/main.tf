/*
  Compute Module - Creates compute resources including EC2 instances,
  Auto Scaling Group, and Application Load Balancer for the backend application.
*/

# Launch template that defines the EC2 instance configuration
# Used by the Auto Scaling Group to create instances
resource "aws_launch_template" "mern" {
  name_prefix   = "mern-launch-"  # Prefix for the launch template name
  image_id      = "ami-0fe8bec493a81c7da"  # Ubuntu 22.04 in eu-north-1
  # instance_type = "t3.micro"  # Free tier eligible instance type
  instance_type = "t3.medium"  
  key_name      = var.key_name  # SSH key pair for instance access

  # Network configuration for instances
  network_interfaces {
    associate_public_ip_address = true  # Assign public IPs
    security_groups             = [var.security_group_id]  # Security group for instances
  }

  # User data script for automated setup of instances
  user_data = base64encode(file("${path.module}/../../scripts/install_dependencies.sh"))

  # Tags to apply to the launched instances
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "mern-ec2"
    }
  }
}

# Application Load Balancer to distribute traffic to EC2 instances
resource "aws_lb" "mern_alb" {
  name               = "mern-alb"  # Name of the load balancer
  internal           = false  # Internet-facing (not internal)
  load_balancer_type = "application"  # Application (HTTP/HTTPS) load balancer
  security_groups    = [var.alb_security_group_id]  # Security group for the ALB
  subnets            = var.public_subnet_ids  # Subnets where the ALB will be deployed
}

# Target group for the ALB to route traffic to instances
resource "aws_lb_target_group" "mern_tg" {
  name     = "mern-tg"  # Name of the target group
  port     = 5000  # Port where the backend app listens
  protocol = "HTTP"  # Protocol for routing traffic
  vpc_id   = var.vpc_id  # VPC where the target group operates

  # Health check configuration to verify instance health
  health_check {
    path                = "/"  # Root path for health checks - most APIs respond to this
    protocol            = "HTTP"  # Protocol for health checks
    matcher             = "200,301,302"  # HTTP codes that indicate healthy status
    interval            = 30  # Time between health checks (seconds)
    timeout             = 5  # Time to wait for a response (seconds)
    healthy_threshold   = 2  # Consecutive successes before marking healthy
    unhealthy_threshold = 2  # Consecutive failures before marking unhealthy
  }
}

# Listener for the ALB to handle incoming HTTP traffic
resource "aws_lb_listener" "mern_listener" {
  load_balancer_arn = aws_lb.mern_alb.arn  # ARN of the load balancer
  port              = 80  # Port to listen on
  protocol          = "HTTP"  # Protocol to use

  # Default action to take for incoming requests
  default_action {
    type             = "forward"  # Forward the request
    target_group_arn = aws_lb_target_group.mern_tg.arn  # Forward to this target group
  }
}

# Auto Scaling Group to manage EC2 instances automatically
resource "aws_autoscaling_group" "mern_asg" {
  desired_capacity     = 1  # Desired number of instances
  max_size             = 2  # Maximum number of instances
  min_size             = 1  # Minimum number of instances
  vpc_zone_identifier  = var.public_subnet_ids  # Subnets to launch instances in

  # Launch template configuration
  launch_template {
    id      = aws_launch_template.mern.id
    version = "$Latest"  # Use the latest version of the launch template
  }

  # Target groups to associate with the ASG
  target_group_arns = [aws_lb_target_group.mern_tg.arn]

  # Tag instances created by the ASG
  tag {
    key                 = "Name"
    value               = "mern-asg-instance"
    propagate_at_launch = true  # Propagate this tag to launched instances
  }
}

# Output the ALB DNS name for accessing the application
output "alb_dns_name" {
  value = aws_lb.mern_alb.dns_name
}
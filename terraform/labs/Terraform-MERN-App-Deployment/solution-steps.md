# MERN Stack Blog App Deployment Solution Guide

This document provides a comprehensive guide for instructors to set up and deploy the MERN stack blog application using Terraform and manual configuration steps.

## Table of Contents

1. [Solution Overview](#solution-overview)
2. [Terraform Infrastructure Setup](#terraform-infrastructure-setup)
3. [Automated Instance Setup](#automated-instance-setup)
4. [Manual Backend Deployment](#manual-backend-deployment)
5. [Frontend Deployment](#frontend-deployment)
6. [Testing the Application](#testing-the-application)
7. [Troubleshooting Guide](#troubleshooting-guide)

## Solution Overview

The solution is divided into two main parts:

1. **Infrastructure Setup with Terraform**: Creates VPC, security groups, EC2 instances (via ASG and Launch Template), ALB, and S3 buckets
2. **Manual Application Deployment**: Setting up MongoDB Atlas, configuring and deploying the backend on EC2, and deploying the frontend to S3

## Terraform Infrastructure Setup

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed (v1.0.0 or later)
- SSH key pair created in the AWS region (eu-north-1)

### Step 1: Review and Update Terraform Files

1. Navigate to the solution directory:

   ```bash
   cd solution
   ```

2. Review the variables in `variables.tf` and update as needed:
   ```bash
   # Update the key_name variable with your SSH key pair name
   variable "key_name" {
     default = "your-key-pair-name"
   }
   ```

### Step 2: Initialize and Apply Terraform

1. Initialize Terraform:

   ```bash
   terraform init
   ```

2. Validate the configuration:

   ```bash
   terraform validate
   ```

3. Plan the deployment:

   ```bash
   terraform plan
   ```

4. Apply the configuration:

   ```bash
   terraform apply
   ```

5. Note the outputs after successful apply (you'll need these later):

   - ALB DNS name
   - Frontend bucket website endpoint
   - Media bucket domain name
   - S3 IAM user credentials (access key and secret key)

6. To retrieve the sensitive S3 IAM credentials:
   ```bash
   terraform output -raw s3_user_access_key
   terraform output -raw s3_user_secret_key
   ```

## Automated Instance Setup

The EC2 instances are automatically configured with the necessary dependencies through user_data in the launch template. The automation:

1. Updates system packages
2. Installs Node.js via NVM
3. Installs PM2 globally
4. Configures PM2 for startup on reboot
5. Creates necessary directories
6. Installs AWS CLI

This automation saves time and ensures consistent setup across all instances in the Auto Scaling Group. After an instance is launched, it takes approximately 5-10 minutes for all installations to complete before the instance is ready for application deployment.

## Manual Backend Deployment

### Step 1: Set Up MongoDB Atlas

1. Create a MongoDB Atlas account at [https://www.mongodb.com/cloud/atlas/register](https://www.mongodb.com/cloud/atlas/register)
2. Create a new project
3. Create a free tier cluster in AWS eu-north-1 region
4. Configure database access:
   - Create a user with password authentication
   - Give read/write access to any database
5. Configure network access:
   - Add the ALB and your IP to the IP access list
   - For testing purposes, you can temporarily allow access from anywhere (0.0.0.0/0)
6. Get your MongoDB connection string from the Connect dialogue

### Step 2: SSH into EC2 Instance

1. Find your EC2 instance in the AWS console (it will be created by the Auto Scaling Group)
2. Connect to the instance using SSH:
   ```bash
   ssh -i "your-key-pair.pem" ubuntu@<ec2-public-ip>
   ```
3. Verify that all automated installations have completed:
   ```bash
   node -v
   npm -v
   pm2 -v
   ```

### Step 3: Clone and Configure the Application

1. Clone the application repository:

   ```bash
   git clone https://github.com/cw-barry/blog-app-MERN.git ~/blog-app
   cd ~/blog-app
   ```

2. Configure backend environment:

   ```bash
   cd backend

   # Create .env file
   cat > .env << EOF
   PORT=5000
   HOST=0.0.0.0
   MODE=production

   # Database configuration
   MONGODB=mongodb+srv://test:qazqwe123@mongodb.txkjsso.mongodb.net/blog-app

   # JWT Authentication
   JWT_SECRET=$(openssl rand -hex 32)
   JWT_EXPIRE=30min
   JWT_REFRESH=$(openssl rand -hex 32)
   JWT_REFRESH_EXPIRE=3d

   # AWS S3 Configuration
   AWS_ACCESS_KEY_ID=<your-s3-access-key>
   AWS_SECRET_ACCESS_KEY=<your-s3-secret-key>
   AWS_REGION=eu-north-1
   S3_BUCKET=<your-media-bucket-name>
   MEDIA_BASE_URL=<your-media-bucket-url>

   # Misc
   DEFAULT_PAGINATION=20
   EOF
   ```

3. Install backend dependencies and start the server:

   ```bash
   npm install
   mkdir -p logs

   pm2 start index.js --name "blog-backend"
   pm2 startup
   sudo pm2 startup systemd -u ubuntu
   sudo env PATH=$PATH:/home/ubuntu/.nvm/versions/node/v22.15.0/bin /home/ubuntu/.nvm/versions/node/v22.15.0/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
   pm2 save
   ```

### Step 4: Verify Backend Operation

1. Test the backend health endpoint:

   ```bash
   curl http://localhost:5000/
   ```

2. Open your ALB DNS in a browser to access the application:
   ```
   http://<alb-dns-name>/
   ```

## Frontend Deployment

### Step 1: Configure and Build Frontend

1. Go to the frontend directory:

   ```bash
   cd ~/blog-app/frontend
   ```

2. Create the environment file:

   ```bash
   cat > .env << EOF
   VITE_BASE_URL=http://<your-alb-dns-name>/api
   VITE_MEDIA_BASE_URL=<your-media-bucket-url>
   EOF
   ```

3. Install dependencies and build:
   ```bash
   npm install -g pnpm@latest-10
   pnpm install
   pnpm run build
   ```

### Step 2: Deploy to S3

1. Configure AWS CLI:

   ```bash
   aws configure
   # Enter your AWS Access Key
   # Enter your AWS Secret Key
   # Set default region to eu-north-1
   # Set default output format to json
   ```

2. Upload the build to S3:

   ```bash
   aws s3 sync dist/ s3://<your-frontend-bucket-name>/
   ```

3. Verify the frontend is accessible at the S3 website endpoint:
   ```
   http://<frontend-bucket-website-endpoint>
   ```

## Testing the Application

1. Navigate to the frontend S3 website URL
2. Try the following operations:
   - Create a new user account
   - Log in with the created account
   - Create a new blog post
   - Upload an image to the blog post
   - View and edit the blog post

## Troubleshooting Guide

### Backend Issues

1. **Backend not starting**:

   - Check PM2 logs: `pm2 logs blog-backend`
   - Verify MongoDB connection string in .env
   - Check for required dependencies

2. **Connection issues to MongoDB Atlas**:

   - Verify IP whitelist includes EC2 instance public IP
   - Check MongoDB Atlas user credentials
   - Test connection using `mongosh` command

3. **File upload issues**:
   - Verify S3 permissions (CORS, bucket policy)
   - Check IAM user has appropriate permissions
   - Verify environment variables for S3 config

### Frontend Issues

1. **Build fails**:

   - Check for required dependencies
   - Verify Node.js version compatibility

2. **Frontend not displaying correctly**:

   - Check browser console for errors
   - Verify environment variables point to correct endpoints
   - Check S3 bucket policy allows public access

3. **API calls failing**:
   - Verify ALB DNS name is correct in frontend .env
   - Check backend health endpoint is responding
   - Verify network ACLs and security groups allow traffic

## Conclusion

By following this guide, you should have a fully functioning MERN stack blog application deployed on AWS. The infrastructure is managed by Terraform for reproducibility, while the application deployment requires manual steps to provide experience with real-world deployment scenarios.

For any additional assistance, refer to the AWS documentation, Terraform documentation, or contact the course instructor.

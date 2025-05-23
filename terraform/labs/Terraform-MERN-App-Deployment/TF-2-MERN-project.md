<div style="display: flex; align-items: center; justify-content: space-between;">
    <img src="../../logos/logo4.jpg" alt="Clarusway Logo Footer" width="40"/>
    <h3 style="margin-left: 10px;"><strong>Terraform</strong></h3>
</div>

---

## **Mentoring Activity: AWS MERN Stack Blog App Deployment Lab**

---

## 🎯 **Objective**

Design and deploy a scalable MERN stack blog application using AWS services within the free-tier limits. This lab emphasizes hands-on infrastructure setup, secure configuration, and deployment automation using EC2, ALB, ASG, S3, and MongoDB Atlas.

---

## ✅ **Tasks Overview**

1. **Design Architecture** – Draft and review the system architecture diagram.
2. **VPC Setup** – Create a custom VPC with public subnets.
3. **Security Configuration** – Set up IAM roles, policies, S3 bucket permissions, and security groups.
4. **MongoDB Atlas Setup** – Use MongoDB Atlas cluster as the application's primary database.
5. **S3 Configuration** – Create buckets for frontend and media uploads with public access and proper CORS settings.
6. **Launch Template for Backend** – Define an EC2 launch template.
7. **Backend Server Setup with ASG & ALB** – Deploy backend instances with Auto Scaling Group and expose them using Application Load Balancer.

---

## 🗂️ **Project Requirements**

### 🔹 **Networking**

- Create a **custom VPC** with:
  - At least two **public subnets** in `eu-north-1`
  - An **Internet Gateway** attached
  - Route tables configured for internet access

### 🔹 **Compute**

- Create a **Launch Template** using a t3.micro EC2 instance and Ubuntu 22.04 AMI
- Configure an **Auto Scaling Group (ASG)** using the launch template
- Configure an **Application Load Balancer (ALB)** to route HTTP traffic to backend servers in ASG

### 🔹 **Manual Installation**

- Use SSH to connect to EC2 instances created via ASG
- Manually install Node.js, configure backend, and run using PM2

### 🔹 **Database**

- **MongoDB Atlas**:
  - Configure a free-tier cluster
  - Add ALB IP range to access list
  - Use connection string in backend `.env`

### 🔹 **Storage**

- **S3 (Frontend)**: Host static React frontend
- **S3 (Media)**: Store user-uploaded content
  - Public access policy
  - Proper CORS settings

### 🔹 **Security**

- Create **IAM User** for S3 media programmatic access
- Use **environment variables** to store sensitive data
- Set up **Security Groups** for EC2 and ALB:
  - Allow ports 22, 80, and 5000

---

## 🔧 **Deliverables**

1. Architecture Diagram
2. Terraform scripts for:
   - VPC
   - Security Groups
   - EC2 Launch Template
   - ASG
   - ALB
   - S3 Buckets
3. Manual deployment proof (screenshots):
   - PM2 backend status
   - MongoDB Atlas cluster
   - ALB DNS URL serving backend
   - S3 public URL loading frontend

---

## ✅ **Success Criteria**

- MERN app runs and accepts blog posts/media uploads
- MongoDB Atlas properly connected and used
- ALB exposes backend securely with multiple instances managed by ASG
- S3 hosts frontend and serves media publicly
- SSH access used to configure and run the backend manually

---

<div align="center">   <img src="../../logos/logo.png" alt="Clarusway Logo Footer" height="30"/> </div>

---

# 3-Tier AWS Web Application with Terraform

This project provisions a production-style 3-tier AWS architecture using Terraform and a modular structure. It is designed to be clear, reusable, and strong

## Architecture

The infrastructure consists of three layers:

- Frontend tier
  - Public-facing Application Load Balancer
  - Auto Scaling Group running nginx instances
  - Public subnets for internet access

- Application tier
  - Internal Application Load Balancer
  - Auto Scaling Group for backend services
  - Private subnets for internal-only access

- Data tier
  - Amazon RDS MySQL instance
  - Private subnet placement
  - Security group restricted access from backend instances

## Included Components

- VPC with public and private subnets
- Internet Gateway and NAT Gateway
- Route tables and subnet associations
- Security groups for frontend, backend, and database layers
- CloudWatch alarms and SNS notifications
- Remote backend configuration for Terraform state

## Module Structure

- modules/networking: VPC, subnets, routing, gateways
- modules/security: security groups for frontend, backend, and database tiers
- modules/compute: frontend/backend ALBs, target groups, launch templates, and ASGs
- modules/database: RDS subnet group, parameter group, and database instance
- modules/monitoring: SNS topic, CloudWatch alarms, and email notifications

## Deployment

1. Configure AWS credentials:
   ```bash
   export AWS_PROFILE=default
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan -var-file=dev.tfvars
   ```

4. Apply the infrastructure:
   ```bash
   terraform apply -var-file=dev.tfvars
   ```

## Best Practices Included

- Modular Terraform design
- Clear separation of networking, security, compute, database, and monitoring
- Input validation for critical variables
- Tagged resources for easier governance
- Reusable module boundaries for future extension
- Output values for key endpoints and resources

## Notes

- Update the values in dev.tfvars or prod.tfvars before deployment.
- Make sure your AWS credentials and region settings are valid.
- The RDS password should be changed to a secure value for real-world use.

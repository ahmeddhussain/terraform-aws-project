# 3-Tier AWS Web Application with Terraform & Jenkins CI/CD

This project provisions a production-style 3-tier AWS architecture using Terraform and a modular structure with Jenkins CI/CD integration. It is designed to be clear, reusable, and suitable for a portfolio project.

## Architecture Overview

The infrastructure implements this exact flow:

- `Frontend ALB` is public and routes traffic to frontend EC2 instances.
- `Frontend EC2` runs `nginx` and serves a static page with a single button.
- The frontend proxies `/api` requests to the internal `Backend ALB`.
- `Backend EC2` instances run a Flask API that connects to MySQL.
- `RDS MySQL` stores the message and the backend reads it on request.

When you open the frontend ALB DNS and press the button, the flow is:

`Public Frontend ALB -> Frontend nginx -> Backend ALB -> Flask backend -> RDS MySQL -> returns message`

## Project Components

### Modules

- `modules/networking`
  - VPC, public/private subnets, internet gateway, NAT gateway, route tables.
- `modules/security`
  - Security groups for frontend ALB, frontend EC2, backend ALB, backend EC2, and RDS.
  - Restricts traffic so backend is only accessible via frontend, and DB is only accessible from backend.
- `modules/compute`
  - `frontend_alb.tf`: public frontend ALB, listener, and TG.
  - `frontend_asg.tf`: nginx launch template and frontend ASG.
  - `backend_alb.tf`: internal backend ALB, listener, and TG.
  - `backend_asg.tf`: Flask backend launch template, systemd service, and backend ASG.
  - `data_ami.tf`: AWS AMI lookup for Amazon Linux 2.
  - `locals.tf`: shared compute module locals and tags.
  - `outputs.tf`: frontend/backend DNS and ASG outputs.
- `modules/database`
  - RDS subnet group, parameter group, and MySQL database instance.
- `modules/monitoring`
  - SNS topic, CloudWatch alarms for ASG CPU, and email notifications.

### Key Infrastructure

- `main.tf`
  - Orchestrates the modules and wires outputs/inputs between them.
- `/variables.tf`
  - Defines variables for region, environment, subnets, instance sizes, DB credentials, and alert email.
- `/backend.tf`
  - Configures the Terraform remote state backend (S3).
- `/dev.tfvars` / `/prod.tfvars`
  - Environment-specific values.

## Security Model

- `frontend_alb_sg`: allows HTTP from anywhere on port 80.
- `frontend_ec2_sg`: allows HTTP from the frontend ALB and optional SSH from `allowed_ssh_cidr`.
- `backend_alb_sg`: allows HTTP on port 8080 only from frontend EC2 instances.
- `backend_ec2_sg`: allows HTTP on port 8080 only from the backend ALB and optional SSH from `allowed_ssh_cidr`.
- `db_sg`: allows MySQL on port 3306 only from backend EC2 instances.

> Note: egress is currently open (`0.0.0.0/0`) for outbound traffic. This is acceptable for demo deployments but can be tightened for production.

## Backend Behavior

The backend startup script now:

- installs `python3`, `pip`, `Flask`, and `pymysql`
- writes `/opt/backend/app.py`
- creates `appdb` if it does not exist
- creates the `messages` table if it does not exist
- inserts the message `Hello From Ahmed, Thank You For Using My Project` when the table is empty
- exposes `/api` to return the stored message
- exposes `/health` for ALB health checks

## Deployment via Jenkins

This project is intended to be deployed through Jenkins to demonstrate CI/CD integration.

1. Configure Jenkins with Terraform installed as tool `terraform`.
2. Add AWS credentials in Jenkins using credential ID `aws-credentials-id`.
3. Create a Jenkins pipeline using `/Jenkins-terraform`.
4. Run the job and choose `ENVIRONMENT=dev` or `prod`.
5. Review the generated plan in the Jenkins console.
6. Approve the deployment when prompted.
7. Jenkins will run `terraform apply -auto-approve` and deploy the infrastructure.
8. After a successful run, retrieve the `frontend_alb_dns_name` output from the Jenkins logs or the job artifacts and open it in a browser.

> Do not use `terraform apply` manually for deployment if you want to demonstrate the Jenkins integration. Local Terraform CLI commands are for validation and troubleshooting only.

## Jenkins Integration

A Jenkins pipeline is provided in `/Jenkins-terraform` and includes:

- `ENVIRONMENT` parameter (`dev` or `prod`)
- `Terraform Init`
- `Terraform Workspace` selection or creation
- `Terraform Plan` using `${params.ENVIRONMENT}.tfvars`
- `Approval` stage before apply
- `Terraform Apply -auto-approve`
- Email notifications on failure or abort

### Jenkins Assumptions

- Jenkins has Terraform installed and configured as tool `terraform`.
- Jenkins credentials are stored as `aws-credentials-id`.
- The pipeline uses username/password credentials to populate `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
- For email notifications to work, Jenkins mail must be configured.


## Validation and Local Testing

If you need to validate the configuration locally, use these commands:

```bash
cd <project-path>
terraform fmt -recursive
terraform validate
terraform plan -var-file=dev.tfvars
```

Then run the deployment through Jenkins and open the frontend ALB DNS from the Jenkins output.

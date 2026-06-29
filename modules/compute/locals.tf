locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "3-tier-web-app"
  }

  frontend_alb_name = "${var.alb_name}-${var.environment}"
  frontend_tg_name  = "frontend-tg-${var.environment}"
  backend_alb_name  = "backend-alb-${var.environment}"
  backend_tg_name   = "backend-tg-${var.environment}"
}

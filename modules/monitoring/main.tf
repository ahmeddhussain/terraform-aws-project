resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/terraform/${var.environment}/app"
  retention_in_days = 14
}

resource "aws_sns_topic" "alerts" {
  name = "app-alerts-${var.environment}"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_frontend" {
  alarm_name          = "high-cpu-frontend-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when frontend CPU is high."
  dimensions = {
    AutoScalingGroupName = var.frontend_asg_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_backend" {
  alarm_name          = "high-cpu-backend-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when backend CPU is high."
  dimensions = {
    AutoScalingGroupName = var.backend_asg_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

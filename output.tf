output "alb_id" {
  value = "${module.alb.lb_id}"
}

output "alb_name" {
  value = "${module.alb.lb_dns_name}"
}

output "lambda_function_arn" {
  value = aws_lambda_function.this.arn
}

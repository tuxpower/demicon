resource "random_pet" "this" {
  length = 2
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  function_name = "demicon"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60
  source_path   = "${path.module}/src/"

  attach_policy_statements = true
  policy_statements = {
    s3 = {
      effect = "Allow",
      actions = [
        "s3:Get*",
        "s3:List*",
        "s3-object-lambda:Get*",
        "s3-object-lambda:List*"
      ],
      resources = ["arn:aws:s3:::${var.s3_bucket}/*"]
    },
  }

  layers = [module.lambda_layer_local.lambda_layer_arn]
}

module "lambda_layer_local" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  create_layer = true

  layer_name          = "layer-local"
  description         = "My lambda layer (deployed from local)"
  compatible_runtimes = ["python3.9"]

  create_package         = false
  local_existing_package = "${path.module}/src/my-deployment-package.zip"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id          = data.aws_vpc.selected.id
  subnets         = data.aws_subnet.default.*.id
  security_groups = data.aws_security_group.default.*.id

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}

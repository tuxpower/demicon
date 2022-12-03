resource "random_pet" "this" {
  length = 2
}

resource "aws_lambda_function" "this" {
  filename      = "${path.module}/src/my-deployment-package.zip"
  function_name = "demicon"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  layers        = [aws_lambda_layer_version.this.arn]

  source_code_hash = filebase64sha256("${path.module}/src/my-deployment-package.zip")

  runtime = "python3.9"
  timeout = 60
}

resource "aws_lambda_layer_version" "this" {
  filename   = "${path.module}/src/my-deployment-package.zip"
  layer_name = "demicon"

  compatible_runtimes = ["python3.9"]
}

resource "aws_iam_role" "lambda" {
  name = "lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda" {
  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
        "s3:Get*",
        "s3:List*",
        "s3-object-lambda:Get*",
        "s3-object-lambda:List*"
     ],
     "Resource": [
        "arn:aws:s3:::josegaspar-terraform-state",
        "arn:aws:s3:::josegaspar-terraform-state/*"
     ],
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
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

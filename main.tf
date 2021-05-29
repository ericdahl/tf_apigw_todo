provider "aws" {
  region = "us-east-1"
}

//module "vpc" {
//  source        = "github.com/ericdahl/tf-vpc"
//  admin_ip_cidr = var.admin_cidr
//}

resource "aws_apigatewayv2_api" "default" {
  name          = "tf-apigw-dynamo"
  protocol_type = "HTTP"
}

resource "aws_cloudwatch_log_group" "default" {
  name = "tf-apigw-dynamo"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id = aws_apigatewayv2_api.default.id
  name   = "dev"

  deployment_id = aws_apigatewayv2_deployment.default.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.default.arn

    format = jsonencode(
      {
        httpMethod       = "$context.httpMethod"
        ip               = "$context.identity.sourceIp"
        protocol         = "$context.protocol"
        requestId        = "$context.requestId"
        requestTime      = "$context.requestTime"
        responseLength   = "$context.responseLength"
        routeKey         = "$context.routeKey"
        status           = "$context.status"
        integrationError = "$context.integrationErrorMessage"
      }
    )
  }

}

resource "aws_apigatewayv2_stage" "prod" {
  api_id = aws_apigatewayv2_api.default.id
  name   = "prod"

  deployment_id = aws_apigatewayv2_deployment.default.id
}

resource "aws_apigatewayv2_deployment" "default" {
  api_id      = aws_apigatewayv2_route.httpbin.api_id
  description = "example"

  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_apigatewayv2_integration.httpbin),
      jsonencode(aws_apigatewayv2_route.httpbin),
      jsonencode(aws_apigatewayv2_integration.items_get_index),
      jsonencode(aws_apigatewayv2_route.items_get_index),

      jsonencode(aws_lambda_function.items_get_index),
    )))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_route.httpbin
  ]
}



module "r53_alias" {
  count = var.enable_dns_alias ? 1 : 0
  source = "./r53_alias"

  domain_name = var.dns_alias_r53_name
  zone_id = var.dns_alias_r53_zone_id
  api_id = aws_apigatewayv2_api.default.id
  api_stage_id = aws_apigatewayv2_stage.dev.id
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
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}


resource "aws_dynamodb_table" "items" {
  hash_key = "id"
  name     = "items"
  attribute {
    name = "id"
    type = "S"
  }

  billing_mode = "PAY_PER_REQUEST"
}

resource "aws_dynamodb_table_item" "items_test_1" {

  hash_key   = aws_dynamodb_table.items.hash_key
  table_name = aws_dynamodb_table.items.name

  item = <<ITEM
{
  "id": {"S": "1"},
  "item": {"S": "get some work done"}
}
ITEM
}

resource "aws_dynamodb_table_item" "items_test_2" {

  hash_key   = aws_dynamodb_table.items.hash_key
  table_name = aws_dynamodb_table.items.name

  item = <<ITEM
{
  "id": {"S": "2"},
  "item": {"S": "get some work done again"}
}
ITEM
}

resource "aws_iam_policy" "lambda_get" {
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "arn:aws:dynamodb:us-east-1:669361545709:table/items"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_get" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_get.arn

}
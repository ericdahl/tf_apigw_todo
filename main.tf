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
      jsonencode(aws_apigatewayv2_integration.items_get),
      jsonencode(aws_apigatewayv2_route.items_get),

      jsonencode(aws_lambda_function.items_get),
    )))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_route.httpbin
  ]


}

resource "aws_apigatewayv2_integration" "httpbin" {
  api_id           = aws_apigatewayv2_api.default.id
  integration_type = "HTTP_PROXY"

  integration_uri    = "https://httpbin.org"
  integration_method = "GET"

}

resource "aws_apigatewayv2_route" "httpbin" {
  api_id    = aws_apigatewayv2_api.default.id
  route_key = "GET /httpbin"
  //  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.httpbin.id}"
}

resource "aws_lambda_function" "items_get" {
  function_name = "items-get"
  handler       = "main.handler"
  role          = aws_iam_role.lambda.arn
  runtime       = "python3.8"

  filename = "${path.module}/lambda/items/get.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/items/get.zip")
}

resource "aws_lambda_permission" "items_get_apigw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.items_get.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.default.execution_arn}*"
}

resource "aws_apigatewayv2_integration" "items_get" {
  api_id           = aws_apigatewayv2_api.default.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = aws_lambda_function.items_get.invoke_arn

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "items_get" {
  api_id    = aws_apigatewayv2_api.default.id
  route_key = "GET /items"
  //  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.items_get.id}"
}


data "archive_file" "items_get" {
  type        = "zip"
  output_path = "lambda/items/get.zip"

  source_dir = "lambda/items/get"
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
  name = "items"
  attribute {
    name = "id"
    type = "S"
  }

  billing_mode = "PAY_PER_REQUEST"
}

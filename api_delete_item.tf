resource "aws_apigatewayv2_route" "items_delete_item" {
  api_id    = aws_apigatewayv2_api.default.id
  route_key = "DELETE /items/{item}"

  target = "integrations/${aws_apigatewayv2_integration.items_delete_item.id}"
}

resource "aws_apigatewayv2_integration" "items_delete_item" {
  api_id           = aws_apigatewayv2_api.default.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = aws_lambda_function.items_delete_item.invoke_arn

  payload_format_version = "2.0"
}

resource "aws_lambda_function" "items_delete_item" {
  function_name = "items-delete-item"
  handler       = "main.handler"
  role          = aws_iam_role.lambda.arn
  runtime       = "python3.8"

  filename         = "${path.module}/lambda/items/target/delete_item.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/items/target/delete_item.zip")

  layers = [aws_lambda_layer_version.items.arn]
}

resource "aws_cloudwatch_log_group" "items_delete_item" {
  name = "/aws/lambda/${aws_lambda_function.items_delete_item.function_name}"
}

resource "aws_lambda_permission" "items_delete_item" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.items_delete_item.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.default.execution_arn}*"
}
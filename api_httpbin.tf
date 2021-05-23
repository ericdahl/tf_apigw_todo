resource "aws_apigatewayv2_route" "httpbin" {
  api_id    = aws_apigatewayv2_api.default.id
  route_key = "GET /httpbin"

  target = "integrations/${aws_apigatewayv2_integration.httpbin.id}"
}

resource "aws_apigatewayv2_integration" "httpbin" {
  api_id           = aws_apigatewayv2_api.default.id
  integration_type = "HTTP_PROXY"

  integration_uri    = "https://httpbin.org"
  integration_method = "GET"

}

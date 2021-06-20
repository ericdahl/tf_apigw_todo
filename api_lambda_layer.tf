resource "aws_lambda_layer_version" "items" {
  layer_name          = "items"
  compatible_runtimes = ["python3.8"]
  filename            = "${path.module}/lambda/items/target/layer.zip"
  source_code_hash    = filebase64sha256("${path.module}/lambda/items/target/layer.zip")

}

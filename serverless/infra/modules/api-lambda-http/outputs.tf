output "api_base_url" {
  value = aws_apigatewayv2_stage.this.invoke_url
}

output "hello_url" {
  value = "${trimsuffix(aws_apigatewayv2_stage.this.invoke_url, "/")}${var.route_path}"
}

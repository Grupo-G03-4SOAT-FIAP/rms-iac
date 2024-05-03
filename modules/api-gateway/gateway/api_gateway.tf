resource "aws_api_gateway_rest_api" "minha_api" {
  name        = "my-api"
  description = "My API Gateway"
}

# resource "aws_api_gateway_authorizer" "my_authorizer" {
#   name          = "my-authorizer"
#   rest_api_id   = aws_api_gateway_rest_api.my_api.id
#   type          = "COGNITO_USER_POOLS"
#   provider_arns = [var.cognito_arn]
# }

resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.minha_api.id
  parent_id   = aws_api_gateway_rest_api.minha_api.root_resource_id
  path_part   = "rms"
}








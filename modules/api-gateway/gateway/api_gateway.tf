resource "aws_api_gateway_rest_api" "minha_api" {
  name        = "rms-bff"
  description = "BFF do Restaurant Management System"
}

# resource "aws_api_gateway_authorizer" "my_authorizer" {
#   name          = "my-authorizer"
#   rest_api_id   = aws_api_gateway_rest_api.my_api.id
#   type          = "COGNITO_USER_POOLS"
#   provider_arns = [var.cognito_arn]
# }

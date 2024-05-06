variable "rotas" {
  type = list(object({
    path        = string
    http_method = string
    uri         = string
  }))
}

variable "gateway_id" {}
variable "resource_id" {}


resource "aws_api_gateway_method" "rotas" {
  for_each = { for idx, rota in var.rotas : idx => rota }

  rest_api_id   = var.gateway_id
  resource_id   = var.resource_id
  http_method   = each.value.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rotas" {
  for_each = { for idx, rota in var.rotas : idx => rota }

  rest_api_id             = var.gateway_id
  resource_id             = var.resource_id
  http_method             = aws_api_gateway_method.rotas[each.key].http_method
  integration_http_method = each.value.http_method
  type                    = "HTTP"
  uri                     = each.value.uri
}

resource "aws_api_gateway_method_response" "rotas" {
  for_each = { for idx, rota in var.rotas : idx => rota }

  rest_api_id = var.gateway_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.rotas[each.key].http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "rotas" {
  for_each = { for idx, rota in var.rotas : idx => rota }

  rest_api_id = var.gateway_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.rotas[each.key].http_method
  status_code = aws_api_gateway_method_response.rotas[each.key].status_code
}
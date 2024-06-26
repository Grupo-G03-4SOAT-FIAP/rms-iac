provider "aws" {
  region = var.region
}

module "gateway" {
  source = "./gateway"
}

module "rotas_api" {
  source     = "./rotas"
  gateway_id = module.gateway.api_gateway_id
  rotas = [
    {
      path        = "catalogo"
      http_method = "ANY"
      uri         = "http://www.example.com/rota1"
    },
    {
      path        = "pedido"
      http_method = "ANY"
      uri         = "http://www.example.com/pedido"
    },
    {
      path        = "pagamento"
      http_method = "ANY"
      uri         = "http://www.example.com/rota3"
    },
    # Adicione quantas rotas você precisar
  ]
}

# main.tf

provider "aws" {
  region = "us-east-1"
}

module "gateway" {
  source = "./gateway"
}

module "rotas_api" {
  source      = "./rotas"
  gateway_id  = module.gateway.api_gateway_id
  resource_id = module.gateway.resource_id
  rotas = [
    {
      path        = "/catalogo"
      http_method = "GET"
      uri         = "https://exemplo.com/rota1"
    },
    {
      path        = "/pedido"
      http_method = "POST"
      uri         = "https://exemplo.com/rota2"
    },

    {
      path        = "/pagamento"
      http_method = "POST"
      uri         = "https://exemplo.com/rota2"
    },
    # Adicione quantas rotas você precisar
  ]

  depends_on = [
    module.gateway
  ]
}

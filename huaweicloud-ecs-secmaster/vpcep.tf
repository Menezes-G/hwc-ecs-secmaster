# ----------------------------------------------------------------------------
# VPC Endpoint (VPCEP)
#
# Cenario: Conectar esta VPC a um servico existente via VPC Endpoint
#            com Private Domain Name habilitado (descomente vpcep_endpoint
#            e preencha var.vpcep_service_id)

# VPC Endpoint com Private Domain Name
# (conecta esta VPC a um servico existente via endpoint privado)
#
# O enable_dns = true cria um Private Domain Name para o endpoint, permitindo
# acessar o servico via nome de dominio privado dentro da VPC, sem expor
# trafego a internet publica.

# ----------------------------------------------------------------------------
resource "huaweicloud_vpcep_endpoint" "ecs_secmaster" {
  service_id       = var.vpcep_service_id
  vpc_id           = data.huaweicloud_vpc.existing.id
  network_id       = data.huaweicloud_vpc_subnet.existing.id
 # Ao criar VPC/Subnet novas, use o bloco comentado abaixo
 #   vpc_id           = huaweicloud_vpc.main.id
 #   network_id       = huaweicloud_vpc_subnet.main.id
  enable_dns       = true
  enable_whitelist = true

  # Ao usar VPC/Subnet existentes, o whitelist usa o CIDR lido do data source:
  whitelist        = [data.huaweicloud_vpc_subnet.existing.cidr]
  # Ao criar VPC/Subnet novas, use: 
  #whitelist = [var.subnet_cidr]
  description      = "VPC Endpoint with Private Domain Name for ECS SecMaster"

  lifecycle {
    ignore_changes = [
      enable_dns,
    ]
  }
}


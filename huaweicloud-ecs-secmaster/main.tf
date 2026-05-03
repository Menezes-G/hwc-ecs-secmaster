#BLOCOS USADOS PARA CRIAR VPC E SUBNET
#
# resource "huaweicloud_vpc" "main" {
#   name = "vpc-ecs-secmaster"
#   cidr = var.vpc_cidr
# }

# resource "huaweicloud_vpc_subnet" "main" { 
#   name              = "subnet-ecs-secmaster"
#   cidr              = var.subnet_cidr
#   gateway_ip        = var.subnet_gateway 
#   vpc_id            = huaweicloud_vpc.main.id
#   availability_zone = var.availability_zone
# }

# ----------------------------------------------------------------------------
# Caso voce ja tenha uma VPC e Subnet criadas, descomente o bloco abaixo
# e COMENTE/REMOVA os blocos "resource huaweicloud_vpc" e "resource huaweicloud_vpc_subnet" ACIMA.
#
# Alem disso, faca as seguintes alteracoes:
#
# 1) No arquivo ecs.tf, troque:
#      huaweicloud_vpc_subnet.main.id
#    por:
#      data.huaweicloud_vpc_subnet.existing.id
#
# 2) No arquivo variables.tf, COMENTE as variaveis:
#      vpc_cidr, subnet_cidr, subnet_gateway
#    e DESCOMENTE as variaveis:
#      existing_vpc_name, existing_subnet_name
#    Preencha os nomes da VPC e Subnet existentes nos defaults.
# ----------------------------------------------------------------------------

data "huaweicloud_vpc" "existing" {
  name = var.existing_vpc_name
}

data "huaweicloud_vpc_subnet" "existing" {
  name   = var.existing_subnet_name
  vpc_id = data.huaweicloud_vpc.existing.id
}

resource "huaweicloud_networking_secgroup" "ecs_secmaster" {
  name                 = "sg-ecs-secmaster-01"
  delete_default_rules = true
}

resource "huaweicloud_networking_secgroup_rule" "egress" {
  security_group_id = huaweicloud_networking_secgroup.ecs_secmaster.id
  description       = "Allow all outbound traffic"
  direction         = "egress"
  ethertype         = "IPv4"
}

resource "huaweicloud_networking_secgroup_rule" "ingress_10" { #adicionar se necessário
  security_group_id = huaweicloud_networking_secgroup.ecs_secmaster.id
  description       = "Allow VPC access"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "10.0.0.0/8"
}

resource "huaweicloud_networking_secgroup_rule" "ingress_172" { #adicionar se necessário
  security_group_id = huaweicloud_networking_secgroup.ecs_secmaster.id
  description       = "Allow private network access"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "172.16.0.0/12" 
}

#comentar o bloco abaixo caso não queira fazer login via ssh

resource "huaweicloud_networking_secgroup_rule" "ingress_ssh" {
  security_group_id = huaweicloud_networking_secgroup.ecs_secmaster.id
  description       = "Allow SSH access"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

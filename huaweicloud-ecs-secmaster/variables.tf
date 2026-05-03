variable "hwc_access_key" {
  type        = string
  description = "Access Key (AK) of your Huawei Cloud account or IAM User"
}

variable "hwc_secret_key" {
  type        = string
  sensitive   = true
  description = "Secret Access Key (SK) of your Huawei Cloud account or IAM User"
}

variable "region" {
  type        = string
  default     = "sa-brazil-1"
  description = "Region where cloud resources will be deployed by default"
}

variable "availability_zone" {
  type        = string
  default     = "sa-brazil-1a"
  description = "AZ where cloud resources will be deployed, when relevant"
}

variable "ecs_name" {
  type        = string
  default     = "ecs-secmaster"
  description = "Name of the ECS instance"
}

variable "flavor_id" {
  type        = string
  default     = "x1.4u.8g"
  description = "Flavor ID (instance type) for the ECS"
}

variable "ecs_password" {
  type        = string
  sensitive   = true
  description = "OS admin password for the ECS instance"
}

# ----------------------------------------------------------------------------
# Variaveis para criacao de nova VPC/Subnet
# Caso ja possua VPC/Subnet existentes, COMENTE as 3 variaveis abaixo
# e descomente o bloco "Variaveis para VPC/Subnet existentes" mais abaixo
# ----------------------------------------------------------------------------

# variable "vpc_cidr" {
#   type        = string
#   default     = "10.0.0.0/8"
#   description = "CIDR block for the VPC"
# }

# variable "subnet_cidr" {
#   type        = string
#   default     = "10.0.0.0/24"
#   description = "CIDR block for the subnet"
# }

# variable "subnet_gateway" {
#   type        = string
#   default     = "10.0.0.1"
#   description = "Gateway IP for the subnet"
# }

# ----------------------------------------------------------------------------
# Variaveis para VPC/Subnet existentes (usar somente se descomentar o bloco data source em main.tf)
# ----------------------------------------------------------------------------
variable "existing_vpc_name" {
  type        = string
  default     = "vpc-teste11" #colocar o nome da vpc aqui, não o cidr
  description = "Nome da VPC existente (usar quando VPC/Subnet ja estiverem criadas)"
}

variable "existing_subnet_name" {
  type        = string
  default     = "subnet-teste11" #colocar o nome da subnet aqui, não o cidr
  description = "Nome da Subnet existente (usar quando VPC/Subnet ja estiverem criadas)"
}

variable "eip_bandwidth_size" {
  type        = string
  default     = "100"
  description = "Bandwidth size in Mbit/s for the EIP"
}

variable "system_disk_type" {
  type        = string
  default     = "SAS"
  description = "System disk type (GPSSD, SAS, SSD, GPSSD2)"
}

variable "data_disk_type" {
  type        = string
  default     = "SAS"
  description = "Data disk type (GPSSD, SAS, SSD, GPSSD2)"
}

variable "vpcep_service_id" {
  type        = string
  default     = "2e47504c-053d-4f89-9cfb-0aa090f8aae4" #Service Type: Interface
  description = "ID do VPC Endpoint Service ao qual esta VPC deve se conectar (obter via console ou data source)"
}

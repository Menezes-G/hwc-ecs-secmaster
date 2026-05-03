# Huawei Cloud ECS SecMaster - Terraform

Projeto Terraform para provisionamento de uma instancia ECS na Huawei Cloud (regiao sa-brazil-1) com configuracoes de rede, seguranca e IAM voltadas para integracao com o SecMaster (Security Master).

---

## O que o codigo faz

### Rede (`main.tf`)

- **VPC e Subnet**: O codigo suporta dois cenarios:
  - **Criar nova VPC/Subnet**: blocos `resource` para `huaweicloud_vpc` e `huaweicloud_vpc_subnet` (atualmente comentados)
  - **Usar VPC/Subnet existentes**: data sources `data.huaweicloud_vpc.existing` e `data.huaweicloud_vpc_subnet.existing` que referenciam VPC e Subnet pelo nome (cenario ativo)

- **Security Group** (`sg-ecs-secmaster-01`): criado sem regras default (`delete_default_rules = true`) com as seguintes regras:
  - **Egress**: todo trafego IPv4 de saida permitido
  - **Ingress 10.0.0.0/8**: trafego de entrada permitido de redes VPC privadas
  - **Ingress 172.16.0.0/12**: trafego de entrada permitido de redes privadas RFC1918
  - **Ingress SSH (porta 22/TCP)**: acesso SSH liberado de qualquer origem (`0.0.0.0/0`). Comente este bloco caso nao deseje acesso SSH

### Compute (`ecs.tf`)

- **ECS Instance** (`ecs-secmaster`): instancia criada com:
  - Imagem: EulerOS 2.0 64bit (ID: `a64fbc6f-c62f-4d0f-b2fc-ee9a41efb3f1`)
  - Flavor: configuravel via `var.flavor_id` (default: `x1.4u.8g`)
  - Security Group: `sg-ecs-secmaster-01`
  - Agency: `secmaster-agent` (associada na criacao da ECS)
  - Disco de sistema: 50 GiB (tipo configuravel, default: SAS)
  - Disco de dados: 110 GiB (tipo configuravel, default: SAS)
  - Conectada a VPC/Subnet existente via data source

- **EIP** (`eip-ecs-secmaster`): IP elastico Dynamic BGP (5_bgp) com banda dedicada de 100 Mbit/s e faturacao por trafego

- **Associacao EIP-ECS**: vincula o EIP a instancia ECS

### IAM (`iam.tf`)

- **Custom Policy** (`secmaster-agent-policy`): policy tipo AX que autoriza as seguintes acoes do SecMaster:
  - `secmaster:workspace:get`
  - `secmaster:node:create`
  - `secmaster:node:monitor`
  - `secmaster:node:taskQueueDetail`
  - `secmaster:node:updateTaskNodeStatus`

- **IAM Agency** (`secmaster-agent`): agency que delega o servico `op_svc_ecs` (ECS/BMS) com duracao ilimitada (FOREVER). A custom policy `secmaster-agent-policy` e atribuida a agency no nivel de projeto da regiao. A agency e associada a ECS no momento da criacao via `agency_name`

### VPC Endpoint (`vpcep.tf`)

- **VPC Endpoint com Private Domain Name**: conecta a VPC a um servico existente (ID: `2e47504c-053d-4f89-9cfb-0aa090f8aae4`) via endpoint privado. O `enable_dns = true` cria um Private Domain Name, permitindo acessar o servico via dominio privado dentro da VPC sem trafego pela internet publica. Whitelist habilitada com o CIDR da subnet existente

### Provider (`providers.tf`)

- Provider `huaweicloud/huaweicloud` versao `~> 1.90` autenticado com AK/SK

---

## Arquitetura

```
Internet
   |
   v
  EIP (5_bgp, 100 Mbit/s) ──> ECS (ecs-secmaster)
                                    |
                                    ├── System Disk: 50 GiB (SAS)
                                    ├── Data Disk: 110 GiB (SAS)
                                    ├── Security Group: sg-ecs-secmaster-01
                                    │       ├── Egress: All IPv4
                                    │       ├── Ingress: 10.0.0.0/8
                                    │       ├── Ingress: 172.16.0.0/12
                                    │       └── Ingress: SSH (22/TCP, 0.0.0.0/0)
                                    ├── Agency: secmaster-agent (op_svc_ecs)
                                    └── VPC Endpoint (Private Domain Name)
                                            └── service_id: 2e47504c-...

VPC: existente (referenciada via data source)
  └── Subnet: existente (referenciada via data source)

IAM Custom Policy: secmaster-agent-policy (AX)
  └── Actions: secmaster:workspace:get, secmaster:node:create,
               secmaster:node:monitor, secmaster:node:taskQueueDetail,
               secmaster:node:updateTaskNodeStatus
```

Diagrama visual disponivel em `architecture.drawio`.

---

## Estrutura de Arquivos

| Arquivo | Conteudo |
|---|---|
| `providers.tf` | Provider Huawei Cloud e autenticacao AK/SK |
| `variables.tf` | Todas as variaveis do projeto |
| `main.tf` | VPC/Subnet (criar ou referenciar), Security Group e regras |
| `ecs.tf` | ECS, discos, EIP e associacao EIP-ECS |
| `iam.tf` | Custom Policy e Agency IAM para SecMaster |
| `vpcep.tf` | VPC Endpoint com Private Domain Name |
| `outputs.tf` | Outputs dos recursos criados |
| `architecture.drawio` | Diagrama de arquitetura |

---

## Como Usar

### Prerequisitos

- Terraform >= 1.0
- Conta Huawei Cloud com AK/SK
- VPC e Subnet existentes (cenario atual) ou criar novas (descomentar blocos)

### Configurar variaveis

Edite `terraform.tfvars`:

```hcl
hwc_access_key     = "sua_access_key"
hwc_secret_key     = "sua_secret_key"
region             = "sa-brazil-1"
availability_zone  = "sa-brazil-1a"
ecs_name           = "ecs-secmaster"
flavor_id          = "x1.4u.8g"
ecs_password       = "sua_senha_segura"
existing_vpc_name  = "nome-da-vpc-existente"
existing_subnet_name = "nome-da-subnet-existente"
eip_bandwidth_size = "100"
system_disk_type   = "SAS"
data_disk_type     = "SAS"
vpcep_service_id   = "2e47504c-053d-4f89-9cfb-0aa090f8aae4"
```

### Deploy

```bash
terraform init
terraform plan
terraform apply
```

### Destroy

```bash
terraform destroy
```

---

## Cenarios de Configuracao

### Trocar entre criar VPC nova e usar existente

| Acao | Arquivo | O que fazer |
|---|---|---|
| Usar VPC existente | `main.tf` | Descomentar `data` sources, comentar `resource` VPC/Subnet |
| Usar VPC existente | `ecs.tf` | Trocar `huaweicloud_vpc_subnet.main.id` por `data.huaweicloud_vpc_subnet.existing.id` |
| Usar VPC existente | `variables.tf` | Comentar `vpc_cidr`, `subnet_cidr`, `subnet_gateway` e descomentar `existing_vpc_name`, `existing_subnet_name` |
| Criar VPC nova | `main.tf` | Descomentar `resource` VPC/Subnet, comentar `data` sources |
| Criar VPC nova | `ecs.tf` | Trocar `data.huaweicloud_vpc_subnet.existing.id` por `huaweicloud_vpc_subnet.main.id` |
| Criar VPC nova | `variables.tf` | Descomentar `vpc_cidr`, `subnet_cidr`, `subnet_gateway` e comentar `existing_vpc_name`, `existing_subnet_name` |
| Criar VPC nova | `vpcep.tf` | Trocar `data.huaweicloud_vpc.existing.id` por `huaweicloud_vpc.main.id`, `data.huaweicloud_vpc_subnet.existing.id` por `huaweicloud_vpc_subnet.main.id`, e `data.huaweicloud_vpc_subnet.existing.cidr` por `var.subnet_cidr` |

### Desabilitar acesso SSH

Comente o bloco `huaweicloud_networking_secgroup_rule.ingress_ssh` em `main.tf`.

---

## Outputs

| Output | Descricao |
|---|---|
| `ecs_id` | ID da instancia ECS |
| `ecs_name` | Nome da instancia ECS |
| `eip_address` | IP elastico associado a ECS |
| `security_group_id` | ID do Security Group |
| `custom_policy_name` | Nome da custom policy IAM |
| `agency_name` | Nome da agency IAM |
| `vpcep_private_domain` | Private Domain Name do VPC Endpoint |

---

## Referencias

- [Huawei Cloud Terraform Provider](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs)
- [Huawei Cloud ECS Docs](https://support.huaweicloud.com/intl/en-us/ecs/index.html)
- [Huawei Cloud VPC Endpoint Docs](https://support.huaweicloud.com/intl/en-us/vpcep/index.html)

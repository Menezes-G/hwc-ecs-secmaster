output "ecs_id" {
  value       = huaweicloud_compute_instance.ecs_secmaster.id
  description = "ID of the ECS instance"
}

output "ecs_name" {
  value       = huaweicloud_compute_instance.ecs_secmaster.name
  description = "Name of the ECS instance"
}

output "eip_address" {
  value       = huaweicloud_vpc_eip.ecs_eip.address
  description = "Elastic IP address associated to the ECS"
}

output "security_group_id" {
  value       = huaweicloud_networking_secgroup.ecs_secmaster.id
  description = "ID of the Security Group"
}

output "custom_policy_name" {
  value       = huaweicloud_identity_role.secmaster_policy.name
  description = "Name of the IAM custom policy"
}

output "agency_name" {
  value       = huaweicloud_identity_agency.secmaster_agent.name
  description = "Name of the IAM agency"
}

output "vpcep_private_domain" {
  value       = huaweicloud_vpcep_endpoint.ecs_secmaster.private_domain_name
  description = "Private Domain Name do VPC Endpoint para acesso privado ao servico"
}

resource "huaweicloud_identity_role" "secmaster_policy" {
  name        = "secmaster-agent-policy"
  description = "Custom policy to authorize SecMaster agent actions"
  type        = "AX"

  policy = jsonencode({
    "Version" : "1.1",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secmaster:workspace:get",
          "secmaster:node:create",
          "secmaster:node:monitor",
          "secmaster:node:taskQueueDetail",
          "secmaster:node:updateTaskNodeStatus"
        ]
      }
    ]
  })
}

resource "huaweicloud_identity_agency" "secmaster_agent" {
  name                  = "secmaster-agent"
  description           = "ECS Agency to enable SecMaster LogAudit Components Node Controller"
  delegated_service_name = "op_svc_ecs"
  duration              = "FOREVER"

  project_role {
    project = var.region
    roles   = [huaweicloud_identity_role.secmaster_policy.name]
  }
}

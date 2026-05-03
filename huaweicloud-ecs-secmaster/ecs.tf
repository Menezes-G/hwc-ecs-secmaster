resource "huaweicloud_compute_instance" "ecs_secmaster" {
  name               = var.ecs_name
  image_id           = "a64fbc6f-c62f-4d0f-b2fc-ee9a41efb3f1" #EulerOS 2.0 64bit
  flavor_id          = var.flavor_id
  security_group_ids = [huaweicloud_networking_secgroup.ecs_secmaster.id]
  region             = var.region
  availability_zone  = var.availability_zone
  admin_pass         = var.ecs_password
  agency_name        = huaweicloud_identity_agency.secmaster_agent.name
  system_disk_type   = var.system_disk_type
  system_disk_size   = 50

  network {
    # Se usar VPC/Subnet existentes, troque a referencia abaixo por:
    uuid = data.huaweicloud_vpc_subnet.existing.id
    #uuid              = huaweicloud_vpc_subnet.main.id
    source_dest_check = true
  }

  data_disks {
    type = var.data_disk_type
    size = 110
  }
}

resource "huaweicloud_vpc_eip" "ecs_eip" {
  name = "eip-${var.ecs_name}"
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "bw-${var.ecs_name}"
    size        = var.eip_bandwidth_size
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_compute_eip_associate" "ecs_eip" {
  public_ip   = huaweicloud_vpc_eip.ecs_eip.address
  instance_id = huaweicloud_compute_instance.ecs_secmaster.id
}

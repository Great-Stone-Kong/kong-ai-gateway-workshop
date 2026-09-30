locals {
  operator_ip   = chomp(data.http.my_ip.response_body)
  # Browser vs curl often differ within the same /24 on ISP egress.
  operator_cidr = "${join(".", slice(split(".", local.operator_ip), 0, 3))}.0/24"

  tags = {
    Owner = "gs.lee@konghq.com"
    Project = "kong-workshop-ai-gateway"
    Managed = "terraform"
  }

  # Shared workshop consumer — same apikey for all students.
  consumers = [
    {
      username = "workshop"
      key      = "sk-kong-workshop"
    }
  ]

  kong_yml = templatefile("${path.module}/templates/kong.yml.tftpl", {
    openai_api_key    = var.openai_api_key
    gemini_api_key    = var.gemini_api_key
    openai_model      = var.openai_model
    gemini_model      = var.gemini_model
    rate_limit_minute = var.rate_limit_minute
    consumers         = local.consumers
  })

  license_abs = abspath(var.kong_license_path)
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
  
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "random_id" "suffix" {
  byte_length = 2
}

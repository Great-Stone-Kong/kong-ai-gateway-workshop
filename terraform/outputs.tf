output "operator_ip" {
  description = "Operator public IP detected at apply time (checkip)"
  value       = local.operator_ip
}

output "operator_cidr" {
  description = "Operator /24 CIDR used for SSH/Admin/Manager SG rules"
  value       = local.operator_cidr
}

output "public_ip" {
  description = "Elastic IP of the Kong instance"
  value       = aws_eip.kong.public_ip
}

output "public_dns" {
  description = "Public DNS of the Kong instance (EIP association)"
  value       = aws_eip.kong.public_dns
}

output "proxy_url" {
  description = "Student-facing Kong proxy base URL"
  value       = "http://${aws_eip.kong.public_ip}:8000"
}

output "admin_url" {
  description = "Operator Admin API URL (SG-restricted)"
  value       = "http://${aws_eip.kong.public_ip}:8001"
}

output "manager_url" {
  description = "Operator Kong Manager GUI URL (SG-restricted, DB-less read-mostly)"
  value       = "http://${aws_eip.kong.public_ip}:8002"
}

output "openai_route" {
  description = "OpenAI chat route"
  value       = "http://${aws_eip.kong.public_ip}:8000/openai"
}

output "gemini_route" {
  description = "Gemini chat route"
  value       = "http://${aws_eip.kong.public_ip}:8000/gemini"
}

output "anthropic_base_url" {
  description = "Anthropic Messages base URL for Claude Code (append /v1/messages)"
  value       = "http://${aws_eip.kong.public_ip}:8000"
}

output "messages_route" {
  description = "Anthropic Messages route (llm_format anthropic → OpenAI)"
  value       = "http://${aws_eip.kong.public_ip}:8000/v1/messages"
}

output "ssh_private_key_path" {
  description = "Local path to generated SSH private key"
  value       = local_sensitive_file.ssh_private_key.filename
}

output "workshop_apikey" {
  description = "Shared workshop key-auth apikey (WORKSHOP_LLM_APIKEY)"
  value       = "sk-kong-workshop"
}

output "kong_bootstrap_id" {
  description = "terraform_data.kong_install id (changes when bootstrap re-runs)"
  value       = terraform_data.kong_install.id
}

output "my_ip" {
  description = "My public IP"
  value       = chomp(data.http.my_ip.response_body)
}
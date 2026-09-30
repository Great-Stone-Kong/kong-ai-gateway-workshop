variable "aws_profile" {
  type        = string
  description = "AWS CLI/SSO profile (optional; null uses the default credential chain)"
  default     = null
  nullable    = true
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-2"
}

variable "name_prefix" {
  type        = string
  description = "Resource name prefix"
  default     = "workshop-aigw"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "kong_image" {
  type        = string
  description = "Kong Gateway Enterprise Docker image"
  default     = "kong/kong-gateway:3.15"
}

variable "kong_license_path" {
  type        = string
  description = "Absolute path to Kong Enterprise license JSON"
}

variable "openai_api_key" {
  type        = string
  description = "OpenAI API key injected into AI Proxy Advanced (server-side only)"
  sensitive   = true
}

variable "gemini_api_key" {
  type        = string
  description = "Gemini API key injected into AI Proxy Advanced (server-side only)"
  sensitive   = true
}

variable "openai_model" {
  type        = string
  description = "Default OpenAI chat model"
  default     = "gpt-4o-mini"
}

variable "gemini_model" {
  type        = string
  description = "Default Gemini chat model (cost-efficient Flash-Lite)"
  default     = "gemini-2.5-flash-lite"
}

variable "rate_limit_minute" {
  type        = number
  description = "Per-consumer request limit per minute (shared workshop apikey)"
  default     = 6000
}

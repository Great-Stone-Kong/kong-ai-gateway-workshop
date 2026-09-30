# Workshop LLM hub (Terraform)

Runs Kong Gateway Enterprise **3.15** on AWS EC2 in **DB-less** mode as the shared Workshop LLM API hub.

Workshop structure: [`../README.md`](../README.md). Student labs: [`../website/docs`](../website/docs/) or [GitHub Pages](https://great-stone-kong.github.io/kong-ai-gateway-workshop/).

## Purpose

- Routes `/openai`, `/gemini`, `/v1/messages` with `key-auth` + `rate-limiting`
- Students use `apikey` only; OpenAI/Gemini keys stay on the hub

## Layout

| Item | Path |
|---|---|
| Terraform | This directory |
| Declarative config | `templates/kong.yml.tftpl` |
| Bootstrap | `scripts/install-kong.sh` |

## How it is applied

- EC2 `t3.medium` + Elastic IP (no ALB)
- SG: `8000` open; `22` / `8001` / `8002` limited to apply-time checkip `/24`
- Docker `kong/kong-gateway:3.15`, `KONG_DATABASE=off`
- Kong Manager on `:8002` (DB-less: view only)
- `/openai`, `/gemini`: OpenAI-compatible chat
- `/v1/messages`: `llm_format: anthropic` → OpenAI (Claude Code)

## Apply

```bash
cd terraform
export TF_VAR_openai_api_key="$DECK_OPENAI_API_KEY"
export TF_VAR_gemini_api_key="$DECK_GEMINI_API_KEY"
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE AWS_DEFAULT_REGION AWS_REGION
# cp terraform.tfvars.example terraform.tfvars
# set openai_api_key, gemini_api_key, kong_license_path
# optional: aws_profile = "your-aws-sso-profile" (omit to use default credential chain)

terraform init
terraform apply
```

## Outputs

| Output | Use |
|---|---|
| `proxy_url` | Proxy base (`:8000`) |
| `openai_route` / `gemini_route` / `messages_route` | Chat and Messages URLs |
| `anthropic_base_url` | Hub base for direct Claude Code checks |
| `admin_url` / `manager_url` | Admin `:8001` / Manager `:8002` (operator /24) |
| `workshop_apikey` | Shared workshop `apikey` (`sk-kong-workshop`) |
| `ssh_private_key_path` | Generated SSH key |
| `operator_ip` / `operator_cidr` | checkip and SG `/24` |

```bash
terraform output -raw workshop_apikey
```

Student packet example:

```bash
WORKSHOP_LLM_OPENAI_URL=$(terraform output -raw openai_route)
WORKSHOP_LLM_GEMINI_URL=$(terraform output -raw gemini_route)
WORKSHOP_LLM_BASE_URL=$(terraform output -raw anthropic_base_url)
WORKSHOP_LLM_APIKEY=sk-kong-workshop
```

## Smoke tests

```bash
PROXY=$(terraform output -raw proxy_url)
KEY=sk-kong-workshop

curl -sS "$PROXY/openai" \
  -H "apikey: $KEY" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Say hello in one sentence."}]}'

curl -sS "$PROXY/gemini" \
  -H "apikey: $KEY" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Say hello in one sentence."}]}'

curl -sS "$PROXY/v1/messages" \
  -H "apikey: $KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-sonnet-4-6","max_tokens":64,"messages":[{"role":"user","content":"Say hello in one sentence."}]}'
```

## Destroy

```bash
cd terraform
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE AWS_DEFAULT_REGION AWS_REGION
terraform destroy
```

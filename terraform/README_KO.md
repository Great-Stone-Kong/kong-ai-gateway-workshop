# Workshop LLM 허브 (Terraform)

AWS EC2에서 Kong Gateway Enterprise **3.15**를 **DB-less**로 올려 공유 Workshop LLM API 허브를 운영합니다.

워크샵 시나리오는 [`../README_KO.md`](../README_KO.md), 실습 문서는 [`../website/docs`](../website/docs/) 또는 [GitHub Pages](https://great-stone-kong.github.io/kong-ai-gateway-workshop/)를 참고합니다.

## 목적

- `/openai`, `/gemini`, `/v1/messages` + `key-auth` + `rate-limiting`
- 실습자는 `apikey`만 사용하고, OpenAI/Gemini 키는 허브에만 둡니다

## 구성

| 항목 | 경로 |
|---|---|
| Terraform | 이 디렉터리 |
| Declarative 설정 | `templates/kong.yml.tftpl` |
| 부트스트랩 | `scripts/install-kong.sh` |

## 적용 방식

- EC2 `t3.medium` + Elastic IP (ALB 없음)
- SG: `8000` 전체 개방, `22` / `8001` / `8002`는 apply 시점 checkip IP의 `/24`
- Docker `kong/kong-gateway:3.15`, `KONG_DATABASE=off`
- Kong Manager `:8002` (DB-less: 조회용)
- `/openai`, `/gemini`: OpenAI 호환 chat
- `/v1/messages`: `llm_format: anthropic` → OpenAI (Claude Code)

## 사전 준비사항

- `TF_VAR_openai_api_key`에서 사용할 OpenAI API Key
- `TF_VAR_gemini_api_key`에서 사용할 Gemini API Key
- Terraform 에서 사용할 AWS 환경
  - 해당 환경에서는 `~/.aws/credential`의 정보를 사용
- AWS 환경에 Kong Enterprise 환경을 구성하기 위한 `KONG_LICENSE_PATH`가 필요합니다.

## 적용

```bash
cd terraform
export TF_VAR_openai_api_key="$OPENAI_API_KEY"
export TF_VAR_gemini_api_key="$GEMINI_API_KEY"
export TF_VAR_kong_license_path="$KONG_LICENSE_PATH"
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE AWS_DEFAULT_REGION AWS_REGION
# cp terraform.tfvars.example terraform.tfvars
# openai_api_key, gemini_api_key, kong_license_path 설정
# 필요 시 aws_profile = "your-aws-sso-profile" (미설정 시 기본 credential chain)

terraform init
terraform apply
```

## 출력

| Output | 용도 |
|---|---|
| `proxy_url` | Proxy base (`:8000`) |
| `openai_route` / `gemini_route` / `messages_route` | 채팅·Messages URL |
| `anthropic_base_url` | Claude Code 허브 직접 검증 시 base |
| `admin_url` / `manager_url` | Admin `:8001` / Manager `:8002` (운영자 /24) |
| `workshop_apikey` | 공유 실습 `apikey` (`sk-kong-workshop`) |
| `ssh_private_key_path` | 생성 SSH 키 |
| `operator_ip` / `operator_cidr` | checkip 및 SG `/24` |

```bash
terraform output -raw workshop_apikey
```

실습자 패킷 예:

```bash
WORKSHOP_LLM_OPENAI_URL=$(terraform output -raw openai_route)
WORKSHOP_LLM_GEMINI_URL=$(terraform output -raw gemini_route)
WORKSHOP_LLM_BASE_URL=$(terraform output -raw anthropic_base_url)
WORKSHOP_LLM_APIKEY=sk-kong-workshop
```

## 스모크 테스트

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

## 삭제

```bash
cd terraform
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE AWS_DEFAULT_REGION AWS_REGION
terraform destroy
```

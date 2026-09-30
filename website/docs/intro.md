---
title: "워크샵 소개"
---

실습 대상은 **Kong Konnect**와 신규 org에 포함되는 **Serverless** 게이트웨이입니다. API Gateway 기본기 다음에 **AI Proxy**로 공유 **Workshop LLM API**에 연결합니다. 모델 공급자 키는 운영자가 보관합니다.

## 대상

- Konnect에서 첫 Gateway·첫 AI 라우트를 만드는 실습자
- Workshop LLM 자격 증명을 배포하는 운영자(운영자 부록 참고)

## 사전 준비

- `curl`, `jq`
- 선택: 선언형 적용용 [decK](https://docs.konghq.com/deck/)
- [Kong Konnect](https://konnect.konghq.com) 계정 (신규 org에 Serverless 포함)
- 강사로부터 받은 Workshop 패킷(`WORKSHOP_LLM_*` — Scene 0)

## 런타임 (실습자)

| 항목 | 값 |
|---|---|
| Control Plane | 본인 Konnect Gateway CP |
| Data Plane | **Serverless** (US 권장) |
| Proxy | Konnect Overview의 **Proxy URL** (`KONNECT_PROXY_URL`) |
| LLM Upstream | 강사 패킷의 Workshop LLM API URL |

```bash
export KONNECT_PROXY_URL=<konnect-overview의-proxy-url>
export DECK_KONNECT_TOKEN=<your-personal-access-token>
export DECK_KONNECT_ADDR=https://us.api.konghq.com
export DECK_KONNECT_CONTROL_PLANE_NAME=<your-serverless-gw-name>

# 강사 패킷
export WORKSHOP_LLM_OPENAI_URL=...
export WORKSHOP_LLM_GEMINI_URL=...
export WORKSHOP_LLM_BASE_URL=...
export WORKSHOP_LLM_APIKEY=sk-kong-workshop
```

## 실습 (~3.5시간)

| Scene | 초점 | 시간 |
|---|---|---|
| [0 Orientation](/docs/scene-0-orientation) | Konnect 계정, Serverless, AI Gateway, 패킷 env | ~25분 |
| [1 Services & Routes](/docs/scene-1-services-routes) | httpbin용 Service / Route | ~25분 |
| [2 Plugin](/docs/scene-2-plugin) | 기본 플러그인 | ~25분 |
| [3 Auth](/docs/scene-3-auth) | Consumer + key-auth | ~25분 |
| [4 AI Proxy → OpenAI](/docs/scene-4-ai-proxy-openai) | Plain Service → AI Proxy Advanced + 정책 | ~45분 |
| [5 Multi-provider LB](/docs/scene-5-ai-multi-provider) | `/ai/openai`에 Gemini 추가 · RR · failover | ~30분 |
| [6 Claude Code backend](/docs/scene-6-claude-code-backend) | Claude → Konnect AI Proxy → 허브 `/v1/messages` | ~25분 |

## 흐름

```text
실습자 (curl / SDK / Claude Code)
  → Konnect Serverless Data Plane
      → Scene 1–3: httpbin / 플러그인 / 인증
      → Scene 4: AI Proxy Advanced → Workshop OpenAI URL + 정책
      → Scene 5: 같은 AI Proxy Advanced에 Gemini target · balancer
      → Scene 6: Anthropic Messages → Workshop `/v1/messages` (Claude Code BASE URL)
```

## 실습 진행 방법

1. [Scene 0](/docs/scene-0-orientation)을 완료합니다.
2. 실습 폴더의 `README.md` / `README_KO.md`를 따릅니다.
3. 학습은 Konnect UI를 우선하고, 실습에 `config.yaml`이 있으면 decK를 사용합니다.
4. API 호출은 `$KONNECT_PROXY_URL`(Serverless proxy)로 합니다.

## 운영자 부록

실습자에게는 Workshop LLM 패킷만 필요합니다. 공유 허브는 [`../terraform/README_KO.md`](https://github.com/Great-Stone-Kong/kong-ai-gateway-workshop/tree/main/terraform)로 기동한 뒤 다음을 배포합니다.

```bash
WORKSHOP_LLM_OPENAI_URL=http://<hub-host>:8000/openai
WORKSHOP_LLM_GEMINI_URL=http://<hub-host>:8000/gemini
WORKSHOP_LLM_BASE_URL=http://<hub-host>:8000
WORKSHOP_LLM_APIKEY=sk-kong-workshop
```

허브 내부 구성과 공급자 키는 실습 자료에 넣지 않습니다.

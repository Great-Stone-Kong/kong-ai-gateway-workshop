# Kong AI Gateway Workshop

Kong Konnect 실습과 공유 **Workshop LLM** 허브로 구성된 AI Gateway 워크샵입니다.

> 참고: [AWS Kong Konnect catalog](https://catalog.workshops.aws/kong-konnect/en-US/00-what-is-kong-konnect)

## 목적

실습자가 **Konnect Serverless**에서 API Gateway·AI Proxy를 구성하고, 운영자가 올린 공유 LLM 허브로 upstream을 연결합니다. 모델 공급자 키는 운영자만 보유합니다.

## 구조

| 경로 | 역할 |
|---|---|
| [`docs/`](./docs/) | 실습자 시나리오 (Scene 0–6) |
| [`terraform/`](./terraform/) | 운영자 공유 LLM 허브 (EC2 Kong EE DB-less) |

```text
실습자 (curl / SDK / Claude Code)
  → Konnect Serverless
      → Scene 1–3: Service / Route / Plugin / Auth
      → Scene 4–5: AI Proxy → Workshop `/openai`, `/gemini`
      → Scene 6: Anthropic Messages → Workshop `/v1/messages`
운영자
  → terraform/ 로 허브 기동 후 WORKSHOP_LLM_* 패킷 배포
```

## 대상

| 대상 | 하는 일 | 문서 |
|---|---|---|
| **실습자** | Konnect Serverless + AI Proxy 구성 | [`docs/README_KO.md`](./docs/README_KO.md) |
| **운영자** | 허브 apply · 패킷 배포 | [`terraform/README_KO.md`](./terraform/README_KO.md) |

## 시나리오

| Scene | 초점 | 시간 |
|---|---|---|
| [0 Orientation](./docs/scene-0-orientation/) | Konnect · Serverless · 패킷 env | ~25분 |
| [1 Services & Routes](./docs/scene-1-services-routes/) | httpbin Service / Route | ~25분 |
| [2 Plugin](./docs/scene-2-plugin/) | 기본 플러그인 | ~25분 |
| [3 Auth](./docs/scene-3-auth/) | Consumer + key-auth | ~25분 |
| [4 AI Proxy → OpenAI](./docs/scene-4-ai-proxy-openai/) | AI Proxy Advanced → `/openai` | ~45분 |
| [5 Multi-provider LB](./docs/scene-5-ai-multi-provider/) | Gemini target · RR · failover | ~30분 |
| [6 Claude Code backend](./docs/scene-6-claude-code-backend/) | Claude → Konnect → 허브 `/v1/messages` | ~25분 |

합계 약 3.5시간. 상세 진행은 [`docs/`](./docs/)을 따릅니다.

## 실습자 패킷 (운영자 배포)

```bash
WORKSHOP_LLM_OPENAI_URL=http://<eip>:8000/openai
WORKSHOP_LLM_GEMINI_URL=http://<eip>:8000/gemini
WORKSHOP_LLM_BASE_URL=http://<eip>:8000
WORKSHOP_LLM_APIKEY=sk-kong-workshop
```

허브 기동·output·스모크는 [`terraform/README_KO.md`](./terraform/README_KO.md)를 참고합니다.

## 인증 계약 (요약)

| 구간 | 방식 |
|---|---|
| Konnect AI Proxy → 허브 | 헤더 `apikey` + 실습자 키 |
| 허브 → OpenAI / Gemini | `Authorization: Bearer` + 공급자 키 (운영자만) |

- Scene 4/5: `upstream_url` = 허브 `/openai` 또는 `/gemini` 전체 URL
- Scene 6: Service = 허브 base, `upstream_url` = `/v1/messages`, `provider: anthropic`, `llm_format: anthropic`

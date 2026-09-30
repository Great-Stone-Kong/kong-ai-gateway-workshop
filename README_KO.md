# Kong AI Gateway Workshop

Kong Konnect 실습과 공유 **Workshop LLM** 허브로 구성된 AI Gateway 워크샵입니다.

- **실습 사이트 (GitHub Pages):** https://great-stone-kong.github.io/kong-ai-gateway-workshop/
- 기본 언어: **한국어** (`ko`) · English locale 전환 지원
- 문서 소스: [`website/`](./website/) (Docusaurus 3.10.2)

> 참고: [AWS Kong Konnect catalog](https://catalog.workshops.aws/kong-konnect/en-US/00-what-is-kong-konnect)

## 목적

실습자가 **Konnect Serverless**에서 API Gateway·AI Proxy를 구성하고, 운영자가 올린 공유 LLM 허브로 upstream을 연결합니다. 모델 공급자 키는 운영자만 보유합니다.

## 구조

| 경로 | 역할 |
|---|---|
| [`website/`](./website/) | 실습 문서 사이트 (Docusaurus, ko/en) |
| [`terraform/`](./terraform/) | 운영자 공유 LLM 허브 (EC2 Kong EE DB-less) |

```text
실습자 → Konnect Serverless → Scene 1–6 (website docs)
운영자 → terraform/ 허브 기동 후 WORKSHOP_LLM_* 패킷 배포
```

## 대상

| 대상 | 하는 일 | 문서 |
|---|---|---|
| **실습자** | Konnect Serverless + AI Proxy | [사이트](https://great-stone-kong.github.io/kong-ai-gateway-workshop/) / [`website/docs`](./website/docs/) |
| **운영자** | 허브 apply · 패킷 배포 | [`terraform/README_KO.md`](./terraform/README_KO.md) |

## 시나리오

| Scene | 초점 | 시간 |
|---|---|---|
| [0 Orientation](./website/docs/scene-0-orientation/) | Konnect · Serverless · 패킷 env | ~25분 |
| [1 Services & Routes](./website/docs/scene-1-services-routes/) | httpbin Service / Route | ~25분 |
| [2 Plugin](./website/docs/scene-2-plugin/) | 기본 플러그인 | ~25분 |
| [3 Auth](./website/docs/scene-3-auth/) | Consumer + key-auth | ~25분 |
| [4 AI Proxy → OpenAI](./website/docs/scene-4-ai-proxy-openai/) | AI Proxy Advanced → `/openai` | ~45분 |
| [5 Multi-provider LB](./website/docs/scene-5-ai-multi-provider/) | Gemini target · RR · failover | ~30분 |
| [6 Claude Code backend](./website/docs/scene-6-claude-code-backend/) | Claude → Konnect → 허브 `/v1/messages` | ~25분 |

합계 약 3.5시간.

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

## 로컬에서 문서 사이트 실행

```bash
cd website
npm ci
npm start
```

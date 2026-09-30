# Kong AI Gateway Workshop

Hands-on Kong Konnect labs plus a shared **Workshop LLM** hub.

> See also: [AWS Kong Konnect catalog](https://catalog.workshops.aws/kong-konnect/en-US/00-what-is-kong-konnect)

## Purpose

Students build API Gateway and AI Proxy on **Konnect Serverless**, and call a shared LLM hub that the operator runs. Provider API keys stay with the operator.

## Layout

| Path | Role |
|---|---|
| [`workshop/`](./workshop/) | Student scenarios (Scenes 0–6) |
| [`terraform/`](./terraform/) | Operator shared LLM hub (EC2 Kong EE DB-less) |

```text
Student (curl / SDK / Claude Code)
  → Konnect Serverless
      → Scenes 1–3: Service / Route / Plugin / Auth
      → Scenes 4–5: AI Proxy → Workshop `/openai`, `/gemini`
      → Scene 6: Anthropic Messages → Workshop `/v1/messages`
Operator
  → start hub via terraform/, hand out WORKSHOP_LLM_* packet
```

## Audience

| Audience | Work | Docs |
|---|---|---|
| **Student** | Konnect Serverless + AI Proxy | [`workshop/README.md`](./workshop/README.md) |
| **Operator** | Hub apply + packet distribution | [`terraform/README.md`](./terraform/README.md) |

## Scenarios

| Scene | Focus | Time |
|---|---|---|
| [0 Orientation](./workshop/scene-0-orientation/) | Konnect · Serverless · packet env | ~25 min |
| [1 Services & Routes](./workshop/scene-1-services-routes/) | httpbin Service / Route | ~25 min |
| [2 Plugin](./workshop/scene-2-plugin/) | Basic plugins | ~25 min |
| [3 Auth](./workshop/scene-3-auth/) | Consumer + key-auth | ~25 min |
| [4 AI Proxy → OpenAI](./workshop/scene-4-ai-proxy-openai/) | AI Proxy Advanced → `/openai` | ~45 min |
| [5 Multi-provider LB](./workshop/scene-5-ai-multi-provider/) | Gemini target · RR · failover | ~30 min |
| [6 Claude Code backend](./workshop/scene-6-claude-code-backend/) | Claude → Konnect → hub `/v1/messages` | ~25 min |

About 3.5 hours total. Follow [`workshop/`](./workshop/) for lab steps.

## Student packet (operator distributes)

```bash
WORKSHOP_LLM_OPENAI_URL=http://<eip>:8000/openai
WORKSHOP_LLM_GEMINI_URL=http://<eip>:8000/gemini
WORKSHOP_LLM_BASE_URL=http://<eip>:8000
WORKSHOP_LLM_APIKEY=sk-kong-workshop
```

Hub apply, outputs, and smoke tests: [`terraform/README.md`](./terraform/README.md).

## Auth contract (summary)

| Hop | Mechanism |
|---|---|
| Konnect AI Proxy → hub | Header `apikey` + student key |
| Hub → OpenAI / Gemini | `Authorization: Bearer` + provider key (operator only) |

- Scenes 4/5: `upstream_url` = full hub `/openai` or `/gemini`
- Scene 6: Service = hub base, `upstream_url` = `/v1/messages`, `provider: anthropic`, `llm_format: anthropic`

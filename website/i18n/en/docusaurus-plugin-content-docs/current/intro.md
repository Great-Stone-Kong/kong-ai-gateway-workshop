---
title: "Workshop overview"
---

Hands-on lab: Kong API Gateway basics, then AI Proxy against a shared **Workshop LLM API**. You work in **Kong Konnect** with the free-tier **Serverless** gateway that comes with a new organization. Provider keys stay with the lab operator.

## Audience

- Students building their first API gateway and first AI route on Konnect
- Operators who distribute Workshop LLM credentials after the shared LLM hub is ready (see Operator appendix)

## Prerequisites

- `curl`, `jq`
- Optional: [decK](https://docs.konghq.com/deck/) for declarative apply
- A free [Kong Konnect](https://konnect.konghq.com) account (new org includes Serverless)
- Workshop packet from the instructor (`WORKSHOP_LLM_*` — Scene 0)

## Runtime (students)

| Item | Value |
|---|---|
| Control plane | Your Konnect Gateway CP |
| Data plane | **Serverless** (US recommended) |
| Proxy | Konnect Overview **Proxy URL** (`KONNECT_PROXY_URL`) |
| LLM upstream | Workshop LLM API URLs from the instructor packet |

```bash
export KONNECT_PROXY_URL=<proxy-url-from-konnect-overview>
export DECK_KONNECT_TOKEN=<your-personal-access-token>
export DECK_KONNECT_ADDR=https://us.api.konghq.com
export DECK_KONNECT_CONTROL_PLANE_NAME=<your-serverless-gw-name>

# From instructor packet
export WORKSHOP_LLM_OPENAI_URL=...
export WORKSHOP_LLM_GEMINI_URL=...
export WORKSHOP_LLM_BASE_URL=...
export WORKSHOP_LLM_APIKEY=sk-kong-workshop
```

## Scenes (~3.5 hours)

| Scene | Focus | Time |
|---|---|---|
| [0 Orientation](/docs/scene-0-orientation) | Konnect account, Serverless, AI Gateway, packet env | ~25 min |
| [1 Services & Routes](/docs/scene-1-services-routes) | Service / Route to httpbin | ~25 min |
| [2 Plugin](/docs/scene-2-plugin) | Core plugins | ~25 min |
| [3 Auth](/docs/scene-3-auth) | Consumer + key-auth | ~25 min |
| [4 AI Proxy → OpenAI](/docs/scene-4-ai-proxy-openai) | Plain Service → AI Proxy Advanced + policies | ~45 min |
| [5 Multi-provider LB](/docs/scene-5-ai-multi-provider) | Add Gemini to `/ai/openai` · RR · failover | ~30 min |
| [6 Claude Code backend](/docs/scene-6-claude-code-backend) | Claude → Konnect AI Proxy → hub `/v1/messages` | ~25 min |

## Flow

```text
You (curl / SDK / Claude Code)
  → Konnect Serverless Data Plane
      → Scene 1–3: httpbin / plugins / auth
      → Scene 4: AI Proxy Advanced → Workshop OpenAI URL + policies
      → Scene 5: Same AI Proxy Advanced + Gemini target · balancer
      → Scene 6: Anthropic Messages → Workshop `/v1/messages` (Claude Code BASE URL)
```

## How to run a scene

1. Complete [Scene 0](/docs/scene-0-orientation).
2. Open the scene folder and follow `README.md` / `README_KO.md`.
3. Prefer Konnect UI for learning; use decK when the scene provides `config.yaml`.
4. Call APIs against `$KONNECT_PROXY_URL` (Serverless proxy).

## Operator appendix

Students only need the Workshop LLM packet. Operators who run the shared hub should follow [`../terraform/README.md`](https://github.com/Great-Stone-Kong/kong-ai-gateway-workshop/tree/main/terraform), then hand out:

```bash
WORKSHOP_LLM_OPENAI_URL=http://<hub-host>:8000/openai
WORKSHOP_LLM_GEMINI_URL=http://<hub-host>:8000/gemini
WORKSHOP_LLM_BASE_URL=http://<hub-host>:8000
WORKSHOP_LLM_APIKEY=sk-kong-workshop
```

Do not put hub internals or provider keys in student materials.

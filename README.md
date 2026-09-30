# Kong AI Gateway Workshop

Hands-on Kong Konnect labs plus a shared **Workshop LLM** hub.

- **Workshop site (GitHub Pages):** https://great-stone-kong.github.io/kong-ai-gateway-workshop/
- Default locale: **Korean (`ko`)** with English via the language switcher
- Docs source: [`website/`](./website/) (Docusaurus 3.10.2)

> See also: [AWS Kong Konnect catalog](https://catalog.workshops.aws/kong-konnect/en-US/00-what-is-kong-konnect)

## Purpose

Students build API Gateway and AI Proxy on **Konnect Serverless**, and call a shared LLM hub that the operator runs. Provider API keys stay with the operator.

## Layout

| Path | Role |
|---|---|
| [`website/`](./website/) | Student docs site (Docusaurus, ko/en) |
| [`terraform/`](./terraform/) | Operator shared LLM hub (EC2 Kong EE DB-less) |

## Audience

| Audience | Work | Docs |
|---|---|---|
| **Student** | Konnect Serverless + AI Proxy | [Site](https://great-stone-kong.github.io/kong-ai-gateway-workshop/) / [`website/docs`](./website/docs/) |
| **Operator** | Hub apply + packet distribution | [`terraform/README.md`](./terraform/README.md) |

## Student packet (operator distributes)

```bash
WORKSHOP_LLM_OPENAI_URL=http://<eip>:8000/openai
WORKSHOP_LLM_GEMINI_URL=http://<eip>:8000/gemini
WORKSHOP_LLM_BASE_URL=http://<eip>:8000
WORKSHOP_LLM_APIKEY=sk-kong-workshop
```

## Auth contract (summary)

| Hop | Mechanism |
|---|---|
| Konnect AI Proxy → hub | Header `apikey` + student key |
| Hub → OpenAI / Gemini | `Authorization: Bearer` + provider key (operator only) |

## Run the docs site locally

```bash
cd website
npm ci
npm start
```

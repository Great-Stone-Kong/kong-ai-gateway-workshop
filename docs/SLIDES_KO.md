# Kong AI Gateway 워크샵 — 슬라이드 개요

총 **~3.5–4시간 + 오프닝/개념/클로징**. 실습자는 Konnect Serverless, 운영자(Terraform 허브)는 인트로·개념·Scene 0·Scene 4 전환·클로징에만 짧게.

커리큘럼: [`README_KO.md`](./README_KO.md) · 상위 구조: [`../README_KO.md`](../README_KO.md)

---

## 권장 흐름

| 구간 | 시간 | 슬라이드 |
|---|---|---|
| **A. 오프닝** | ~10분 | 목표 · 아키텍처 1장 · 역할 분리 · Scene 타임라인 |
| **B. 개념 브리핑** | ~20–25분 | API Gateway · Entity · 플러그인 · AI Gateway · 인증 계약 |
| **C. Scene 0** | ~25분 | Konnect/Serverless · Proxy URL · `WORKSHOP_LLM_*` |
| **D. Scene 1** | ~25분 | Service/Route · httpbin · Upstream RR |
| **E. Scene 2** | ~25분 | 플러그인 스코프 · RL · Transformer · Termination · Header Route |
| **F. Scene 3** | ~25분 | Auth vs Authz · key-auth · OIDC · 비교 |
| **G. Scene 4** | ~45분 | Plain LLM → AI Proxy 전환 · Decorator/Guard/Token RL · ACL |
| **H. Scene 5** | ~30분 | Gemini target · RR · failover |
| **I. Scene 6** | ~25분 | Claude → Konnect → `/v1/messages` · Claude Code |
| **J. 클로징** | ~10분 | 정리 · 키 경계 · 다음 단계 |

---

## 섹션별 요지

### A. 오프닝 (개념)

- Konnect에서 Gateway·AI Proxy를 직접 구성. **공급자 키는 실습자 없음**.
- 한 장 다이어그램:

```text
실습자 → Konnect Serverless
  Scene 1–3: Service / Route / Plugin / Auth
  Scene 4–5: AI Proxy → 허브 /openai, /gemini
  Scene 6: Anthropic Messages → 허브 /v1/messages
운영자 → terraform/ (EC2 Kong EE DB-less 허브) → WORKSHOP_LLM_* 패킷
```

- 오늘 순서: **개념(B) → 환경(0) → Gateway 기본(1–3) → AI(4–6)**.

### B. 개념 브리핑 (개념만 · 실습 없음)

Scene 실습에 들어가기 전, 공통 언어를 맞춘다. Academy **KGLL-101**, **KGLL-234**, **KGLL-206** 요지.

#### B1. Kong API Gateway란

- API / 마이크로서비스 앞단의 **중앙 진입점**: 라우팅, 인증·인가, 제한, 변환, 관측.
- 클라이언트가 upstream을 직접 알 필요 없음 → Gateway가 정책을 적용한 뒤 전달.
- **Control Plane vs Data Plane**
  - CP: 설정·관리 (Konnect UI / Admin API / decK)
  - DP: 실제 트래픽 처리 (이 워크샵 = **Serverless** hosted DP)
- Konnect: CP는 클라우드, DP는 Serverless / Dedicated / Hybrid 중 선택. 오늘은 Serverless.

#### B2. 요청이 흐르는 방식

```text
Client → Route(매칭) → Plugins → Service → (Upstream/Targets) → Backend
```

- **Route**: 어떤 요청을 받을지 (path, host, header, method…).
- **Service**: 어디로 보낼지 (upstream URL / host).
- **Strip path**: Route path를 upstream에 넘길지 여부 — Scene 1·4·6에서 의식적으로 설정.

#### B3. 핵심 Entity

| Entity | 한 줄 | 이 워크샵에서 |
|---|---|---|
| **Service** | Upstream을 가리키는 논리 서비스 | httpbin, LLM plain, AI routes |
| **Route** | Client 진입 규칙 | `/test`, `/ai/openai`, `/v1/messages`… |
| **Upstream** | 로드밸런싱 단위 | Scene 1 Target RR |
| **Target** | Upstream의 실제 호스트:포트 | httpbin.org / konghq |
| **Consumer** | API 호출 주체(앱·사용자) | Scene 3·4 key-auth |
| **Plugin** | 교차 관심사(인증, RL, 변환, AI…) | Scene 2–6 |
| **Credential** | Consumer의 비밀(키, OAuth…) | `apikey`, OIDC |

슬라이드 한 장: Entity 관계도 (Consumer ↔ Plugin ↔ Route/Service ↔ Upstream ↔ Target).

#### B4. 플러그인 모델

- 부착 위치(스코프): **Consumer / Route / Service / Global**.
- 요청·응답 경로에서 체인으로 실행 → **순서가 동작에 영향** (Scene 4에서 다시 강조).
- 대표 카테고리 (오늘은 이 중만 실습):
  - Traffic: Rate Limiting (Advanced), Request Termination
  - Transformations: Request/Response Transformer
  - Security: key-auth, ACL, OIDC
  - AI: AI Proxy Advanced, Prompt Guard/Decorator, AI Rate Limiting

#### B5. Kong AI Gateway란

- **일반 API Gateway + LLM 인식 계층**.
- Plain Service만으로도 LLM HTTP는 가능 (Scene 4 Lab 1) — 한계:
  - 클라이언트가 upstream 키/`apikey`를 알아야 함
  - 모델·route_type·포맷 변환·프롬프트 정책·토큰 단위 RL·멀티 모델 LB가 Gateway에 없음
- **AI Proxy / AI Proxy Advanced**가 하는 일:
  - LLM provider·모델·`upstream_url` 지정
  - 인증 헤더 **주입** (실습자 키 ≠ 공급자 키)
  - `llm_format` (openai / anthropic …) · `route_type` (`llm/v1/chat` …)
  - target 여러 개 → RR / priority failover (Scene 5)
- AI 전용 정책 플러그인: Prompt Decorator, Prompt Guard, AI Rate Limiting(토큰), (언급만) Semantic Cache / Analytics

#### B6. 오늘 쓰는 인증 계약 (한 장으로 고정)

| 구간 | 방식 | 누가 앎 |
|---|---|---|
| Client → Konnect | (Scene에 따라) 없음 / Consumer `apikey` / OIDC | 실습자 |
| Konnect AI Proxy → Workshop 허브 | 헤더 `apikey` + 패킷 키 | 실습자 패킷 · Gateway에 주입 |
| 허브 → OpenAI / Gemini | `Authorization: Bearer` | **운영자만** |

Scene 6: Client(Claude)는 Anthropic Messages 포맷, Konnect는 `provider: anthropic` + `llm_format: anthropic`으로 허브 `/v1/messages`에 전달.

#### B7. 개념 → Scene 매핑 (한 장)

| 개념 | Scene |
|---|---|
| Service / Route / Upstream | 1 |
| Plugin 스코프 · RL · Transformer | 2 |
| Consumer · key-auth · OIDC | 3 |
| Plain vs AI Proxy · AI 정책 | 4 |
| Multi-target · balancer | 5 |
| Native LLM format · Claude Code | 6 |

---

### C. Scene 0 — 실습 위주

- Org 생성, US 리전, Serverless CP 확인.
- Proxy URL → `no Route matched`면 준비 완료.
- 강사 패킷: `WORKSHOP_LLM_OPENAI_URL` / `GEMINI_URL` / `BASE_URL` / `APIKEY`.
- (운영자 1장) 허브는 이미 기동됨. 실습자는 URL·키만 사용.

### D. Scene 1 — 개념 복습 1장 + 실습

- B2–B3 복습: Client → Route → Service → Backend. Strip path.
- 실습: Service `httpbin` → Route `/test`, Proxy 호출, `X-Kong-*` / `X-Forwarded-*` 확인.
- Upstream + Target 2개(RR), Service host를 Upstream 이름으로 교체.

### E. Scene 2 — 개념 복습 1장 + 실습

- B4 복습: Plugin 스코프.
- Rate Limiting Advanced → 429, `X-RateLimit-*`.
- Response Transformer · Request Termination · Header 조건 Route.

### F. Scene 3 — 개념 복습 1장 + 실습

- Auth(인증) vs Authz(인가) — Academy **KGLL-234**.
- Consumer + key-auth (`apikey`) → 401/200.
- Route `/oidc`: client_credentials + OIDC Bearer 검증 — Academy **KGLL-206**.
- 메시지: upstream 비밀 없이 게이트웨이에서 신원 증명.

### G. Scene 4 — 전환 포인트 (B5를 실습으로 증명)

1. Plain `/ai/plain`으로 허브 호출(클라이언트가 `apikey` 직접) — “Gateway만으로도 LLM HTTP는 된다”.
2. Plain 한계 → AI Proxy 필요성 (B5 재소환).
3. AI Proxy Advanced가 `apikey` 주입, 클라이언트는 chat body만.
4. Decorator → Guard → AI Token RL → key-auth + ACL.
5. **클라이언트 키 ≠ 허브 주입 키**.
6. 권장 플러그인 순서: key-auth → ACL → Guard → Decorator → AI RL → AI Proxy Advanced.

### H. Scene 5 — 실습 위주

- 기존 AI Proxy Advanced에 Gemini target 추가.
- RR: 응답 `model`로 OpenAI vs Gemini 구분.
- Priority + failover → OpenAI를 깨뜨린 뒤 Gemini로 전환 → 복구.

### I. Scene 6 — 개념 1장 + 실습

- Claude Code → Konnect (`provider: anthropic`, `llm_format: anthropic`) → 허브 `/v1/messages` → OpenAI.
- Service = 허브 base, Route `/v1/messages`, Strip path **OFF**, `upstream_url` = `.../v1/messages`.
- curl 검증 후 `ANTHROPIC_BASE_URL=$KONNECT_PROXY_URL`로 Claude Code.
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS=16384` (허브 OpenAI 완료 토큰 한도).

### J. 클로징 (개념)

- Entity → Plugin → AI Proxy → 멀티 공급자 → 개발도구(Claude).
- B6 인증 계약 다시 한 장.
- 운영자 destroy / 실습자 org 정리(짧게).

---

## Academy → 슬라이드 매핑

| Academy | 사용 | 붙이는 곳 |
|---|---|---|
| **KGLL-101** Services/Routes/Plugins/Consumers | Entity·RL·key-auth·Caching 언급 | **B3–B4**, D, E, F, G |
| **KGLL-234** Securing API (KIC) | Auth vs Authz, Key Auth, RL | **B6**, F, G |
| **KGLL-206** OIDC Plugin | issuer/audience, Client Credentials | F |
| **KGLL-236** Traffic Management | Request/Response Transformer | E |
| **KGLL-106** Canary | Service 정의, 트래픽 분할 **비유만** | B3, H (Canary lab 없음) |
| **KDLL-218** / **KGLL-103** Logging | Gateway 관측 **한 줄** | B1 / J (file-log lab 없음) |

**제외:** Mesh(`KMLL-*`), KIC 설치(231–233), mTLS, OTel — 이번 워크샵 범위 밖.

---

## 실습 vs 개념

| | 개념 | 실습 |
|---|---|---|
| A, **B**, J | 목표·Gateway/AI/Entity·정리 | — |
| C–F, H–I | Scene 시작 1장(B 복습) | 나머지 UI 따라하기 |
| **G (Scene 4)** | Plain→AI Proxy 전환을 길게 | `/ai/plain` → AI Proxy → 정책 체인 |

발표 팁: **B는 화이트보드/다이어그램 위주**, Scene마다 “방금 B에서 본 X를 UI로 만든다”로 연결.

---

## 운영자 vs 실습자

| 시점 | 실습자 | 운영자(짧게) |
|---|---|---|
| A–B | 아키텍처·계약 이해 | 허브가 패킷 URL 뒤의 실체임을 1장 |
| C | 패킷 붙여넣기 | 허브 기동 완료 · 패킷만 배포 |
| D–F | 본인 Serverless만 | 등장 없음 |
| G–H | upstream = 패킷 URL | “허브가 Bearer 붙인다” 1장 |
| I | anthropic AI Proxy + Claude | `/v1/messages` 변환은 허브 내부(비공개) |
| J | CP 정리 | destroy / 키 회수 |

**말하지 않을 것:** 허브 `kong.yml` 상세, 공급자 키 값, 실습자 Terraform.

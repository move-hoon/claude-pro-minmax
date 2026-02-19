> **[English Version](README.md)**

# Commands Directory

## 목적
일반적인 워크플로우를 위한 슬래시 커맨드(slash command) 정의를 포함합니다.

> **경로 안내:** 명령어/에이전트 프롬프트에는 설치 경로(`~/.claude/...`)가 사용됩니다. 이 저장소의 소스 경로는 `./.claude/...`, `./scripts/...`입니다.

## 내용

| 커맨드 | 목적 | 주요 기능 |
|---------|---------|-------------|
| `do.md` | 배치 실행 | 원자적 plan+build+verify 한 번에 처리, 실패 시 롤백 |
| `do-sonnet.md` | Sonnet으로 실행 | context: fork, model: sonnet |
| `do-opus.md` | Opus로 실행 | context: fork, model: opus |
| `plan.md` | 복잡한 작업 | @planner → @builder 체인 |
| `dplan.md` | 심층 계획 | @dplanner (Sequential Thinking + Perplexity + Context7) |
| `review.md` | 코드 검토 | 읽기 전용, 카테고리 |
| `learn.md` | 패턴 캡처 | 자동 추출 또는 명시적 지정 |
| `session-save.md` | 상태 저장 | 비밀 정보 삭제 |
| `session-load.md` | 작업 재개 | 컨텍스트 복원 |
| `load-context.md` | 컨텍스트 로드 | Read tool, 비용 경제 |
| `compact-phase.md` | 전략적 축소 | 단계 인식 가지치기 |
| `watch.md` | tmux 모니터링 | 메시지 비용 없음 |
| `llms-txt.md` | LLM 최적화 문서 | URL에서 /llms.txt 조회 |
| `analyze-failures.md` | 도구 오류 분석 | 하이브리드 학습 (로그 + 분석) |

## 명령어 카테고리

### 실행 명령어
| 명령어 | 사용 시점 | 리소스 사용량 |
|---------|-------------|--------------|
| `/do` | 단순~중간 작업 (1-3 파일). 원자적 배치 실행, 실패 시 롤백 | 최소 (세션 모델) |
| `/do-sonnet` | 깊은 추론이 필요한 복잡한 로직 | 중간 (Sonnet 4.6) |
| `/do-opus` | 중요한 결정, Sonnet 실패 시 | 높음 (Opus 4.6—API 가격이 비용 반영) |
| `/plan` | 다중 파일 작업, 아키텍처 결정 | 중간 (Sonnet 4.6 → Haiku 4.5 체인) |
| `/dplan` | 연구가 많은 복잡한 아키텍처 | 높음 (Sonnet 4.6 + MCP 도구) |

### 품질 보증
| 명령어 | 사용 시점 | 리소스 사용량 |
|---------|-------------|--------------|
| `/review` | 구현 후 품질 체크 | 최소 (Haiku 4.5, 읽기 전용) |

### 세션 관리
| 명령어 | 사용 시점 | 리소스 사용량 |
|---------|-------------|--------------|
| `/session-save` | 나중을 위한 작업 요약 저장 | 로컬 스크립트 (API 사용 안 함) |
| `/session-load` | 이전 작업 재개 | 최소 (컨텍스트용 Read tool) |

### 컨텍스트 관리
| 명령어 | 사용 시점 | 리소스 사용량 |
|---------|-------------|--------------|
| `/load-context` | 프로젝트 컨텍스트 템플릿 로드 | 최소 (Read tool) |
| `/compact-phase` | 전략적 컨텍스트 압축 | 안내만 (실행 없음) |

### 학습 및 분석
| 명령어 | 사용 시점 | 리소스 사용량 |
|---------|-------------|--------------|
| `/learn` | 향후 참조를 위한 패턴 캡처 | 최소 (learned/에 Write) |
| `/analyze-failures` | 축적된 도구 실패 분석 | 중간 (LLM 분석 필요) |

### 유틸리티
| 명령어 | 사용 시점 | 리소스 사용량 |
|---------|-------------|--------------|
| `/watch` | 장기 실행 프로세스 모니터링 | 로컬 tmux (API 사용 안 함) |
| `/llms-txt` | LLM 최적화 문서 조회 | 최소 (WebFetch) |

## 워크플로우 예시

### 간단한 기능 구현
```bash
# 1. 명확히 정의된 간단한 작업은 직접 실행
/do CRUD 기능이 있는 사용자 서비스 생성

# 2. 구현 후 검토
/review src/services/user-service.ts
```
**Quota:** 낮음 (세션 모델 실행 + Haiku 4.5 검토)

### 복잡한 기능 구현
```bash
# 1. 먼저 아키텍처 계획
/plan 리프레시 토큰과 함께 JWT 인증 추가

# 2. Planner 설계 → Builder 구현 → 자동 검토
# (에이전트 체인이 자동으로 처리)

# 3. 필요 시 수동 검토
/review src/auth/
```
**Quota:** 중간 (Sonnet 4.6 계획 + Haiku 4.5 구현 + Haiku 4.5 검토)

### 연구 중심 아키텍처
```bash
# 1. 연구 도구를 사용한 심층 계획
/dplan 우리 사용 사례에서 이벤트 소싱과 CQRS의 트레이드오프 분석

# 2. 연구 후 관련 컨텍스트 로드
/load-context backend

# 3. 연구 결과를 바탕으로 구현
# (복잡도에 따라 /plan 또는 /do 사용)
```
**Quota:** 높음 (Sonnet 4.6 + Sequential Thinking + Perplexity + Context7)

### 디버깅 및 학습
```bash
# 1. 최근 실패 분석
/analyze-failures 50

# 2. 패턴 추출 및 학습된 스킬 생성
/learn "유니온 타입 속성 접근 전 타입 가드 사용"

# 3. 학습된 패턴 확인
/learn --show
```
**Quota:** 중간 (실패 로그 LLM 분석)

### 긴 세션 관리
```bash
# 1. 이전 컨텍스트 로드
/session-load auth-feature

# 2. 작업 수행...

# 3. 휴식 전 진행 상황 저장
/session-save auth-feature-v2

# 4. 전략적으로 컨텍스트 압축
/compact-phase implementation
```
**Quota:** 낮음 (대부분 스크립트 기반 작업)

## 명령어 비교

### 실행: /do vs /do-sonnet vs /do-opus vs /plan vs /dplan

| 측면 | /do | /do-sonnet | /do-opus | /plan | /dplan |
|--------|-----|------------|----------|-------|--------|
| **모델** | 세션 모델 | Sonnet 4.6 | Opus 4.6 | Sonnet 4.6 → Haiku 4.5 | Sonnet 4.6 + MCP |
| **상대 비용** | 낮음 | 중간 | 높음 | 중상 | 최고 |
| **계획** | 내부 (배치) | 내부 (배치) | 내부 (배치) | 아키텍처 설계 | 심층 연구 |
| **사용 사례** | 간단한 작업 | 복잡한 로직 | 중요한 결정 | 다중 파일 기능 | 미지의 영역 |
| **영향받는 파일** | 1-3 | 1-3 | 제한없음 | 5+ | 제한없음 |
| **질문** | 불가 | 불가 | 불가 | ≤3 (기본값 포함) | 무제한 |
| **연구 도구** | 불가 | 불가 | 불가 | 불가 | 가능 (Perplexity, Context7) |

**결정 트리:**
```
작업 복잡도
├─ 간단함 (1-3 파일, 명확한 요구사항)
│   └─→ /do
│
├─ 중간 (4-5 파일, 약간의 복잡도)
│   ├─ 로직 중심 → /do-sonnet
│   └─ 다중 파일 → /plan
│
└─ 복잡함 (5+ 파일, 불명확한 접근)
    ├─ 알려진 도메인 → /plan
    ├─ 연구 필요 → /dplan
    └─ 중요/Sonnet 실패 → /do-opus
```

### 컨텍스트: /session-save vs /load-context

| 측면 | /session-save | /load-context |
|--------|---------------|---------------|
| **목적** | 전체 세션 상태 저장 | 사전 정의된 템플릿 로드 |
| **내용** | 작업 이력, 결정, 코드 | 프로젝트 구조, 컨벤션 |
| **범위** | 세션 특정 | 프로젝트 전역 패턴 |
| **시점** | 작업 세션 종료 시 | 새 작업 시작 시 |
| **형식** | 마크다운 요약 | 구조화된 컨텍스트 파일 |

**함께 사용:**
```bash
# 하루 시작
/session-load yesterday-work     # 어제 작업 재개
/load-context backend             # 프로젝트 컨벤션 로드

# 하루 종료
/session-save today-progress      # 내일을 위해 저장
```

## 모범 사례

### 1. 올바른 실행 명령어 선택

**`/do` 사용 시점:**
- 명확한 요구사항이 있는 잘 정의된 작업
- 1-3개 파일에만 영향
- 아키텍처 결정 불필요
- 예: "사용자 입력에 유효성 검사 추가"

**`/plan` 사용 시점:**
- 5개 이상 파일에 영향
- 아키텍처 결정 필요
- 요구사항 명확화 필요
- 예: "멀티 테넌트 지원 추가"

**`/dplan` 사용 시점:**
- 알려지지 않은 기술이나 패턴
- 여러 접근 방식 평가 필요
- 복잡한 경쟁 상태 디버깅
- 예: "분산 트랜잭션 처리 설계"

**`/do-opus` 사용 시점:**
- 중요한 작업 (프로덕션 핫픽스)
- Sonnet이 2회 재시도 후 실패
- 최대 추론 능력 필요
- 예: "프로덕션 메모리 누수 수정"

### 2. 전략적 컨텍스트 관리

**조기에 자주 압축:**
```bash
# 계획 단계 후
/compact-phase planning

# 구현 후
/compact-phase implementation

# 검토 후
/compact-phase review
```

**선택적으로 컨텍스트 로드:**
```bash
# 한 번에 모든 것을 로드하지 마세요
/load-context backend     # ✓ 필요한 것만 로드
/load-context frontend    # ✗ 필요하지 않으면 로드 안 함
```

### 3. 실패로부터 학습

**정기적으로 실패 분석:**
```bash
# 주간 분석
/analyze-failures 100

# 어려운 디버깅 세션 후
/analyze-failures 20
```

**즉시 패턴 캡처:**
```bash
# 까다로운 이슈 해결 직후
/learn "취소 가능한 fetch 요청에 AbortController 사용"
```

### 4. 세션 관리

**자연스러운 중단점에서 저장:**
- 작업 세션 종료
- 작업 전환 전
- 주요 마일스톤 후
- 실험적 변경 전

**재개 시 로드:**
- 작업 세션 시작
- 이전 작업으로 다시 전환
- 과거 작업의 컨텍스트 필요 시

### 5. Pro Plan 최적화

**고비용 명령어 최소화:**
- 가능하면 `/plan` 대신 `/do` 사용
- 가능하면 `/do-opus` 대신 `/do-sonnet` 사용
- 연구가 중요하지 않으면 `/dplan` 대신 `/plan` 사용

**작업 일괄 처리:**
```bash
# ✗ 여러 개의 /do 호출
/do 사용자 모델 생성
/do 사용자 컨트롤러 생성
/do 사용자 테스트 생성

# ✓ 단일 /plan 호출
/plan 모델, 컨트롤러, 테스트가 있는 사용자 모듈 생성
```

**비용 0 도구 사용:**
- `/session-save`, `/session-load` (스크립트 기반)
- `/watch` (tmux 기반)
- `/compact-phase` (안내만 제공)

## 사용 예시

```bash
# 직접 실행 (간단한 작업)
/do 사용자 서비스 생성
/do-sonnet 복잡한 캐싱 로직 구현

# 복잡한 작업 (계획 필요)
/plan JWT를 사용한 사용자 인증 추가
/dplan 트랜잭션 매니저의 잠재적 데드락 분석

# 코드 검토
/review src/auth/
/review --security

# 학습
/learn "항상 유효성 검사에 zod 사용"
/learn --show
/analyze-failures 50

# 세션
/session-save auth-feature
/session-load

# 컨텍스트
/load-context backend
/load-context frontend

# 단계
/compact-phase implementation
/watch tests
/llms-txt https://docs.example.com
```

## 설계 결정

| 결정 | 근거 |
|------|------|
| `/do-sonnet`과 `/do-opus`를 별도 커맨드로 분리 | Frontmatter `model:` 필드는 `context: fork`와 함께만 동작함. 의도한 서브에이전트 모델로 라우팅하려면 별도 커맨드가 필요 |
| `/plan`은 `agent: planner`, `/review`는 `agent: reviewer` 사용 | 이 커맨드들은 특정 도구 제한이 필요함. `planner`는 읽기 전용(Write/Edit 불가). `reviewer`도 읽기 전용. `agent:` 필드가 해당 에이전트의 tools/permissions를 적용 |
| `/load-context`의 `disable-model-invocation: false` | Claude가 이 커맨드를 자동 호출할 수 있으려면 `false`여야 함. `true`면 Read tool로 컨텍스트 파일 로드 불가 |
| `/compact-phase`는 안내만 제공 | Claude Code의 `/compact`는 사용자 입력 필요. 이 커맨드는 단계별 프롬프트를 복사-붙여넣기 할 수 있도록 안내 |

## 커스텀 커맨드 추가

새로운 `.md` 파일을 **frontmatter**와 함께 생성하세요 (공식 문서 준수 필수):

```markdown
---
name: your-command
description: 이 커맨드가 하는 일과 언제 사용하는지
argument-hint: [필수-인자] or --flag [선택]
disable-model-invocation: true
---

# /your-command 커맨드

## 목적
이 커맨드가 하는 일.

## 입력
$ARGUMENTS

## 실행
1. 1단계
2. 2단계

## 출력
\`\`\`
예상 출력 형식
\`\`\`

## 예시
\`\`\`bash
/your-command example
\`\`\`
```

### Frontmatter 필드

| 필드 | 필수 | 설명 |
|------|:----:|------|
| `name` | 예 | 커맨드 이름 (소문자, 하이픈) |
| `description` | 예 | 언제 사용하는지 (Claude 자동 호출 판단용) |
| `argument-hint` | 아니오 | 자동완성에 표시 |
| `disable-model-invocation` | 아니오 | `true` = 수동만, `false` = Claude 자동 호출 허용 |
| `allowed-tools` | 아니오 | 도구 제한 (예: `Read, Grep`) |
| `model` | 아니오 | 모델 강제 (`sonnet`, `haiku`, `opus`) |
| `context` | 아니오 | `fork` = 서브에이전트 컨텍스트에서 실행 |
| `agent` | 아니오 | `context: fork` 시 서브에이전트 유형 (예: `planner`, `reviewer`) |
| `hooks` | 아니오 | 라이프사이클 훅 (`PreToolUse`, `PostToolUse`, `Stop`) |

### 위치
- 전역: `~/.claude/commands/` (모든 프로젝트)
- 프로젝트: `./.claude/commands/` (이 프로젝트만)

> **[English Version](README.md)**

# Contexts Directory

## 목적
지연 로딩(lazy loading)을 위한 **프로젝트 참조 데이터**를 포함합니다. 이 파일들은 자동으로 로드되지 **않으며**, 필요할 때 `/load-context`를 사용하여 로드해야 합니다.

컨텍스트 파일은 고정된 프로젝트 정보(API 엔드포인트, DB 스키마, 환경 변수)입니다. 진행 중인 작업 상태를 추적하는 세션과 다릅니다.

| | Contexts | Sessions |
|--|----------|----------|
| **성격** | 고정된 프로젝트 참조 데이터 | 진행 중인 작업 상태 |
| **변경 빈도** | 프로젝트 구조 변경 시만 | 매 세션마다 |
| **예시** | API 엔드포인트, DB 스키마, 환경 변수 | 진행 상황, 결정 사항, 다음 작업 |
| **저장 필요** | 없음 (파일 자체가 이미 저장됨) | 있음 (매번 `/session-save`) |

## 내용

| 파일 | 목적 | 로드 시점 |
|------|---------|--------------|
| `backend-context.md` | API 엔드포인트, DB 스키마, 환경 변수 | 백엔드 개발 시 |
| `frontend-context.md` | 컴포넌트, 상태, 라우트 | 프론트엔드 개발 시 |

## 사용법

```bash
# 작업을 시작할 때 로드
/load-context backend

# 사용 가능한 컨텍스트 확인
/load-context --list

# 다른 작업으로 전환
/load-context frontend
```

## 왜 지연 로딩인가요?

1. **프롬프트 캐시 효율성:** CLAUDE.md가 불변 상태로 유지되어 캐시 적중률 극대화
2. **비용 경제:** 필요한 것만 로드 (Pro Plan: 모든 메시지 = 쿼터)
3. **집중된 컨텍스트:** 백엔드 작업 중 프론트엔드 스키마 로드 방지

## Instruction Hierarchy (지시 우선순위)

> **중요:** `/load-context`는 Read tool을 사용하므로 **tool output 레벨** — Claude의 지시 우선순위에서 가장 낮은 수준으로 로드됩니다.

```
System prompt (최고)  ← CLAUDE.md, rules/, --system-prompt
User messages         ← 사용자 프롬프트
Tool output (최저)    ← /load-context, @file, Read tool
```

**의미:**
- 컨텍스트 파일은 Claude가 참고하는 **참조 데이터** — tool output 레벨로 충분
- Claude가 **반드시 따라야 할 규칙** → `.claude/rules/`에 넣으세요 (자동 로드, system prompt 레벨)
- 고급: `claude --system-prompt "$(cat context.md)"`로 system prompt 레벨 주입 가능

**대안 — CLAUDE.md에서 `@import`:**
```markdown
# CLAUDE.md 안에서
- @.claude/contexts/backend-context.md
```
이렇게 하면 system prompt 레벨로 로드되지만, **매 세션마다** 로드됩니다 (지연 로딩 아님). 항상 필요한 컨텍스트에만 사용.

## 템플릿

```markdown
# [Project] Context

## 기술 스택
- Runtime: [...]
- Framework: [...]
- Database: [...]

## API 엔드포인트
| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| ... | ... | ... | ... | ... |

## 주요 정보
- ...

## 최근 변경 사항
- [date]: [change]
```

## 모범 사례

1. 컨텍스트 파일은 100줄 이내로 유지
2. 주요 변경 사항 후 업데이트
3. 비밀 정보 포함 금지 (어차피 삭제됨)
4. Claude가 알아야 할 **참조 데이터**에 집중
5. **행동 규칙**은 `.claude/rules/`에 넣기 — 더 높은 지시 우선순위
6. 세션당 2개 이상의 컨텍스트 로드 지양

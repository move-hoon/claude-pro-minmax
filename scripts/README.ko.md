> **[English Version](README.md)**

# Scripts Directory

## 목적
"프롬프트"로 처리하는 것이 아니라 "코드"로 처리해야 하는 작업을 위한 결정론적 스크립트를 포함합니다.

**철학:** "코드로 할 수 있는 것을 프롬프트하지 마세요."

## 유니버설 스크립트

| 스크립트 | 목적 | 이점 |
|--------|---------|---------|
| `verify.sh` | 런타임 적응형 검증 (빌드+테스트+린트) | 결정론적 실행, 프롬프팅 불필요 |
| `build.sh` | 런타임 적응형 빌드 | 런타임 자동 감지, 모델 추측 제거 |
| `test.sh` | 런타임 적응형 테스트 | 직접 실행, 100% 정확도 |
| `lint.sh` | 런타임 적응형 린트 | 로컬 처리, 즉각적 결과 |

## 런타임 감지 레이어

```
runtime/
├── detect.sh         # 프로젝트 런타임 자동 감지 (JSON 출력)
└── adapters/
    ├── _interface.sh # 어댑터 계약 정의
    ├── jvm.sh        # Java/Kotlin (Gradle/Maven)
    ├── node.sh       # TypeScript/JS (npm/pnpm/yarn/bun)
    ├── go.sh         # Go 모듈
    ├── rust.sh       # Cargo
    ├── python.sh     # pip/poetry/uv
    ├── generic.sh    # Makefile 폴백
    └── _template.sh  # 새 어댑터용 템플릿
```

## 유틸리티 스크립트

| 스크립트 | 목적 | 이점 |
|--------|---------|---------|
| `scrub-secrets.js` | 텍스트에서 비밀 정보 제거 | 보안 + 토큰 노출 방지 |
| `analyze-failures.sh` | 도구 실패 로그 분석 및 패턴 추출 | LLM 분석 전 로그 전처리 |
| `create-branch.sh` | 결정론적 브랜치 생성 | 일관된 명명, 추측 불필요 |
| `commit.sh` | Conventional Commit 형식 | 컨벤션 자동 적용 |
| `snapshot.sh` | `/do` 명령의 원자적 롤백 | 결정론적 `git stash` + depth guard + 라벨 안전장치 |

## Hooks 디렉토리

| Hook 스크립트 | 이벤트 | 목적 | 실행 비용 |
|-------------|-------|---------|------------|
| `hooks/critical-action-check.sh` | PreToolUse | 위험한 명령 차단 | 로컬 (무료), 차단 시 메시지 |
| `hooks/post-edit-format.sh` | PostToolUse | 편집된 파일 자동 포맷 | 로컬 (무료) |
| `hooks/compact-suggest.sh` | PostToolUse | 3단계 컴팩션 경고 (25 권고 / 50 경고 / 75 위험) | 로컬 (무료), 티어당 ~30 토큰 |
| `hooks/notification.sh` | Notification | 데스크톱 알림 | 로컬 (무료) |
| `hooks/session-start.sh` | SessionStart | 환경변수 설정 + 예산 알림 + 세션 알림 | 로컬 (무료), 예산 컨텍스트 ~40 입력 토큰 |
| `hooks/session-cleanup.sh` | SessionEnd | 세션에서 비밀 정보 제거 | 로컬 (무료) |
| `hooks/retry-check.sh` | Stop | 연속 2회 실패 시 차단 (builder) | 로컬 (무료), 에스컬레이션 메시지 |
| `hooks/readonly-check.sh` | PreToolUse | 읽기 전용 (reviewer) | 로컬 (무료), 차단 시 메시지 |
| `hooks/tool-failure-log.sh` | PostToolUseFailure | 도구 실패 로깅 | 로컬 (무료) |

**비용 설명:** 모든 Hook은 로컬에서 실행되어 API 호출이 없습니다. Hook이 Claude에게 메시지를 표시할 때만(예: 명령 차단, 컴팩션 제안) 해당 메시지가 입력 토큰을 소비하며, 이러한 메시지는 의도적으로 간결합니다.

## scrub-secrets.js

**목적:** 15개 이상의 비밀 패턴을 스캔하고 교체합니다.

**사용법:**
```bash
# 입력 파이프
cat session.md | node scrub-secrets.js > clean.md

# /session-save에 의해 자동으로 사용됨
```

**감지된 패턴:**
- OpenAI, Anthropic, Stripe, GitHub, AWS 키
- 자격 증명이 포함된 데이터베이스 URL
- JWT 토큰
- 비밀번호/비밀 필드
- 개인 키 (PEM)

## create-branch.sh

**목적:** 결정론적 브랜치 명명.

**사용법:**
```bash
./create-branch.sh feature user-profile
# 생성: feature/user-profile

./create-branch.sh fix login-bug
# 생성: fix/login-bug
```

**유형:** feature, fix, hotfix, refactor, chore

## analyze-failures.sh

**목적:** 축적된 도구 실패 로그를 분석하고 반복되는 패턴을 추출합니다.

**사용법:**
```bash
# 최근 50개 실패 분석
./analyze-failures.sh 50

# /analyze-failures 명령어에 의해 사용됨
# LLM 분석 전 로그 전처리
```

**출력:** LLM 분석을 위해 포맷된 실패 요약

## commit.sh

**목적:** Conventional Commit 형식 지정.

**사용법:**
```bash
./commit.sh feat auth "add JWT refresh tokens"
# 커밋: feat(auth): add JWT refresh tokens
```

**유형:** feat, fix, docs, style, refactor, perf, test, chore

## 왜 스크립트인가요?

| 접근 방식 | 실행 비용 | 정확도 | 속도 |
|----------|----------|----------|-------|
| Claude 프롬프트 | Quota 소비 | 모델 의존적 | API 왕복 필요 |
| 쉘 스크립트 | 로컬 (무료) | 결정론적 (100%) | 즉시 |

**장점:** 스크립트는 결정론적 작업을 quota 소비 없이 로컬에서 처리하여, Claude가 창의적/추론 작업에 집중할 수 있게 합니다.

## 커스텀 스크립트 추가

```bash
#!/bin/bash
# my-script.sh - Description

set -e  # 오류 발생 시 종료

# 여기에 결정론적 로직 작성
```

실행 가능하게 만들기:
```bash
chmod +x ~/.claude/scripts/my-script.sh
```

# CPMM 사용자 가이드 (설치 후 운영)

이 문서는 `README.ko.md`를 이미 읽고 설치를 끝낸 사용자를 위한 운영 가이드입니다.
설명보다 실행에 집중합니다: 무엇을, 언제, 어떻게 실행할지.

## 0. 운영 계약 (한 번만 읽기)

- 한 작업에는 하나의 주 실행 커맨드를 둡니다.
- 작업 프롬프트에는 범위 + 제약 + 완료조건을 같이 적습니다.
- 매 실행 후 다음 커맨드를 즉시 결정합니다. 모호한 상태로 멈추지 않습니다.

결과 판정:
- `/review` 결과는 `PASS` 또는 `FAIL`입니다.  
  `PASS`면 진행, `FAIL`이면 수정 후 변경 경로 기준으로 재리뷰합니다.
- `/do`의 `반복 실패`는 1차 실패 + 2차 실패(재시도 소진)를 뜻하며, 검증 실패도 포함됩니다.
- 에스컬레이션은 자동이 아니라 수동입니다. CPMM은 실패 시 다음 커맨드(`/do-sonnet`, `/plan`)를 제안하지만 자동 전환하지 않습니다.
- `/do`가 반복 실패하면 `/do-sonnet`, 그래도 막히면 필요한 경우에만 `/do-opus`로 승격합니다.
- 중요 작업 확인 프롬프트가 뜨면 의도적으로 확인하거나 즉시 중단합니다.

## 1. 새 세션 시작 2분 체크리스트

1. 프로젝트 루트로 이동합니다.
2. 기본 모델을 설정합니다.
   ```bash
   /model haiku
   ```
3. (선택) 필요한 컨텍스트만 로드합니다.
   ```bash
   /load-context --list
   /load-context backend
   ```
4. 첫 작업은 `/do`로 시작합니다.

## 2. 10초 커맨드 선택표

| 상황 | 사용할 커맨드 | 예시 |
|---|---|---|
| 작고 명확한 작업 (1-3 파일) | `/do` | `/do Fix null check in user service and add minimal test.` |
| 여러 파일 기능 (4+ 파일) 또는 구조 판단 필요 | `/plan` | `/plan Add JWT refresh flow with rotation.` |
| 구현 없이 설계안만 필요 | `/plan --no-build` | `/plan --no-build Propose DB migration strategy for billing.` |
| 심층 조사 필요 (Sequential Thinking + Perplexity + Context7) | `/dplan` | `/dplan Analyze race conditions in payment retries.` |
| `/do`가 복잡 로직에서 반복 실패 | `/do-sonnet` | `/do-sonnet Implement conflict-safe cache invalidation.` |
| Sonnet도 막히거나 매우 중요한 결정 | `/do-opus` | `/do-opus Resolve deadlock risk in transaction coordinator.` |
| 머지 전 코드 점검 | `/review` | `/review src/auth/` |
| 보안 중심 점검 | `/review --security` | `/review --security src/auth/` |
| 작업 중단 전 상태 저장 | `/session-save` | `/session-save auth-refresh` |
| 이름 지정하여 이전 작업 재개 | `/session-load` | `/session-load auth-refresh` |
| 인자 없이 최근 세션 재개 | `/session-load` | `/session-load` |
| 로드 전 저장 세션 목록 확인 | `/session-load --list` | `/session-load --list` |
| 단계 전환 시 컨텍스트 정리 안내 받기 | `/compact-phase` | `/compact-phase implementation` |
| 심층 계획 후 컨텍스트 정리 | `/compact-phase deep-planning` | `/compact-phase deep-planning` |
| 테스트/빌드 장기 모니터링 | `/watch` | `/watch tests` |
| 사용자 지정 장기 명령 모니터링 | `/watch custom` | `/watch custom \"pnpm test:e2e --watch\"` |
| 컨텍스트 템플릿 로드 (≤2개 권장) | `/load-context` | `/load-context backend` |
| 저장된 세션 컨텍스트 로드 | `/load-context session` | `/load-context session` |
| 세션 자동 분석으로 패턴 추출 | `/learn` | `/learn` |
| 특정 패턴 직접 저장 | `/learn` | `/learn "Use DTO mappers for API responses"` |
| 저장된 패턴 목록 확인 | `/learn --show` | `/learn --show` |
| 도구 실패 패턴 분석 (기본: 최근 50건) | `/analyze-failures` | `/analyze-failures 100` |
| llms.txt 문서 조회 (Context7 미지원 시 보조) | `/llms-txt` | `/llms-txt nextjs` |

> **참고:**
> - `/compact-phase`는 자동으로 압축하지 **않습니다**. `/compact [instructions]` 명령을 출력하므로, 이를 복사하여 직접 실행하세요.
> - `/review`는 6가지 카테고리를 검사합니다: **SEC** (보안) · **TYPE** (타입 안전) · **PERF** (성능) · **LOGIC** (로직 오류) · **STYLE** (컨벤션) · **TEST** (누락 테스트).
> - 컨텍스트를 3개 이상 로드하면 경고가 표시됩니다. 최적 성능을 위해 ≤2개로 유지하세요.

## 2.1 목표별 네비게이션 (목표 -> 완료 신호)

| 목표 | 시작 커맨드 | 완료 신호 | 다음 액션 |
|---|---|---|---|
| 작은 수정 반영 | `/do` | 코드+검증 완료 | `/review [path]` |
| 복잡 기능 구현 | `/plan` | 플랜 승인 + 구현 완료 | `/review --all` |
| 설계안만 먼저 확보 | `/plan --no-build` | 실행 가능한 플랜 확보 | `/do` 또는 `/do-sonnet` 실행 |
| 고난도 불확실성 조사 | `/dplan` | 검증된 선택지 확보 | 선택지 확정 후 실행 |
| 보안 게이트 통과 | `/review --security` | 보안 리뷰 PASS | 머지/릴리즈 진행 |
| 안전하게 중단 | `/session-save` | 세션 파일 저장 완료 | `/session-load`로 재개 |
| 이전 상태 확인 후 재개 | `/session-load --list` | 대상 세션 식별 완료 | `/session-load [name]` |
| 비대해진 컨텍스트 정리 | `/compact-phase` | 단계 기준 정리 완료 | 현재 워크플로우 계속 |

## 3. 시나리오별 실행 런북

### 시나리오 1: 빠른 버그 수정

적용: 버그 1건, 범위가 명확하고 파일 수가 적을 때.

```bash
/model haiku
/do Fix off-by-one error in pagination and add a regression test.
/review src/pagination/
```

`/do`가 2회 실패하면:
```bash
/do-sonnet Fix off-by-one error in pagination and add a regression test.
```

### 시나리오 2: 여러 파일에 걸친 기능 추가

적용: 모듈/레이어를 넘는 신규 기능.

```bash
/plan Add password reset flow (API, service, email template, tests).
```

플랜 확인 후:
1. 구현 진행 승인
2. 구현 후
   ```bash
   /review src/auth/
   ```

### 시나리오 3: 구현 전 설계 합의만 필요

적용: 먼저 설계 결론이 필요한 작업.

```bash
/plan --no-build Design multi-tenant workspace isolation.
```

합의 후 `/do` 또는 `/do-sonnet`으로 구현합니다.

### 시나리오 4: 도메인이 낯설거나 난도가 높은 문제

적용: 경쟁 상태, 분산 처리, 복잡 의사결정.

```bash
/dplan Validate idempotency + locking strategy for payment retries.
```

검증된 설계를 실행 태스크로 분해해 진행합니다.

### 시나리오 5: `/do`가 계속 실패

적용: 같은 작업이 재시도 후에도 실패할 때.

순서:
1. 작업 문장을 더 구체화해 재시도
2. Sonnet 승격
   ```bash
   /do-sonnet [same task, clearer constraints]
   ```
3. 여전히 막히고 임계 작업이면
   ```bash
   /do-opus [same task + failure context]
   ```
4. 계속 실패하면 작업 단위를 더 쪼개서 Haiku/Sonnet부터 재시작

### 시나리오 6: 머지 전 품질 게이트

적용: 구현 완료 후 배포/머지 직전.

```bash
/review --all
/review --security src/
```

이슈 수정 후 변경 경로 기준으로 재리뷰합니다.

### 시나리오 7: 보안 민감 변경

적용: 인증/인가/시크릿/결제.

```bash
/plan Add role-based permission checks for admin endpoints.
/review --security src/auth/
/review --security src/api/
```

### 시나리오 8: 장시간 테스트/빌드 관찰

적용: watch 모드, 장시간 프로세스.

```bash
/watch tests
# 또는
/watch dev
# 또는
/watch build
```

tmux 기본 제어:
- 분리: `Ctrl+b d`
- 재접속: `tmux attach -t claude-watch-tests`
- 세션 목록: `tmux ls`
- 세션 종료: `tmux kill-session -t claude-watch-tests`

사용자 지정 모니터링 예시:
```bash
/watch custom "pnpm test:e2e --watch"
```

### 시나리오 9: 오늘 작업 저장 후 내일 재개

중단 전:
```bash
/session-save checkout-refactor
```

> **보안:** `/session-save`는 세션 파일 작성 전에 API 키, 토큰, 비밀번호 등 15+ 패턴의 시크릿을 자동으로 제거합니다. 수동 정리가 필요 없습니다.

재개 시:
```bash
/session-load --list
/session-load checkout-refactor
```

### 시나리오 10: 작업 초점 전환 (백엔드 <-> 프론트엔드)

적용: 현재 세션의 초점이 크게 바뀔 때.

```bash
/load-context --list
/load-context frontend
/load-context session
/compact-phase planning
```

현재 작업에 필요한 컨텍스트만 유지합니다.

### 시나리오 11: 같은 실수/재작업 반복

적용: 비슷한 수정이 계속 발생할 때.

```bash
/learn "Always validate request DTO before service call"
/learn --show
```

### 시나리오 12: 도구 오류가 반복 누적됨

적용: edit/grep 등 툴 실패가 잦을 때.

```bash
/analyze-failures 100
```

분석 결과를 `/learn`으로 규칙화합니다.

### 시나리오 13: 라이브러리 공식 문서 빠른 확인

적용: 구현 중 API/문법 확인이 즉시 필요할 때.

```bash
/llms-txt nextjs
/llms-txt prisma
/llms-txt https://example.com/llms.txt
```

### 시나리오 14: 세션 컨텍스트가 비대해짐

적용: 대화가 길어져 정확도/속도가 떨어질 때.

```bash
/compact-phase planning
# 또는
/compact-phase implementation
# 또는
/compact-phase review
# 또는
/compact-phase deep-planning
```

> **동작 방식:** `/compact-phase`는 자동으로 압축하지 않습니다. 맞춤형 `/compact [instructions]` 명령을 출력하므로, 이를 복사하여 직접 실행하세요. 시스템은 75% 컨텍스트 도달 시 자동 압축도 수행합니다 (`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=75`).

## 4. 일상 운영 루프

### A. 일반 개발 루프

1. `/model haiku`
2. `/do [task]`
3. `/review [changed path]`
4. 반복
5. 종료 전 `/session-save [name]`

### B. 복잡 기능 루프

1. `/plan [feature]`
2. 플랜 승인
3. 구현 진행
4. `/review --all`
5. `/review --security [critical paths]`

### C. 조사 후 실행 루프

1. `/dplan [problem]`
2. 설계안 선택
3. `/do` 또는 `/do-sonnet` 실행
4. `/review`로 검증

## 5. 에스컬레이션 운영 규칙

- 기본 실행: `Haiku + /do`
- 필요할 때만 단계적으로 승격:
  1. `/do-sonnet`
  2. `/do-opus`
- 장애가 해소되면 고비용 모델에 머물지 않습니다.
- 후속 루틴 작업은 Haiku/Sonnet으로 복귀합니다.

## 6. 복붙 템플릿

### 작은 수정
```bash
/do Fix [bug] in [file/path]. Add minimal test. Keep diff small.
```

### 복잡 구현
```bash
/plan Implement [feature]. Include affected files, migration impact, and test plan.
```

### 깊은 조사
```bash
/dplan Investigate [issue]. Compare at least two design options with risks.
```

### 보안 점검
```bash
/review --security [path]
```

### 리뷰 결과 해석
- `PASS`: 머지/릴리즈 흐름으로 진행합니다.
- `FAIL`: 지적 사항을 수정하고 변경 경로 기준으로 `/review`를 다시 실행합니다.

### 작업 종료
```bash
/session-save [feature-name]
```

## 7. 피해야 할 패턴

- `/do-opus`를 기본값처럼 사용하는 것
- 한 번에 끝낼 수 있는 작업을 지나치게 잘게 `/do`로 쪼개는 것
- 비단순 변경에서 `/review` 없이 머지하는 것
- 필요 이상으로 컨텍스트를 많이 로드하는 것
- 컨텍스트가 오염된 세션을 정리 없이 계속 쓰는 것
- 롤백 이후 변경/미추적 파일 상태 확인 없이 바로 다음 작업으로 넘어가는 것

## 8. 빠른 복구표

| 문제 | 즉시 조치 |
|---|---|
| `/do` 2회 실패 | 작업 범위를 명확히 하고 `/do-sonnet` |
| Sonnet도 실패한 핵심 작업 | 제약을 명시해 `/do-opus` |
| 출력 품질이 점점 흔들림 | `/compact-phase [current phase]` |
| 지금 당장 종료해야 함 | `/session-save [name]` |
| 이전 진척이 기억 안 남 | `/session-load --list` 후 대상 로드 |
| 도구 에러 반복 | `/analyze-failures` 후 `/learn` |

`/do` 실패로 롤백이 발생했다면:
1. `git status`로 현재 상태 확인
2. 유지할 파일과 정리할 파일 분리
3. 필요 없는 임시 파일은 수동 정리

## 9. 백그라운드 시스템 동작

아래 훅은 자동 실행됩니다. 별도 명령 불필요 — 표시되는 메시지의 의미만 알아두세요.

| 트리거 | 동작 | 표시 메시지 |
|---|---|---|
| 세션 시작 | Pro Plan 전략 요약 표시 (비용 비율, 메시지 목표) | `📊 Pro Plan Strategy: ~45 msg/5h...` |
| Write/Edit 25회 | 컴팩트 안내 (advisory) | `[COMPACT-ADVISORY] 25 tool calls...` |
| Write/Edit 50회 | 컴팩트 경고 (warning) | `[COMPACT-WARNING] 50 tool calls...` |
| Write/Edit 75회 | 컴팩트 긴급 (critical) | `[COMPACT-CRITICAL] 75 tool calls...` |
| 컨텍스트 75% 도달 | 자동 컴팩트 발동 (`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=75`) | 자동 컨텍스트 축소 |
| 도구 실패 (매회) | `~/.claude/logs/tool-failures.log`에 기록 | 무음 (`/analyze-failures`로 확인) |
| 파일 편집 | 자동 포맷 실행 (prettier / black / gofmt / rustfmt) | 무음 |
| `/compact` 실행 전 | 사전 컴팩트 훅이 현재 상태를 `~/.claude/sessions/`에 저장 | 무음 |
| 세션 종료 | 자동 요약 저장 + 시크릿 제거 | 무음 |
| 빌더 재시도 한도 (2×) | 빌더 서브에이전트 중단, 에스컬레이션 제안 | `RETRY_CAP: 2 consecutive failures detected.` |

**선택적 환경 변수** (`.claude/settings.json` → `env`):

| 변수 | 기본값 | 설명 |
|---|---|---|
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | `75` | 자동 컴팩트 발동 컨텍스트 % 임계값 |
| `CLAUDE_SESSION_NOTIFY` | `0` | `1`로 설정 시 세션 시작 때 이전 세션 자동 감지 |
| `CLAUDE_FAILURE_NOTIFY` | `0` | `1`로 설정 시 누적 실패 10건 이상에서 `/analyze-failures` 자동 권유 |

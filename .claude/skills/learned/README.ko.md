# 학습된 패턴 데이터베이스 (Learned Patterns)

이 디렉토리는 Claude Code 환경의 **장기 기억(Long-Term Memory)** 저장소입니다. `/learn` 명령어를 통해 추출된 반복적인 코딩 패턴, 아키텍처 결정 사항, 그리고 개인적인 코딩 스타일 선호도를 보관합니다.

## 핵심 개념: 지식 순환 아키텍처

1. **감지 (Detection)**: 작업 도중 반복되는 패턴이나 중요한 규칙을 발견합니다.
2. **추출 (Extraction)**: `/learn` 명령어를 실행하여 해당 지식을 정형화합니다.
3. **저장 (Persistence)**: 메타데이터가 포함된 마크다운 파일로 이 폴더에 저장됩니다.
4. **부활 (Resurrection)**: 다음 세션이 시작될 때 Claude는 이 폴더를 인덱싱하여, **과거의 실수를 반복하지 않고 이미 결정된 규칙을 다시 묻지 않습니다.**

## 사용 방법 및 실행

### 1. 명시적 학습 (Manual Learning)
기억해야 할 규칙이 생겼을 때 직접 입력합니다:
`> /learn "API 에러 핸들링 시 항상 try-catch와 전역 로거를 사용해줘"`

### 2. 세션 분석 (Session Analysis)
복잡한 작업을 마친 후, Claude에게 패턴을 찾아내라고 시킵니다:
`> /learn`
Claude가 전체 대화 기록을 분석하여 저장할만한 패턴을 제안합니다.

### 3. 목록 확인 (Management)
`> /learn --show` (현재 저장된 모든 패턴 목록을 확인합니다.)

## 분류 체계 및 저장 위치

| 카테고리 | 저장 위치 | 용도 |
| :--- | :--- | :--- |
| **CONVENTION** | `.claude/rules/` | 구조적 규칙 (예: 폴더 구조, 네이밍 컨벤션) |
| **PATTERN** | **이 폴더 (learned/)** | 재사용 가능한 로직 블록 (예: 인증 흐름, 에러 처리 패턴) |
| **PREFERENCE** | `.claude/rules/` | 개인적 취향 (예: "나는 trailing comma를 선호함") |

## 패턴 파일 구조

모든 패턴 파일은 Claude가 읽기 최적화된 아래 형식을 따릅니다:

```markdown
---
name: api-response-format
category: PATTERN
tags: [api, nodejs, json]
---
# 패턴: 표준 API 응답 형식

## 문제점
API 응답 형식이 일관되지 않아 프론트엔드에서 파싱 에러가 자주 발생함.

## 해결책
`src/types/api.ts`에 정의된 `BaseResponse` 인터페이스를 반드시 사용함.

## 예시
```typescript
res.json({
  success: true,
  data: result,
  error: null
});
```
```

## ⚠️ 주의 사항
- **비밀번호/키 제외**: `/learn` 명령어 실행 시 `scrub-secrets.js`가 자동으로 작동하여 API 키나 토큰이 저장되지 않도록 검열합니다.
- **프로젝트 컨텍스트**: 패턴은 사용자 홈 디렉토리에 저장되지만, Claude는 현재 프로젝트와 연관된 패턴을 우선적으로 인덱싱합니다.

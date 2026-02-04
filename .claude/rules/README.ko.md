> **[English Version](README.md)**

# Rules Directory

## 목적
Claude가 항상 따르는 규칙들을 포함합니다. 이 규칙들은 모든 세션에서 자동으로 로드됩니다.

## 내용

| 파일 | 목적 | 우선순위 |
|------|---------|----------|
| `critical-actions.md` | 위험한 명령어에 대한 HITL(Human-in-the-Loop) 확인 | 최상 |
| `security.md` | 보안 모범 사례 | 상 |
| `code-style.md` | 코드 컨벤션 | 중 |
| `language.md` | 응답 언어 강제 | 하 |

## 중요 작업 (Critical Actions)

가장 중요한 규칙 파일입니다. 다음을 정의합니다:

1. **직접적인 위험 명령어:**
   - `git push --force`
   - `DROP TABLE`, `DELETE FROM` (WHERE 절 없음)
   - 주요 디렉토리에 대한 `rm -rf`

2. **간접적인 스크립트 감지:**
   - `npm run clean`, `reset`, `nuke`
   - `yarn db:reset`, `db:drop`

3. **Git 충돌 처리:**
   - 즉시 감지
   - 사용자에게 이양 (자동 해결 금지)

## 설계 결정

| 결정 | 근거 |
|------|------|
| 규칙 파일에 frontmatter 없음 | `critical-actions.md`와 `security.md` 같은 규칙은 의도적으로 전역 적용. `paths` 제한 불필요 |
| `critical-actions.md`를 순수 마크다운으로 | 훅 기반 차단(`critical-action-check.sh`)이 실제 강제를 담당. 규칙 파일은 Claude 이해를 위한 문서 |
| `security.md`를 `critical-actions.md`에서 분리 | Critical actions = 위험 명령어 차단. Security = 코딩 모범 사례. 목적이 다름 |

## 사용법

규칙은 자동으로 로드됩니다. 별도의 명령어가 필요하지 않습니다.

## 범위 지정 규칙 (고급)

`paths` frontmatter를 사용하여 특정 파일에만 규칙을 제한할 수 있습니다. 모노레포나 여러 언어가 섞인 프로젝트에서 유용합니다.

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "lib/**/*.ts"
---
# API 규칙
...
```

## 고급 구성

- **서브디렉토리**: 규칙을 폴더별로 그룹화할 수 있습니다 (예: `rules/frontend/`, `rules/backend/`).
- **심볼릭 링크 (Symlinks)**: 여러 프로젝트 간 일관성을 위해 공유 규칙 세트를 링크할 수 있습니다.

## 커스텀 규칙 추가

새로운 `.md` 파일을 생성하세요:

```markdown
---
# 선택 사항: 특정 파일에만 적용
paths:
  - "**/*.ts"
---

# [Rule Name] Rules

## 목적
이 규칙이 강제하는 것.

## 항상 할 것 (ALWAYS Do)
- ...

## 절대 하지 말 것 (NEVER Do)
- ...
```

## 우선순위

```
~/.claude/rules/*.md          (사용자 레벨, 먼저 로드됨)
./project/.claude/rules/*.md  (프로젝트 레벨, 사용자 규칙을 오버라이드)
```

프로젝트 규칙이 **더 높은 우선순위**를 가집니다. 프로젝트 규칙 파일이 사용자 규칙 파일과 동일한 이름(예: `code-style.md`)을 가진 경우, 프로젝트 버전이 사용자 버전을 완전히 대체합니다.

프로젝트 규칙이 전역 규칙과 동일한 파일명을 가질 경우 전역 규칙을 오버라이드할 수 있습니다.

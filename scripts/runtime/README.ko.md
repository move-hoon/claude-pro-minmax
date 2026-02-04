> **[English Version](README.md)**

# Runtime Detection Layer

## 목적
언어 독립적 작업을 위한 OCP 준수 런타임 감지. 코어 스크립트 수정 없이 새 언어 추가 가능.

## 구조

```
runtime/
├── detect.sh         # 프로젝트 런타임 자동 감지
└── adapters/         # 언어별 구현체
```

## detect.sh

프로젝트 유형을 자동 감지하고 JSON을 출력합니다.

**사용법:**
```bash
# 기본 사용
./detect.sh
# 출력: {"runtime":"node","tool":"npm","adapter":"node.sh"}

# 모노레포 지원 (하위 디렉토리)
./detect.sh --path backend
# 출력: {"runtime":"jvm","tool":"gradle","adapter":"jvm.sh"}
```

**감지 우선순위:**
1. JVM: `build.gradle.kts` > `build.gradle` > `pom.xml`
2. Node: `package.json` (락 파일로 패키지 매니저 확인)
3. Rust: `Cargo.toml`
4. Go: `go.mod`
5. Python: `pyproject.toml` > `setup.py` > `requirements.txt`
6. Generic: Makefile로 폴백

## 통합

유니버설 스크립트가 이 레이어를 사용합니다:

```bash
# scripts/verify.sh
RUNTIME=$("$RUNTIME_DIR/detect.sh" "$@")
ADAPTER=$(echo "$RUNTIME" | jq -r '.adapter')
source "$RUNTIME_DIR/adapters/$ADAPTER"
adapter_verify
```

## 새 런타임 추가

`detect.sh`만 업데이트:

```bash
# 감지 패턴 추가
[[ -f "$dir/mix.exs" ]] && echo '{"runtime":"elixir","tool":"mix","adapter":"elixir.sh"}' && return
```

그 다음 `adapters/elixir.sh`에 어댑터 생성.

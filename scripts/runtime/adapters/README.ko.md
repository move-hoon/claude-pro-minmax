> **[English Version](README.md)**

# Adapters Directory

## 목적
어댑터 계약을 따르는 언어별 구현체. 각 어댑터는 빌드, 테스트, 린트 작업에 대해 통합 인터페이스를 제공합니다.

## 사용 가능한 어댑터

| 어댑터 | 런타임 | 빌드 도구 | 언어 |
|---------|---------|-------------|-----------|
| `jvm.sh` | JVM | Gradle, Maven | Java, Kotlin |
| `node.sh` | Node | npm, pnpm, yarn, bun | TypeScript, JavaScript |
| `go.sh` | Go | Go 모듈 | Go |
| `rust.sh` | Rust | Cargo | Rust |
| `python.sh` | Python | pip, poetry, uv | Python |
| `generic.sh` | Generic | Makefile | Any |

## 개발 유틸리티

| 파일 | 목적 |
|------|------|
| `_interface.sh` | 계약 검증기 - 어댑터가 모든 필수 함수를 구현했는지 검증 |
| `_template.sh` | 어댑터 템플릿 - 새 어댑터 생성 시 복사하여 사용 |

## 어댑터 계약

모든 어댑터는 다음 함수를 구현해야 합니다 (`_interface.sh`에 정의됨):

```bash
adapter_info()    # 어댑터 메타데이터를 JSON으로 반환
adapter_verify()  # 전체 검증 실행 (빌드 + 테스트 + 린트)
adapter_build()   # 프로젝트 빌드
adapter_test()    # 테스트 실행
adapter_lint()    # 린터 실행
adapter_format()  # 코드 포맷
adapter_clean()   # 빌드 산출물 정리
```

선택 사항:
```bash
adapter_run()     # 개발 서버 실행
```

## 새 어댑터 추가

**3단계 (OCP - 코어 수정 없음):**

1. 템플릿 복사:
   ```bash
   cp _template.sh elixir.sh
   ```

2. 모든 `adapter_*` 함수 구현

3. `../detect.sh`에 감지 패턴 추가:
   ```bash
   [[ -f "$dir/mix.exs" ]] && echo '{"runtime":"elixir","tool":"mix","adapter":"elixir.sh"}' && return
   ```

완료! Universal scripts가 자동으로 새 어댑터 사용

## 어댑터 준수 검증

```bash
./adapters/_interface.sh ./adapters/elixir.sh
# 출력: ✓ Adapter implements all required functions
```

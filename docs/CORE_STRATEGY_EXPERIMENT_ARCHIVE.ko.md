# 핵심전략 실험 아카이브 (워크로드 직접 측정)

## 1) 측정 항목

- `/usage`: 각 실행의 `Δusage`만 기록
- `ccusage session`: `Input`, `Output`, `Cache Create (cache output)`, `Cache Read`, `Total Tokens`, `Cost`
- `ccusage` 수치: 각 시점의 session 리포트 값 (conversation session 기준)
- Opus 실행 설정: 이 아카이브의 Opus 4.6 실행은 effort mode를 `medium`으로 고정하여 수행함.
- 해석상 주의: `/usage`는 퍼센트 단위의 거친 지표이므로, 이 문서는 절대적인 내부 credits 공식을 "증명"하기보다 워크로드별 상대 경향과 전략 방향을 검증하는 데 초점을 둔다.

## 2) 비교 파일 크기 실측 (`wc -l -w -c`, 실행 대상)

| File Label | Lines | Words | Bytes |
| --- | ---: | ---: | ---: |
| target.js | 1002 | 11008 | 98843 |
| small.txt | 120 | 1200 | 9000 |
| medium.txt | 240 | 2400 | 18000 |

## 3) 워크로드 A: no-tool short reply (1회)

프롬프트: `Reply with exactly one word: done`

| Model | Δusage | Input | Output | Cache Create (cache output) | Cache Read | Total Tokens | Cost |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Haiku 4.5 | +0% | 10 | 3 | 4,293 | 0 | 4,306 | $0.01 |
| Sonnet 4.5 | +0% | 10 | 7 | 4,145 | 0 | 4,162 | $0.02 |
| Opus 4.6 | +2% | 3 | 1 | 4,129 | 0 | 4,133 | $0.03 |

## 4) 워크로드 B: tool-mediated single-file read (3회 반복)

프롬프트: `Read target.js and output exactly: done`

### 4.1 턴별 스냅샷 (직접 측정)

| Model | Turn | Δusage (turn) | Input | Output | Cache Create (cache output) | Cache Read | Total Tokens | Cost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Haiku 4.5 | 1st | +0% | 26 | 13 | 6,297 | 11,236 | 17,572 | $0.01 |
| Haiku 4.5 | 2nd | +0% | 36 | 14 | 7,364 | 17,578 | 24,992 | $0.01 |
| Haiku 4.5 | 3rd | +1% | 46 | 16 | 8,429 | 25,194 | 33,685 | $0.01 |
| Sonnet 4.5 | 1st | +1% | 34 | 9 | 9,827 | 17,199 | 27,069 | $0.04 |
| Sonnet 4.5 | 2nd | +1% | 52 | 11 | 14,728 | 38,058 | 52,849 | $0.07 |
| Sonnet 4.5 | 3rd | +1% | 70 | 14 | 19,616 | 68,799 | 88,499 | $0.09 |
| Opus 4.6 | 1st | +7% | 7 | 147 | 41,920 | 76,059 | 118,133 | $0.30 |
| Opus 4.6 | 2nd | +6% | 11 | 157 | 79,482 | 160,965 | 240,615 | $0.58 |
| Opus 4.6 | 3rd | +5% | 15 | 184 | 116,979 | 320,999 | 438,177 | $0.90 |

### 4.2 3턴 합계 요약

| Model | Δusage (3 turns) |
| --- | ---: |
| Haiku 4.5 | +1% |
| Sonnet 4.5 | +3% |
| Opus 4.6 | +18% |

## 5) 워크로드 C: no-tool short reply + `/reset` 반복 (Opus)

프롬프트: `Reply with exactly one word: done` (각 실행 사이 `/reset`)

| Run | Δusage | Input | Output | Cache Create (cache output) | Cache Read | Total Tokens | Cost |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1st | +1% | 3 | 1 | 4,129 | 0 | 4,133 | $0.03 |
| 2nd | +1% | 6 | 2 | 8,601 | 0 | 8,609 | $0.05 |
| 3rd | +0% | 9 | 3 | 8,601 | 4,472 | 13,085 | $0.06 |

## 6) 워크로드 D: full-file output (두 파일 크기 비교)

프롬프트 (원문):
- `Read small.txt and output exactly the full file content unchanged. No explanation. No markdown. No extra text.`
- `Read medium.txt and output exactly the full file content unchanged. No explanation. No markdown. No extra text.`
표의 토큰/비용 값은 각 실행 시점의 session 리포트 값

| Model | Payload | Δusage | Input | Output | Cache Create (cache output) | Cache Read | Total Tokens | Cost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Opus 4.6 | small.txt (120L/1200W/9000B) | +3% | 4 | 20 | 4,782 | 37,730 | 42,536 | $0.05 |
| Opus 4.6 | medium.txt (240L/2400W/18000B) | +5% | 6 | 123 | 7,516 | 82,935 | 90,580 | $0.09 |
| Sonnet 4.5 | small.txt (120L/1200W/9000B) | +2% | 4 | 9 | 4,926 | 37,729 | 42,668 | $0.03 |
| Sonnet 4.5 | medium.txt (240L/2400W/18000B) | +3% | 4 | 9 | 7,441 | 37,729 | 45,183 | $0.04 |

## 7) 직접 측정 기반 결론

- no-tool 단문 1회는 Opus만 즉시 `Δusage +2%`가 관측됨.
- tool-mediated 3회 합계는 모델별 차이가 크게 벌어짐: Haiku `+1%`, Sonnet `+3%`, Opus `+18%`.
- 파일 출력 워크로드에서 페이로드가 커질수록(특히 Opus) `Δusage`와 `Total Tokens`가 함께 증가함.
- `/reset` 반복 구간(Opus)은 `+1%, +1%, +0%`로 단기 비선형 패턴이 관측됨.

## 8) 외부 역분석 사례: `claude-limits`

참고 사례: [claude-limits](https://she-llac.com/claude-limits) (2026-03-11 확인)

- 분석 형태: 비공식 역분석
- 분석 기준: generation endpoint의 SSE 응답에 포함된 unrounded usage float 샘플
- 제시 모델:
  - 플랜 usage는 사용 credits / 플랜 credits 비율
  - 호출 1회의 소모량은 `ceil(input_tokens × input_rate + output_tokens × output_rate)`
  - output rate는 input rate의 5배
  - `claude-limits`는 subscription plan의 cache read를 0 credits로 모델링한다.

| Model | Input credits/token | Output credits/token |
| --- | ---: | ---: |
| Haiku | 2/15 | 10/15 |
| Sonnet | 6/15 | 30/15 |
| Opus | 10/15 | 50/15 |

- 글이 제시한 Pro 플랜 추정치:
  - `550,000 credits / 5h`
  - `5,000,000 credits / week`

## 9) 외부 글과 로컬 실험 비교

| 비교 항목 | `claude-limits` 제시 내용 | 로컬 실험 관측 | 정리 |
| --- | --- | --- | --- |
| 무거운 모델일수록 usage 부담이 커진다 | Opus > Sonnet > Haiku 방향의 credits 부담 | A, B | 동일 방향 |
| 같은 작업 반복 시 usage 누적 격차가 벌어진다 | 동일 호출 반복 시 누적 차이 확대 | B | 동일 방향 |
| 입력 처리량이 커질수록 usage가 커진다 | input/output 증가 시 credits 증가 | D | 동일 방향 |
| 반복 실행은 완전한 선형이 아닐 수 있다 | ceil, cache 상태, window에 따라 비선형 가능 | B, C | 부분 대응 |
| cache read가 유리하다 | subscription plan cache read = 0 credits | B, C, D의 `Cache Read` 증가 추이 | 별도 측정 없음 |
| 모델별 계수와 플랜 한도 | 계수표와 Pro/Max 한도 제시 | 직접 재현 데이터 없음 | 별도 측정 없음 |

## 10) 종합 비교

- 직접 측정에서는 무거운 모델, 반복되는 동일 작업, 더 큰 입력/출력이 더 높은 `Δusage`와 연결되는 경향이 관측됐다.
- `claude-limits`는 이 현상을 모델별 계수, input/output 가중치, cache read 처리 방식으로 설명한다.
- CPMM의 핵심 전략인 "가벼운 모델부터 시작하고, 불필요한 출력과 반복 읽기를 줄이며, 검증된 작업량 대비 quota 효율을 높인다"는 방향은 로컬 실험과 외부 역분석에서 같은 축으로 나타난다.

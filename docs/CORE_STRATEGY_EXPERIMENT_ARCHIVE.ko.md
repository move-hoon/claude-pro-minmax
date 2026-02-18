# 핵심전략 실험 아카이브 (워크로드 직접 측정)

## 1) 측정 항목

- `/usage`: 각 실행의 `Δusage`만 기록
- `ccusage session`: `Input`, `Output`, `Cache Create (cache output)`, `Cache Read`, `Total Tokens`, `Cost`
- `ccusage` 수치: 각 시점의 session 리포트 값 (conversation session 기준)

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

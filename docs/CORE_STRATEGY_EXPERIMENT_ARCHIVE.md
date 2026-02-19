# Core Strategy Experiment Archive (Workload Direct Measurements)

## 1) Metrics

- `/usage`: only `Δusage` is reported per run
- `ccusage session`: `Input`, `Output`, `Cache Create (cache output)`, `Cache Read`, `Total Tokens`, `Cost`
- `ccusage` values: session report values at each measurement point (conversation-session grouped)
- Opus runtime setting: all Opus 4.6 runs in this archive were executed with effort mode set to `medium`.

## 2) Measured File Sizes (`wc -l -w -c`, executed files)

| File Label | Lines | Words | Bytes |
| --- | ---: | ---: | ---: |
| target.js | 1002 | 11008 | 98843 |
| small.txt | 120 | 1200 | 9000 |
| medium.txt | 240 | 2400 | 18000 |

## 3) Workload A: no-tool short reply (single run)

Prompt: `Reply with exactly one word: done`

| Model | Δusage | Input | Output | Cache Create (cache output) | Cache Read | Total Tokens | Cost |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Haiku 4.5 | +0% | 10 | 3 | 4,293 | 0 | 4,306 | $0.01 |
| Sonnet 4.5 | +0% | 10 | 7 | 4,145 | 0 | 4,162 | $0.02 |
| Opus 4.6 | +2% | 3 | 1 | 4,129 | 0 | 4,133 | $0.03 |

## 4) Workload B: tool-mediated single-file read (3 repeated runs)

Prompt: `Read target.js and output exactly: done`

### 4.1 Turn-by-turn snapshots (direct measurements)

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

### 4.2 Three-turn total summary

| Model | Δusage (3 turns) |
| --- | ---: |
| Haiku 4.5 | +1% |
| Sonnet 4.5 | +3% |
| Opus 4.6 | +18% |

## 5) Workload C: no-tool short reply + `/reset` repetition (Opus)

Prompt: `Reply with exactly one word: done` (with `/reset` between runs)

| Run | Δusage | Input | Output | Cache Create (cache output) | Cache Read | Total Tokens | Cost |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1st | +1% | 3 | 1 | 4,129 | 0 | 4,133 | $0.03 |
| 2nd | +1% | 6 | 2 | 8,601 | 0 | 8,609 | $0.05 |
| 3rd | +0% | 9 | 3 | 8,601 | 4,472 | 13,085 | $0.06 |

## 6) Workload D: full-file output (two file-size comparison)

Prompt (verbatim):
- `Read small.txt and output exactly the full file content unchanged. No explanation. No markdown. No extra text.`
- `Read medium.txt and output exactly the full file content unchanged. No explanation. No markdown. No extra text.`
Token/cost columns are session report values at each run point

| Model | Payload | Δusage | Input | Output | Cache Create (cache output) | Cache Read | Total Tokens | Cost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Opus 4.6 | small.txt (120L/1200W/9000B) | +3% | 4 | 20 | 4,782 | 37,730 | 42,536 | $0.05 |
| Opus 4.6 | medium.txt (240L/2400W/18000B) | +5% | 6 | 123 | 7,516 | 82,935 | 90,580 | $0.09 |
| Sonnet 4.5 | small.txt (120L/1200W/9000B) | +2% | 4 | 9 | 4,926 | 37,729 | 42,668 | $0.03 |
| Sonnet 4.5 | medium.txt (240L/2400W/18000B) | +3% | 4 | 9 | 7,441 | 37,729 | 45,183 | $0.04 |

## 7) Conclusions from Direct Measurements

- In a one-turn no-tool micro workload, only Opus shows immediate `Δusage +2%`.
- In the 3-turn tool-mediated workload, model spread is large: Haiku `+1%`, Sonnet `+3%`, Opus `+18%`.
- In full-file output workloads, larger payload is accompanied by higher `Δusage` and higher `Total Tokens` (most clearly in Opus).
- In Opus no-tool + `/reset`, short-window behavior is non-linear: `+1%, +1%, +0%`.

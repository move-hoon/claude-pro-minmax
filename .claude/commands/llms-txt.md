---
name: llms-txt
description: Fetch llms.txt documentation for a library. Use when Context7 doesn't cover a library.
argument-hint: nextjs | prisma | supabase | [custom-url]
allowed-tools: Bash(curl:*)
---

# /llms-txt Command

Fetch LLM-optimized documentation for libraries.

## Library
$ARGUMENTS

## Common URLs
| Library | URL |
|---------|-----|
| Next.js | https://nextjs.org/llms.txt |
| Prisma | https://prisma.io/llms.txt |
| Supabase | https://supabase.com/llms.txt |
| Vercel | https://vercel.com/llms.txt |
| Helius | https://www.helius.dev/docs/llms.txt |
| Tailwind | https://tailwindcss.com/llms.txt |

## Execution

Based on the library name:
1. Try `https://[library].org/llms.txt`
2. Try `https://[library].io/llms.txt`
3. Try `https://[library].com/llms.txt`
4. Try `https://docs.[library].io/llms.txt`

For custom URLs, fetch directly.

```bash
# Example
curl -s https://nextjs.org/llms.txt | head -200
```

## When to Use
- Context7 MCP가 해당 라이브러리를 찾지 못할 때
- 빠른 원샷 문법 확인이 필요할 때
- 최신 API 문서가 필요할 때

## Examples
```
/llms-txt nextjs          # Next.js 문서
/llms-txt prisma          # Prisma 문서
/llms-txt https://custom.dev/llms.txt  # Custom URL
```

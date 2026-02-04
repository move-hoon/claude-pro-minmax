#!/usr/bin/env node
/**
 * Secret Scrubber
 * Removes 15+ secret patterns from text
 * Usage: cat file | node scrub-secrets.js > clean-file
 */

const readline = require('readline');

const PATTERNS = [
  { p: /sk-[a-zA-Z0-9\-]{20,}/g, r: '[REDACTED:OPENAI_KEY]' },
  { p: /sk-ant-[a-zA-Z0-9\-]{20,}/g, r: '[REDACTED:ANTHROPIC_KEY]' },
  { p: /pplx-[a-zA-Z0-9\-]{20,}/g, r: '[REDACTED:PERPLEXITY_KEY]' },
  { p: /sk_live_[a-zA-Z0-9]{20,}/g, r: '[REDACTED:STRIPE_LIVE]' },
  { p: /sk_test_[a-zA-Z0-9]{20,}/g, r: '[REDACTED:STRIPE_TEST]' },
  { p: /ghp_[a-zA-Z0-9]{36}/g, r: '[REDACTED:GITHUB_PAT]' },
  { p: /gho_[a-zA-Z0-9]{36}/g, r: '[REDACTED:GITHUB_OAUTH]' },
  { p: /AKIA[A-Z0-9]{16}/g, r: '[REDACTED:AWS_KEY]' },
  { p: /postgres(ql)?:\/\/[^:]+:[^@]+@[^\s]+/g, r: '[REDACTED:POSTGRES_URL]' },
  { p: /mysql:\/\/[^:]+:[^@]+@[^\s]+/g, r: '[REDACTED:MYSQL_URL]' },
  { p: /mongodb(\+srv)?:\/\/[^:]+:[^@]+@[^\s]+/g, r: '[REDACTED:MONGODB_URL]' },
  { p: /Bearer\s+[a-zA-Z0-9\-_.]{20,}/g, r: 'Bearer [REDACTED:TOKEN]' },
  { p: /eyJ[a-zA-Z0-9\-_]+\.eyJ[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+/g, r: '[REDACTED:JWT]' },
  { p: /password["'\s:=]+["'][^"']{4,}["']/gi, r: 'password: "[REDACTED]"' },
  { p: /secret["'\s:=]+["'][^"']{8,}["']/gi, r: 'secret: "[REDACTED]"' },
  { p: /-----BEGIN[A-Z\s]+PRIVATE KEY-----[\s\S]*?-----END[A-Z\s]+PRIVATE KEY-----/g, r: '[REDACTED:PRIVATE_KEY]' },
];

let count = 0;

function scrub(line) {
  let result = line;
  for (const { p, r } of PATTERNS) {
    const m = result.match(p);
    if (m) { count += m.length; result = result.replace(p, r); }
  }
  return result;
}

async function main() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout, terminal: false });
  const lines = [];
  for await (const line of rl) lines.push(scrub(line));
  console.log(lines.join('\n'));
  console.error(`\n--- Scrubbed: ${count} secrets ---`);
}

main().catch(console.error);

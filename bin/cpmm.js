#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");
const os = require("node:os");
const { spawnSync } = require("node:child_process");

const pkg = require("../package.json");
const argv = process.argv.slice(2);
const command = argv[0] || "install";
const installScript = path.resolve(__dirname, "..", "install.sh");
const HOME = os.homedir();

function printHelp() {
  console.log(`CPMM CLI v${pkg.version}

Usage:
  cpmm install    Install CPMM to ~/.claude
  cpmm doctor     Verify installation
  cpmm --help     Show this help
  cpmm --version  Show version
`);
}

if (command === "--help" || command === "-h" || command === "help") {
  printHelp();
  process.exit(0);
}

if (command === "--version" || command === "-v" || command === "version") {
  console.log(pkg.version);
  process.exit(0);
}

if (process.platform === "win32") {
  console.error(
    "CPMM installer requires macOS/Linux. Windows users: use WSL (https://learn.microsoft.com/windows/wsl/install)"
  );
  process.exit(1);
}

if (command === "doctor") {
  runDoctor();
  process.exit(0);
}

if (!fs.existsSync(installScript)) {
  console.error(`Install script not found: ${installScript}`);
  process.exit(1);
}

if (command !== "install") {
  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(1);
}

const filteredEnv = buildFilteredEnv();
const result = spawnSync("bash", [installScript], {
  stdio: "inherit",
  env: filteredEnv,
});

if (result.error) {
  console.error(result.error.message);
  process.exit(1);
}

process.exit(result.status ?? 1);

function buildFilteredEnv() {
  const allowed = [
    "PATH", "HOME", "SHELL", "USER", "TERM",
    "LANG", "LC_ALL", "TMPDIR", "XDG_CONFIG_HOME",
  ];
  return Object.fromEntries(
    allowed
      .filter((k) => process.env[k] !== undefined)
      .map((k) => [k, process.env[k]])
  );
}

function checkFile(filePath) {
  return fs.existsSync(filePath);
}

function checkExecutable(filePath) {
  if (!fs.existsSync(filePath)) return false;
  try {
    fs.accessSync(filePath, fs.constants.X_OK);
    return true;
  } catch {
    return false;
  }
}

function checkCli(name) {
  const r = spawnSync("which", [name], { encoding: "utf8" });
  return r.status === 0 && r.stdout.trim().length > 0;
}

function parseMcpServers() {
  const claudeJson = path.join(HOME, ".claude.json");
  if (!fs.existsSync(claudeJson)) return [];
  try {
    const data = JSON.parse(fs.readFileSync(claudeJson, "utf8"));
    return Object.keys(data.mcpServers || {});
  } catch {
    return [];
  }
}

function formatLine(symbol, label, note) {
  const base = `  ${symbol} ${label}`;
  return note ? base.padEnd(46) + note : base;
}

function runDoctor() {
  const results = { pass: 0, fail: 0, warn: 0 };

  function check(symbol, label, note) {
    if (symbol === "✓") results.pass++;
    else if (symbol === "✗") results.fail++;
    else results.warn++;
    console.log(formatLine(symbol, label, note));
  }

  function required(ok, label) {
    check(ok ? "✓" : "✗", label, ok ? null : "(required — missing)");
  }

  function optional(ok, label, note) {
    check(ok ? "✓" : "⚠", label, ok ? null : note);
  }

  console.log(`CPMM Doctor v${pkg.version}\n`);

  console.log("Core Files:");
  required(checkFile(`${HOME}/.claude/CLAUDE.md`), "~/.claude/CLAUDE.md");
  required(checkFile(`${HOME}/.claude/settings.json`), "~/.claude/settings.json");

  console.log("\nRules:");
  required(checkFile(`${HOME}/.claude/rules/critical-actions.md`), "~/.claude/rules/critical-actions.md");
  required(checkFile(`${HOME}/.claude/rules/security.md`), "~/.claude/rules/security.md");
  required(checkFile(`${HOME}/.claude/rules/code-style.md`), "~/.claude/rules/code-style.md");
  optional(checkFile(`${HOME}/.claude/rules/language.md`), "~/.claude/rules/language.md", "(optional)");

  console.log("\nScripts:");
  required(checkExecutable(`${HOME}/.claude/scripts/verify.sh`), "~/.claude/scripts/verify.sh");
  required(checkExecutable(`${HOME}/.claude/scripts/runtime/detect.sh`), "~/.claude/scripts/runtime/detect.sh");

  console.log("\nSkills:");
  required(checkFile(`${HOME}/.claude/skills/`), "~/.claude/skills/");

  const mcpServers = parseMcpServers();
  console.log("\nMCP Servers:");
  required(mcpServers.includes("context7"), "context7");
  required(mcpServers.includes("sequential-thinking"), "sequential-thinking");
  optional(mcpServers.includes("perplexity"), "perplexity", "(optional — set API key)");

  console.log("\nCLI Tools:");
  required(checkCli("claude"), "claude");
  required(checkCli("jq"), "jq");
  optional(checkCli("mgrep"), "mgrep", "(optional — npm install -g @mixedbread/mgrep)");
  optional(checkCli("tmux"), "tmux", "(optional)");

  const total = results.pass + results.fail + results.warn;
  console.log(`\nResult: ${results.pass}/${total} passed, ${results.warn} optional skipped`);

  if (results.fail > 0) process.exit(1);
}

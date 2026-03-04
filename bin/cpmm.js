#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");
const os = require("node:os");
const { spawnSync } = require("node:child_process");
const {
  getDependencyPolicy,
  getDependencyByKey,
  remediationPlanForDependency,
} = require("./dependency-policy");

const pkg = require("../package.json");
const argv = process.argv.slice(2);
const command = argv[0] || "install";
const commandArgs = argv.slice(1);
const installScript = path.resolve(__dirname, "..", "install.sh");
const HOME = os.homedir();

const EXIT_CODES = {
  OK: 0,
  CHECK_FAILED: 1,
  USAGE_ERROR: 2,
  EXECUTION_FAILED: 3,
};

main();

function main() {
  if (isGlobalHelp(command)) {
    printHelp();
    process.exit(EXIT_CODES.OK);
  }

  if (isGlobalVersion(command)) {
    console.log(pkg.version);
    process.exit(EXIT_CODES.OK);
  }

  if (process.platform === "win32") {
    console.error(
      "CPMM installer requires macOS/Linux. Windows users: use WSL (https://learn.microsoft.com/windows/wsl/install)"
    );
    process.exit(EXIT_CODES.CHECK_FAILED);
  }

  switch (command) {
    case "install":
      process.exit(runInstall(commandArgs));
    case "setup":
      process.exit(runSetup(commandArgs));
    case "doctor":
      process.exit(runDoctor(commandArgs));
    default:
      printUsageError(`Unknown command: ${command}`);
      process.exit(EXIT_CODES.USAGE_ERROR);
  }
}

function isGlobalHelp(value) {
  return value === "--help" || value === "-h" || value === "help";
}

function isGlobalVersion(value) {
  return value === "--version" || value === "-v" || value === "version";
}

function printHelp() {
  const policy = getDependencyPolicy();
  const required = policy
    .filter((dep) => dep.required)
    .map((dep) => dep.label)
    .join(", ");
  const optional = policy
    .filter((dep) => !dep.required)
    .map((dep) => dep.label)
    .join(", ");

  console.log(`CPMM CLI v${pkg.version}

Usage:
  cpmm install
  cpmm setup [--check|--fix] [--yes] [--json]
  cpmm doctor [--fix] [--yes] [--json]
  cpmm --help
  cpmm --version

Dependency Policy:
  required: ${required}
  optional: ${optional}

Contract Exit Codes (setup/doctor):
  0  All required checks passed (or required deps fixed successfully)
  1  Required checks failed (no remediation execution failure)
  2  Invalid CLI usage/flags
  3  Remediation execution failure (--fix --yes only)
`);
}

function printUsageError(message) {
  console.error(message);
  console.error("Run 'cpmm --help' for usage.");
}

function runInstall(args) {
  if (args.length > 0) {
    printUsageError(`Unexpected arguments for install: ${args.join(" ")}`);
    return EXIT_CODES.USAGE_ERROR;
  }

  if (!fs.existsSync(installScript)) {
    console.error(`Install script not found: ${installScript}`);
    return EXIT_CODES.CHECK_FAILED;
  }

  const filteredEnv = buildFilteredEnv();
  const result = spawnSync("bash", [installScript], {
    stdio: "inherit",
    env: filteredEnv,
  });

  if (result.error) {
    console.error(result.error.message);
    return EXIT_CODES.CHECK_FAILED;
  }

  return result.status ?? EXIT_CODES.CHECK_FAILED;
}

function runSetup(args) {
  const parsed = parseCommandFlags("setup", args);
  if (parsed.error) {
    printUsageError(parsed.error);
    return EXIT_CODES.USAGE_ERROR;
  }

  if (parsed.flags.has("--help")) {
    printSetupHelp();
    return EXIT_CODES.OK;
  }

  const mode = parsed.flags.has("--fix") ? "fix" : "check";
  const json = parsed.flags.has("--json");

  const report = evaluateDependencyReport();
  let executionError = null;

  if (mode === "fix") {
    if (!parsed.flags.has("--yes")) {
      printUsageError("--fix requires --yes (non-interactive mutation gate).");
      return EXIT_CODES.USAGE_ERROR;
    }

    executionError = remediateMissingDependencies(report.missingDependencies, { json });

    const postFixReport = evaluateDependencyReport();
    report.checks = postFixReport.checks;
    report.missingDependencies = postFixReport.missingDependencies;
    report.requiredFailures = postFixReport.requiredFailures;
    report.summary = postFixReport.summary;
  }

  const exitCode = resolveExitCode({
    requiredFailureCount:
      report.requiredFailures.dependencies.length +
      report.requiredFailures.managedFiles.length,
    executionError,
  });

  const payload = buildPayload({
    mode,
    checks: report.checks,
    summary: report.summary,
    requiredFailures: report.requiredFailures,
    executionError,
    exitCode,
  });

  if (json) {
    console.log(JSON.stringify(payload, null, 2));
  } else {
    printSetupHuman(payload);
  }

  return exitCode;
}

function runDoctor(args) {
  const parsed = parseCommandFlags("doctor", args);
  if (parsed.error) {
    printUsageError(parsed.error);
    return EXIT_CODES.USAGE_ERROR;
  }

  if (parsed.flags.has("--help")) {
    printDoctorHelp();
    return EXIT_CODES.OK;
  }

  const mode = parsed.flags.has("--fix") ? "fix" : "check";
  const json = parsed.flags.has("--json");

  const report = evaluateDoctorReport();
  let executionError = null;

  if (mode === "fix") {
    if (!parsed.flags.has("--yes")) {
      printUsageError("--fix requires --yes (non-interactive mutation gate).");
      return EXIT_CODES.USAGE_ERROR;
    }

    executionError = remediateMissingDependencies(report.missingDependencies, { json });

    const postFixReport = evaluateDoctorReport();
    report.checks = postFixReport.checks;
    report.missingDependencies = postFixReport.missingDependencies;
    report.requiredFailures = postFixReport.requiredFailures;
    report.summary = postFixReport.summary;
  }

  const requiredFailureCount =
    report.requiredFailures.managedFiles.length +
    report.requiredFailures.dependencies.length;

  const exitCode = resolveExitCode({ requiredFailureCount, executionError });

  const payload = buildPayload({
    mode,
    checks: report.checks,
    summary: report.summary,
    requiredFailures: report.requiredFailures,
    executionError,
    exitCode,
  });

  if (json) {
    console.log(JSON.stringify(payload, null, 2));
  } else {
    printDoctorHuman(payload);
  }

  return exitCode;
}

function parseCommandFlags(subcommand, args) {
  const normalized = args.map((arg) => (arg === "-h" ? "--help" : arg));

  const allowedByCommand = {
    setup: new Set(["--check", "--fix", "--yes", "--json", "--help"]),
    doctor: new Set(["--fix", "--yes", "--json", "--help"]),
  };

  const flags = new Set();
  const allowed = allowedByCommand[subcommand];

  for (const arg of normalized) {
    if (!arg.startsWith("-")) {
      return { error: `Unexpected positional argument for ${subcommand}: ${arg}` };
    }

    if (!allowed.has(arg)) {
      return { error: `Unknown or unsupported flag for ${subcommand}: ${arg}` };
    }

    flags.add(arg);
  }

  if (subcommand === "setup") {
    if (flags.has("--check") && flags.has("--fix")) {
      return { error: "--check and --fix cannot be used together." };
    }
    if (flags.has("--yes") && !flags.has("--fix")) {
      return { error: "--yes is only valid with --fix." };
    }
  }

  if (subcommand === "doctor") {
    if (flags.has("--yes") && !flags.has("--fix")) {
      return { error: "--yes is only valid with --fix." };
    }
  }

  return { flags };
}

function evaluateDependencyReport() {
  const checks = buildDependencyChecks();
  const summary = buildSummary(checks);
  const requiredFailures = {
    managedFiles: [],
    dependencies: checks.filter((c) => c.required && !c.ok).map((c) => c.label),
  };
  const missingDependencies = checks.filter((c) => !c.ok).map((c) => c.key);

  return { checks, summary, requiredFailures, missingDependencies };
}

function evaluateDoctorReport() {
  const checks = [];
  const mcpServers = parseMcpServers();

  checks.push(
    createCheck("Core Files", "~/.claude/CLAUDE.md", {
      required: true,
      domain: "managedFiles",
      ok: checkFile(`${HOME}/.claude/CLAUDE.md`),
    }),
    createCheck("Core Files", "~/.claude/settings.json", {
      required: true,
      domain: "managedFiles",
      ok: checkFile(`${HOME}/.claude/settings.json`),
    }),
    createCheck("Rules", "~/.claude/rules/critical-actions.md", {
      required: true,
      domain: "managedFiles",
      ok: checkFile(`${HOME}/.claude/rules/critical-actions.md`),
    }),
    createCheck("Rules", "~/.claude/rules/security.md", {
      required: true,
      domain: "managedFiles",
      ok: checkFile(`${HOME}/.claude/rules/security.md`),
    }),
    createCheck("Rules", "~/.claude/rules/code-style.md", {
      required: true,
      domain: "managedFiles",
      ok: checkFile(`${HOME}/.claude/rules/code-style.md`),
    }),
    createCheck("Rules", "~/.claude/rules/language.md", {
      required: false,
      domain: "managedFiles",
      ok: checkFile(`${HOME}/.claude/rules/language.md`),
      note: "(optional)",
    }),
    createCheck("Scripts", "~/.claude/scripts/verify.sh", {
      required: true,
      domain: "managedFiles",
      ok: checkExecutable(`${HOME}/.claude/scripts/verify.sh`),
    }),
    createCheck("Scripts", "~/.claude/scripts/runtime/detect.sh", {
      required: true,
      domain: "managedFiles",
      ok: checkExecutable(`${HOME}/.claude/scripts/runtime/detect.sh`),
    }),
    createCheck("Skills", "~/.claude/skills/", {
      required: true,
      domain: "managedFiles",
      ok: checkFile(`${HOME}/.claude/skills/`),
    }),
    createCheck("MCP Servers", "context7", {
      required: true,
      domain: "managedFiles",
      ok: mcpServers.includes("context7"),
    }),
    createCheck("MCP Servers", "sequential-thinking", {
      required: true,
      domain: "managedFiles",
      ok: mcpServers.includes("sequential-thinking"),
    }),
    createCheck("MCP Servers", "perplexity", {
      required: false,
      domain: "managedFiles",
      ok: mcpServers.includes("perplexity"),
      note: "(optional — set API key)",
    })
  );

  for (const depCheck of buildDependencyChecks()) {
    checks.push(depCheck);
  }

  const summary = buildSummary(checks);

  const requiredFailures = {
    managedFiles: checks
      .filter((c) => c.domain === "managedFiles" && c.required && !c.ok)
      .map((c) => c.label),
    dependencies: checks
      .filter((c) => c.domain === "dependencies" && c.required && !c.ok)
      .map((c) => c.label),
  };

  const missingDependencies = checks
    .filter((c) => c.domain === "dependencies" && !c.ok)
    .map((c) => c.key);

  return { checks, summary, requiredFailures, missingDependencies };
}

function createCheck(section, label, { required, domain, ok, note, key }) {
  return {
    section,
    label,
    required,
    domain,
    ok,
    note: note || null,
    key: key || null,
  };
}

function buildDependencyChecks() {
  const policy = getDependencyPolicy();

  return policy.map((dep) => {
    const installed = commandExists(dep.command);
    const remediation = remediationPlanForDependency(dep, {
      platform: process.platform,
      commandExists,
    });

    let note;
    if (installed) {
      note = null;
    } else if (dep.required) {
      note = remediation.ok
        ? `(required — run: ${remediation.steps.map((s) => s.display).join(" && ")})`
        : `(required — ${remediation.message})`;
    } else {
      note = remediation.ok
        ? `(optional — run: ${remediation.steps.map((s) => s.display).join(" && ")})`
        : `(optional — ${remediation.message})`;
    }

    return createCheck("Dependencies", dep.label, {
      required: dep.required,
      domain: "dependencies",
      ok: installed,
      note,
      key: dep.key,
    });
  });
}

function buildSummary(checks) {
  const summary = { pass: 0, fail: 0, warn: 0 };

  for (const check of checks) {
    if (check.ok) {
      summary.pass += 1;
      continue;
    }

    if (check.required) {
      summary.fail += 1;
    } else {
      summary.warn += 1;
    }
  }

  return summary;
}

function remediateMissingDependencies(missingKeys, { json }) {
  for (const key of missingKeys) {
    const dep = getDependencyByKey(key);
    if (!dep) continue;

    const plan = remediationPlanForDependency(dep, {
      platform: process.platform,
      commandExists,
    });

    if (!plan.ok) {
      return {
        type: plan.errorType || "unsupported_runtime",
        message: plan.message,
        dependency: dep.key,
      };
    }

    for (const step of plan.steps) {
      if (!json) {
        console.log(`→ Fixing ${dep.label}: ${step.display}`);
      }

      const run = spawnSync(step.command, step.args, {
        stdio: json ? "pipe" : "inherit",
        env: process.env,
      });

      if (run.error) {
        return {
          type: "command_failed",
          message: run.error.message,
          command: step.display,
          dependency: dep.key,
        };
      }

      if (run.status !== 0) {
        return {
          type: "command_failed",
          message: `Command exited with status ${run.status}`,
          command: step.display,
          dependency: dep.key,
        };
      }
    }
  }

  return null;
}

function resolveExitCode({ requiredFailureCount, executionError }) {
  if (executionError) return EXIT_CODES.EXECUTION_FAILED;
  if (requiredFailureCount > 0) return EXIT_CODES.CHECK_FAILED;
  return EXIT_CODES.OK;
}

function buildPayload({ mode, checks, summary, requiredFailures, executionError, exitCode }) {
  return {
    mode,
    exitCode,
    result: resultLabelForExit(exitCode),
    summary,
    requiredFailures,
    executionError: executionError || null,
    checks: checks.map((check) => ({
      section: check.section,
      label: check.label,
      required: check.required,
      domain: check.domain,
      ok: check.ok,
      note: check.note,
    })),
  };
}

function resultLabelForExit(exitCode) {
  if (exitCode === EXIT_CODES.OK) return "ok";
  if (exitCode === EXIT_CODES.CHECK_FAILED) return "check_failed";
  if (exitCode === EXIT_CODES.USAGE_ERROR) return "usage_error";
  return "execution_failed";
}

function printSetupHelp() {
  console.log(`Usage: cpmm setup [--check|--fix] [--yes] [--json]

Flags:
  --check  Read-only dependency check (default)
  --fix    Attempt dependency fixes
  --yes    Required with --fix
  --json   JSON output
`);
}

function printDoctorHelp() {
  console.log(`Usage: cpmm doctor [--fix] [--yes] [--json]

Flags:
  --fix    Attempt dependency fixes (managed files remain read-only)
  --yes    Required with --fix
  --json   JSON output
`);
}

function printSetupHuman(payload) {
  console.log(`CPMM Setup v${pkg.version}\n`);
  printGroupedChecks(payload.checks);
  const total = payload.summary.pass + payload.summary.fail + payload.summary.warn;
  console.log(`\nResult: ${payload.summary.pass}/${total} passed, ${payload.summary.warn} optional skipped`);

  if (payload.requiredFailures.dependencies.length > 0) {
    console.log("\nRequired dependencies missing:");
    for (const item of payload.requiredFailures.dependencies) {
      console.log(`  - ${item}`);
    }
  }

  if (payload.executionError) {
    console.log(`\nExecution error: ${payload.executionError.type}`);
    console.log(`  ${payload.executionError.message}`);
    if (payload.executionError.command) {
      console.log(`  command: ${payload.executionError.command}`);
    }
  }
}

function printDoctorHuman(payload) {
  console.log(`CPMM Doctor v${pkg.version}\n`);
  printGroupedChecks(payload.checks);
  const total = payload.summary.pass + payload.summary.fail + payload.summary.warn;
  console.log(`\nResult: ${payload.summary.pass}/${total} passed, ${payload.summary.warn} optional skipped`);

  if (payload.requiredFailures.managedFiles.length > 0 || payload.requiredFailures.dependencies.length > 0) {
    console.log("\nRequired failures:");
    if (payload.requiredFailures.managedFiles.length > 0) {
      console.log("  managedFiles:");
      for (const item of payload.requiredFailures.managedFiles) {
        console.log(`    - ${item}`);
      }
    }
    if (payload.requiredFailures.dependencies.length > 0) {
      console.log("  dependencies:");
      for (const item of payload.requiredFailures.dependencies) {
        console.log(`    - ${item}`);
      }
    }
  }

  if (payload.executionError) {
    console.log(`\nExecution error: ${payload.executionError.type}`);
    console.log(`  ${payload.executionError.message}`);
    if (payload.executionError.command) {
      console.log(`  command: ${payload.executionError.command}`);
    }
  }
}

function printGroupedChecks(checks) {
  const sectionOrder = [
    "Core Files",
    "Rules",
    "Scripts",
    "Skills",
    "MCP Servers",
    "Dependencies",
  ];

  for (const section of sectionOrder) {
    const sectionChecks = checks.filter((check) => check.section === section);
    if (sectionChecks.length === 0) continue;

    console.log(`${section}:`);
    for (const check of sectionChecks) {
      const symbol = check.ok ? "✓" : check.required ? "✗" : "⚠";
      const base = `  ${symbol} ${check.label}`;
      if (check.ok || !check.note) {
        console.log(base);
      } else {
        console.log(base.padEnd(46) + check.note);
      }
    }

    console.log("");
  }
}

function buildFilteredEnv() {
  const allowed = [
    "PATH",
    "HOME",
    "SHELL",
    "USER",
    "TERM",
    "LANG",
    "LC_ALL",
    "TMPDIR",
    "XDG_CONFIG_HOME",
  ];

  return Object.fromEntries(
    allowed
      .filter((key) => process.env[key] !== undefined)
      .map((key) => [key, process.env[key]])
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

function commandExists(binName) {
  const pathValue = process.env.PATH || "";
  const paths = pathValue.split(path.delimiter).filter(Boolean);

  for (const dir of paths) {
    const fullPath = path.join(dir, binName);
    try {
      fs.accessSync(fullPath, fs.constants.X_OK);
      return true;
    } catch {
      // continue
    }
  }

  return false;
}

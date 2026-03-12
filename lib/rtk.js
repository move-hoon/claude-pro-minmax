"use strict";

const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { execSync, spawnSync } = require("node:child_process");

const RTK_INSTALL_URL = "https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh";
const RTK_DOCS_URL = "https://github.com/rtk-ai/rtk/blob/main/docs/INSTALL.md";
const CPMM_HOOK_NAME = "critical-action-check.sh";
const RTK_HOOK_NAME = "rtk-rewrite.sh";

function commandExists(cmd) {
  try {
    execSync(`command -v ${cmd}`, { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

function runCommand(bin, args, label) {
  const rendered = [bin, ...args].join(" ");
  console.log(`  $ ${rendered}`);
  const result = spawnSync(bin, args, { stdio: "inherit", env: { ...process.env } });
  if (result.status !== 0) {
    console.error(`  FAIL: ${label} (exit ${result.status})`);
    return false;
  }
  return true;
}

function getRtkManualInstallHints() {
  return [
    "RTK is optional. CPMM setup will continue without it.",
    "Install RTK manually with one of these upstream-supported methods:",
    "  - brew install rtk",
    `  - curl -fsSL ${RTK_INSTALL_URL} | sh`,
    `  - Docs: ${RTK_DOCS_URL}`,
  ];
}

function attemptRtkInstall() {
  if (commandExists("rtk")) {
    return {
      ok: true,
      outcome: "already_installed",
      method: "existing",
      message: "RTK already installed.",
    };
  }

  if (commandExists("brew")) {
    const ok = runCommand("brew", ["install", "rtk"], "rtk (brew)");
    if (ok) {
      return {
        ok: true,
        outcome: "installed",
        method: "brew",
        message: "RTK installed via Homebrew.",
      };
    }
  }

  if (commandExists("curl")) {
    const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "cpmm-rtk-"));
    const scriptPath = path.join(tempDir, "install.sh");
    try {
      const downloaded = runCommand("curl", ["-fsSL", RTK_INSTALL_URL, "-o", scriptPath], "rtk installer download");
      const installed = downloaded ? runCommand("sh", [scriptPath], "rtk installer") : false;
      return {
        ok: installed,
        outcome: installed ? "installed" : "manual_action_required",
        method: "curl",
        message: installed ? "RTK installed via upstream installer." : "RTK upstream installer failed.",
      };
    } finally {
      fs.rmSync(tempDir, { recursive: true, force: true });
    }
  }

  return {
    ok: false,
    outcome: "manual_action_required",
    method: "manual",
    message: "No supported automatic RTK installer found.",
  };
}

function matcherIncludesBash(matcher) {
  return String(matcher || "")
    .split("|")
    .map((token) => token.trim())
    .includes("Bash");
}

function flattenBashHooks(settings) {
  const entries = Array.isArray(settings?.hooks?.PreToolUse) ? settings.hooks.PreToolUse : [];
  const flattened = [];

  entries.forEach((entry, entryIndex) => {
    if (!matcherIncludesBash(entry?.matcher)) return;
    const hooks = Array.isArray(entry?.hooks) ? entry.hooks : [];
    hooks.forEach((hook, hookIndex) => {
      flattened.push({
        entryIndex,
        hookIndex,
        command: String(hook?.command || ""),
        timeout: hook?.timeout,
      });
    });
  });

  return flattened;
}

function inspectRtkStatus(settingsPath) {
  const result = {
    binaryInstalled: commandExists("rtk"),
    settingsPath,
    cpmmHookFound: false,
    hookEnabled: false,
    orderOk: null,
    timeoutValue: null,
    timeoutOk: null,
    failReason: null,
    warnings: [],
  };

  if (!fs.existsSync(settingsPath)) {
    result.failReason = "missing_settings_json";
    return result;
  }

  let parsed;
  try {
    parsed = JSON.parse(fs.readFileSync(settingsPath, "utf8"));
  } catch {
    result.failReason = "invalid_settings_json";
    return result;
  }

  const hooks = flattenBashHooks(parsed);
  const cpmmIndex = hooks.findIndex((hook) => hook.command.includes(CPMM_HOOK_NAME));
  if (cpmmIndex === -1) {
    result.failReason = "missing_cpmm_hook";
    return result;
  }

  result.cpmmHookFound = true;

  const rtkIndex = hooks.findIndex((hook) => hook.command.includes(RTK_HOOK_NAME));
  if (rtkIndex === -1) {
    return result;
  }

  result.hookEnabled = true;
  result.orderOk = cpmmIndex < rtkIndex;
  if (!result.orderOk) {
    result.failReason = "rtk_precedes_cpmm";
  }

  const rtkHook = hooks[rtkIndex];
  result.timeoutValue = typeof rtkHook.timeout === "number" ? rtkHook.timeout : null;
  result.timeoutOk = result.timeoutValue === 10;
  if (!result.timeoutOk) {
    result.warnings.push("rtk_timeout_not_10");
  }

  return result;
}

module.exports = {
  RTK_DOCS_URL,
  RTK_INSTALL_URL,
  attemptRtkInstall,
  getRtkManualInstallHints,
  inspectRtkStatus,
};

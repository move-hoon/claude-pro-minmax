"use strict";

const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { execSync, spawnSync } = require("node:child_process");

const RTK_INSTALL_URL = "https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh";
const RTK_DOCS_URL = "https://github.com/rtk-ai/rtk/blob/main/docs/INSTALL.md";
const CPMM_HOOK_NAME = "critical-action-check.sh";
const RTK_HOOK_NAME = "rtk-rewrite.sh";
const RTK_HOOK_COMMAND = "~/.claude/hooks/rtk-rewrite.sh";
const RTK_HOOK_TIMEOUT = 10;

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

function cloneJson(value) {
  return JSON.parse(JSON.stringify(value));
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

function normalizeManagedRtkHookSettings(settings) {
  const source = settings && typeof settings === "object" ? settings : {};
  const next = cloneJson(source);
  if (!next.hooks || typeof next.hooks !== "object") next.hooks = {};
  const preToolUse = Array.isArray(next.hooks.PreToolUse) ? next.hooks.PreToolUse : [];
  next.hooks.PreToolUse = preToolUse;

  let cpmmEntryIndex = -1;
  let cpmmHookIndex = -1;

  preToolUse.forEach((entry, entryIndex) => {
    if (!matcherIncludesBash(entry?.matcher)) return;
    const hooks = Array.isArray(entry?.hooks) ? entry.hooks : [];
    const foundIndex = hooks.findIndex((hook) => String(hook?.command || "").includes(CPMM_HOOK_NAME));
    if (foundIndex !== -1 && cpmmEntryIndex === -1) {
      cpmmEntryIndex = entryIndex;
      cpmmHookIndex = foundIndex;
    }
  });

  if (cpmmEntryIndex === -1 || cpmmHookIndex === -1) {
    return {
      ok: false,
      failReason: "missing_cpmm_hook",
      changed: false,
      settings: next,
    };
  }

  next.hooks.PreToolUse = preToolUse
    .map((entry, entryIndex) => {
      if (!matcherIncludesBash(entry?.matcher)) return entry;
      const hooks = Array.isArray(entry?.hooks) ? entry.hooks : [];
      const filteredHooks = hooks.filter((hook) => !String(hook?.command || "").includes(RTK_HOOK_NAME));
      return {
        ...entry,
        hooks: filteredHooks,
        __cpmmEntry: entryIndex === cpmmEntryIndex,
      };
    })
    .filter((entry) => {
      if (!matcherIncludesBash(entry?.matcher)) return true;
      if (entry.__cpmmEntry) return true;
      return Array.isArray(entry?.hooks) && entry.hooks.length > 0;
    })
    .map((entry) => {
      const { __cpmmEntry, ...rest } = entry;
      return rest;
    });

  const canonicalEntry = next.hooks.PreToolUse.find((entry) => {
    if (!matcherIncludesBash(entry?.matcher)) return false;
    const hooks = Array.isArray(entry?.hooks) ? entry.hooks : [];
    return hooks.some((hook) => String(hook?.command || "").includes(CPMM_HOOK_NAME));
  });

  if (!canonicalEntry) {
    return {
      ok: false,
      failReason: "missing_cpmm_hook",
      changed: false,
      settings: next,
    };
  }

  const canonicalHooks = Array.isArray(canonicalEntry.hooks) ? canonicalEntry.hooks : [];
  const canonicalCpmmIndex = canonicalHooks.findIndex((hook) => String(hook?.command || "").includes(CPMM_HOOK_NAME));
  if (canonicalCpmmIndex === -1) {
    return {
      ok: false,
      failReason: "missing_cpmm_hook",
      changed: false,
      settings: next,
    };
  }

  const desiredRtkHook = {
    type: "command",
    command: RTK_HOOK_COMMAND,
    timeout: RTK_HOOK_TIMEOUT,
  };

  canonicalHooks.splice(canonicalCpmmIndex + 1, 0, desiredRtkHook);
  canonicalEntry.hooks = canonicalHooks;

  return {
    ok: true,
    changed: JSON.stringify(source) !== JSON.stringify(next),
    settings: next,
    failReason: null,
  };
}

function writeSettingsJsonAtomic(settingsPath, settings) {
  const tempPath = `${settingsPath}.tmp`;
  fs.writeFileSync(tempPath, `${JSON.stringify(settings, null, 2)}\n`, "utf8");
  fs.renameSync(tempPath, settingsPath);
}

function ensureRtkHookArtifact() {
  const hookPath = path.join(os.homedir(), ".claude", "hooks", RTK_HOOK_NAME);
  if (fs.existsSync(hookPath)) {
    return { ok: true, hookPath, initialized: false };
  }

  const ok = runCommand("rtk", ["init", "-g", "--hook-only", "--no-patch"], "rtk hook init");
  if (!ok || !fs.existsSync(hookPath)) {
    return {
      ok: false,
      hookPath,
      initialized: ok,
      failReason: "missing_rtk_hook_artifact",
      message: "RTK hook artifact could not be created.",
    };
  }

  return { ok: true, hookPath, initialized: true };
}

function reconcileManagedRtkHook({ enabledBeforeSetup, settingsPath }) {
  const result = {
    attempted: Boolean(enabledBeforeSetup),
    changed: false,
    ok: true,
    message: null,
    failReason: null,
  };

  if (!enabledBeforeSetup) {
    return result;
  }

  if (!commandExists("rtk")) {
    return {
      ...result,
      ok: false,
      failReason: "rtk_binary_missing",
      message: "RTK binary is not available, so CPMM could not restore the managed RTK hook.",
    };
  }

  if (!fs.existsSync(settingsPath)) {
    return {
      ...result,
      ok: false,
      failReason: "missing_settings_json",
      message: "CPMM settings.json is missing after setup.",
    };
  }

  const hookArtifact = ensureRtkHookArtifact();
  if (!hookArtifact.ok) {
    return {
      ...result,
      ok: false,
      failReason: hookArtifact.failReason || "missing_rtk_hook_artifact",
      message: hookArtifact.message || "RTK hook artifact could not be created.",
    };
  }

  let parsed;
  try {
    parsed = JSON.parse(fs.readFileSync(settingsPath, "utf8"));
  } catch {
    return {
      ...result,
      ok: false,
      failReason: "invalid_settings_json",
      message: "CPMM settings.json is invalid JSON after setup.",
    };
  }

  const normalized = normalizeManagedRtkHookSettings(parsed);
  if (!normalized.ok) {
    return {
      ...result,
      ok: false,
      failReason: normalized.failReason,
      message: "CPMM could not find its Bash safety hook while restoring RTK.",
    };
  }

  if (normalized.changed) {
    writeSettingsJsonAtomic(settingsPath, normalized.settings);
  }

  return {
    ...result,
    changed: normalized.changed,
  };
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
  result.timeoutOk = result.timeoutValue === RTK_HOOK_TIMEOUT;
  if (!result.timeoutOk) {
    result.warnings.push("rtk_timeout_not_10");
  }

  return result;
}

module.exports = {
  RTK_DOCS_URL,
  RTK_INSTALL_URL,
  RTK_HOOK_COMMAND,
  RTK_HOOK_TIMEOUT,
  attemptRtkInstall,
  getRtkManualInstallHints,
  inspectRtkStatus,
  normalizeManagedRtkHookSettings,
  reconcileManagedRtkHook,
};

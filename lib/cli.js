"use strict";

const { execSync, spawnSync } = require("node:child_process");
const path = require("node:path");
const fs = require("node:fs");
const pkg = require("../package.json");

const DEPS = [
  {
    key: "claude",
    command: "claude",
    required: false,
    installKind: "skip",
    description: "Claude Code CLI (assumed pre-installed)",
  },
  {
    key: "jq",
    command: "jq",
    required: true,
    installKind: "system",
    systemPackage: "jq",
    description: "JSON processor for CLI workflows",
  },
  {
    key: "mgrep",
    command: "mgrep",
    required: true,
    installKind: "npm",
    npmPackage: "@mixedbread/mgrep",
    postInstall: ["mgrep", "install-claude-code"],
    description: "Fast code search tool",
  },
  {
    key: "tmux",
    command: "tmux",
    required: true,
    installKind: "system",
    systemPackage: "tmux",
    description: "Terminal multiplexer for background agents",
  },
];

function commandExists(cmd) {
  try {
    execSync(`command -v ${cmd}`, { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

function detectSystemInstaller() {
  if (commandExists("brew")) return { ok: true, installer: "brew", sudo: false };
  if (commandExists("apt-get")) return { ok: true, installer: "apt-get", sudo: true };
  if (commandExists("dnf")) return { ok: true, installer: "dnf", sudo: true };
  if (commandExists("pacman")) return { ok: true, installer: "pacman", sudo: true };
  if (commandExists("apk")) return { ok: true, installer: "apk", sudo: true };
  return { ok: false };
}

function buildInstallCmd(installer, pkg, sudo) {
  const prefix = sudo ? "sudo " : "";
  switch (installer) {
    case "brew": return `brew install ${pkg}`;
    case "apt-get": return `${prefix}apt-get install -y ${pkg}`;
    case "dnf": return `${prefix}dnf install -y ${pkg}`;
    case "pacman": return `${prefix}pacman -S --noconfirm ${pkg}`;
    case "apk": return `${prefix}apk add ${pkg}`;
    default: return null;
  }
}

function runCmd(cmd, label) {
  console.log(`  $ ${cmd}`);
  const result = spawnSync("sh", ["-c", cmd], { stdio: "inherit" });
  if (result.status !== 0) {
    console.error(`  FAIL: ${label} (exit ${result.status})`);
    return false;
  }
  return true;
}

function installDep(dep) {
  if (dep.installKind === "skip") return true;

  if (dep.installKind === "npm") {
    if (!commandExists("npm")) {
      console.error(`  npm not found. Install Node.js first, then: npm i -g ${dep.npmPackage}`);
      return false;
    }
    if (!runCmd(`npm install -g ${dep.npmPackage}`, dep.key)) return false;
    if (dep.postInstall) {
      return runCmd(dep.postInstall.join(" "), `${dep.key} post-install`);
    }
    return true;
  }

  if (dep.installKind === "system") {
    const sys = detectSystemInstaller();
    if (!sys.ok) {
      const hint = process.platform === "darwin"
        ? `\n  Install Homebrew first: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
        : "";
      console.error(`  No supported package manager found. Install ${dep.systemPackage} manually.${hint}`);
      return false;
    }
    const cmd = buildInstallCmd(sys.installer, dep.systemPackage, sys.sudo);
    return runCmd(cmd, dep.key);
  }

  return false;
}

function checkDeps() {
  return DEPS.map((dep) => ({
    ...dep,
    installed: commandExists(dep.command),
  }));
}

function printStatus(results) {
  console.log("");
  for (const r of results) {
    const icon = r.installed ? "OK" : (r.required ? "MISSING" : "SKIP");
    const tag = r.required ? "[required]" : "[optional]";
    console.log(`  ${icon} ${r.key.padEnd(8)} ${tag} ${r.description}`);
  }
  console.log("");
}

function runSetup() {
  console.log(`CPMM v${pkg.version} - Setup`);

  const results = checkDeps();
  const missing = results.filter((r) => r.required && !r.installed);

  if (missing.length > 0) {
    console.log(`\nInstalling ${missing.length} missing dependency(ies)...\n`);

    for (const dep of missing) {
      console.log(`[${dep.key}] ${dep.description}`);
      if (!installDep(dep)) {
        // continue to install others
      } else {
        console.log(`  Done.\n`);
      }
    }

    const after = checkDeps();
    printStatus(after);

    const stillMissing = after.filter((r) => r.required && !r.installed);
    if (stillMissing.length > 0) {
      console.error(`${stillMissing.length} required dep(s) still missing.`);
      return 1;
    }
  } else {
    console.log("\nAll dependencies installed.");
    printStatus(results);
  }

  // Run install.sh for config files, language, and Perplexity setup
  if (!runInstallScript()) {
    return 1;
  }

  console.log("Setup complete.");
  return 0;
}

function runInstallScript() {
  const scriptPath = path.resolve(__dirname, "..", "install.sh");
  if (!fs.existsSync(scriptPath)) {
    return true;
  }
  console.log("Configuring CPMM...\n");
  const result = spawnSync("bash", [scriptPath], {
    stdio: "inherit",
    env: { ...process.env },
  });
  if (result.status !== 0) {
    console.error("Config setup had issues. Run 'bash install.sh' manually if needed.");
    return false;
  }
  return true;
}

function runDoctor() {
  console.log(`CPMM v${pkg.version} - Doctor`);

  const results = checkDeps();
  printStatus(results);

  const missing = results.filter((r) => r.required && !r.installed);
  if (missing.length > 0) {
    console.log(`Fix: cpmm setup`);
    return 1;
  }

  console.log("All checks passed.");
  return 0;
}

function printHelp() {
  console.log(`CPMM v${pkg.version}

Usage:
  cpmm setup      Install deps + configure CPMM (language, Perplexity)
  cpmm doctor     Check dependency status
  cpmm --help     Show this help
  cpmm --version  Show version
`);
}

function runCli(argv) {
  const cmd = argv[0] || "setup";

  if (cmd === "--help" || cmd === "-h" || cmd === "help") {
    printHelp();
    return 0;
  }

  if (cmd === "--version" || cmd === "-v" || cmd === "version") {
    console.log(pkg.version);
    return 0;
  }

  if (process.platform === "win32") {
    console.error("CPMM requires macOS/Linux. Windows users: use WSL.");
    return 1;
  }

  switch (cmd) {
    case "setup":
      return runSetup();
    case "doctor":
      return runDoctor();
    default:
      console.error(`Unknown command: ${cmd}\nRun 'cpmm --help' for usage.`);
      return 2;
  }
}

module.exports = { runCli };

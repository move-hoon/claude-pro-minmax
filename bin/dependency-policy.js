const dependencyPolicy = [
  {
    key: "claude",
    command: "claude",
    label: "claude",
    required: true,
    installKind: "npm",
    npmPackage: "@anthropic-ai/claude-code",
  },
  {
    key: "jq",
    command: "jq",
    label: "jq",
    required: true,
    installKind: "system",
    systemPackage: "jq",
  },
  {
    key: "mgrep",
    command: "mgrep",
    label: "mgrep",
    required: false,
    installKind: "npm",
    npmPackage: "@mixedbread/mgrep",
    postInstallSteps: [
      {
        command: "mgrep",
        args: ["install-claude-code"],
        display: "mgrep install-claude-code",
      },
    ],
  },
  {
    key: "tmux",
    command: "tmux",
    label: "tmux",
    required: false,
    installKind: "system",
    systemPackage: "tmux",
  },
];

function getDependencyPolicy() {
  return dependencyPolicy.map((item) => ({ ...item }));
}

function getDependencyByKey(key) {
  return dependencyPolicy.find((item) => item.key === key);
}

function supportedInstallers() {
  return ["brew", "apt-get", "npm"];
}

function resolveSystemInstaller(platform, commandExists) {
  if (platform === "darwin") {
    if (commandExists("brew")) return { ok: true, installer: "brew" };
    return {
      ok: false,
      errorType: "unsupported_installer",
      message: "Homebrew (brew) is required on macOS for system package fixes.",
    };
  }

  if (platform === "linux") {
    if (commandExists("apt-get")) return { ok: true, installer: "apt-get" };
    return {
      ok: false,
      errorType: "unsupported_installer",
      message: "Only apt-get is supported for system package fixes in v1.",
    };
  }

  return {
    ok: false,
    errorType: "unsupported_runtime",
    message: `Unsupported platform for automatic fixes: ${platform}`,
  };
}

function buildSystemStep(installer, pkg, commandExists) {
  if (installer === "brew") {
    return {
      ok: true,
      step: {
        command: "brew",
        args: ["install", pkg],
        display: `brew install ${pkg}`,
      },
    };
  }

  if (installer === "apt-get") {
    if (typeof process.getuid === "function" && process.getuid() === 0) {
      return {
        ok: true,
        step: {
          command: "apt-get",
          args: ["install", "-y", pkg],
          display: `apt-get install -y ${pkg}`,
        },
      };
    }

    if (commandExists("sudo")) {
      return {
        ok: true,
        step: {
          command: "sudo",
          args: ["apt-get", "install", "-y", pkg],
          display: `sudo apt-get install -y ${pkg}`,
        },
      };
    }

    return {
      ok: false,
      errorType: "unsupported_runtime",
      message: "sudo is required for apt-get fixes when not running as root.",
    };
  }

  return {
    ok: false,
    errorType: "unsupported_installer",
    message: `Unsupported installer: ${installer}`,
  };
}

function remediationPlanForDependency(dep, { platform, commandExists }) {
  if (dep.installKind === "npm") {
    if (!commandExists("npm")) {
      return {
        ok: false,
        errorType: "unsupported_runtime",
        message: "npm is required for npm-based dependency fixes.",
      };
    }

    const steps = [
      {
        command: "npm",
        args: ["install", "-g", dep.npmPackage],
        display: `npm install -g ${dep.npmPackage}`,
      },
    ];

    for (const step of dep.postInstallSteps || []) {
      steps.push({
        command: step.command,
        args: step.args.slice(),
        display: step.display,
      });
    }

    return { ok: true, steps, installer: "npm" };
  }

  if (dep.installKind === "system") {
    const installerResult = resolveSystemInstaller(platform, commandExists);
    if (!installerResult.ok) return installerResult;

    const stepResult = buildSystemStep(
      installerResult.installer,
      dep.systemPackage,
      commandExists
    );
    if (!stepResult.ok) return stepResult;

    return {
      ok: true,
      steps: [stepResult.step],
      installer: installerResult.installer,
    };
  }

  return {
    ok: false,
    errorType: "unsupported_runtime",
    message: `Unknown install kind for dependency '${dep.key}'.`,
  };
}

module.exports = {
  getDependencyPolicy,
  getDependencyByKey,
  supportedInstallers,
  remediationPlanForDependency,
};

> **[한국어 버전](README.ko.md)**

<!-- Badges -->
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Claude Code](https://img.shields.io/badge/Claude_Code-Compatible-purple.svg)
![Pro Plan](https://img.shields.io/badge/Pro_Plan-Optimized-green.svg)

# Claude Pro MinMax (CPMM)

> **Minimum Tokens, Maximum Intelligence. Beyond the Quota limits.**

A Claude Code configuration optimized for Pro Plan constraints.

---

> [!TIP]
> **🚀 3-Second Summary: Why use this?**
> 1.  **Quota Protection:** Prevents mindless parallel execution and enforces **sequential execution** to save tokens.
> 2.  **Cost Optimization:** Uses a combination of **Haiku (Implementation) + Sonnet (Design)** instead of the expensive Opus.
> 3.  **Zero-Cost Automation:** Provides safety guards with **11 local hooks** that don't use the API.

---

## 🛠 Installation

### 1. Prerequisites
```bash
npm install -g @anthropic-ai/claude-code
npm install -g @mixedbread/mgrep
mgrep install-claude-code
brew install jq   # macOS (Linux: sudo apt-get install jq)
```

### 2. One-Line Install
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/move-hoon/claude-pro-minmax/main/install.sh)"
```

### 3. Post-Install Configuration (Optional)
**The installation script will ask for your Perplexity API Key.**
If you skipped it during installation, you can set it up manually:
1. Open `~/.claude.json`.
2. Add the following to the `mcpServers` object:
   ```json
   "perplexity": {
     "command": "npx",
     "args": ["-y", "@perplexity-ai/mcp-server"],
     "env": {
       "PERPLEXITY_API_KEY": "YOUR_API_KEY_HERE"
     }
   }
   ```

> **Other included MCP servers (Enabled by default):**
> - **Sequential Thinking**: Powerful reasoning tool for complex logic.
> - **Context7**: Advanced documentation fetching and context management.

> **Note:** The installation script automatically backs up your existing `~/.claude` settings (`~/.claude-backup-{timestamp}`).

### 4. Project Initialization
> **Tip:** Before running `claude`, set up `.claude/CLAUDE.md` and `.claude/settings.json` by referencing the templates in `~/.claude/project-templates/`. This ensures optimizations are active from the start.

---

## Problem Definition

Claude Pro Plan has constraints that fundamentally change how you should use Claude Code:

- **5-Hour Rolling Reset**: Usage resets every 5 hours, encouraging short and focused sessions.
- **Message-Based Quota (Length-Sensitive)**: As the conversation gets longer (as context accumulates), the quota deducted per message increases exponentially. ([Claude Help Center](https://support.anthropic.com/en/articles/8325606-what-is-claude-pro))
- **Weekly Limits**: Additional weekly caps are applied to heavy users.

The original [everything-claude-code](https://github.com/affaan-m/everything-claude-code) is a powerful tool optimized for the near-unlimited **Max Plan** environment. However, blindly following "high-output" patterns like parallel agents or multi-instances on the **Pro Plan** will lead to rapid quota depletion due to acute context accumulation.

This project maintains powerful features while redesigning the architecture to fit Pro Plan constraints.

---

## Core Strategy

### 1. Goal
**Maximize session sustainability within Pro Plan's 5-hour Quota window.**

This configuration is designed to extend productive work time by reducing Quota consumption per task. The goal is not "limit bypass," but **resource efficiency optimization** to work longer without exhausting the allocation.

### 2. Approach
While Anthropic hasn't disclosed the exact algorithm, Quota consumption is affected by the following three factors. This project optimizes all of them.

* **Context Size (Input Tokens):** Deduplication through sequential execution.
* **Response Length (Output Tokens):** Reduction via CLI filtering.
* **Model Type (Compute Cost):** Strategic model selection.

### 3. Execution Strategy: Atomic Workflow & Sequential Execution

1.  **Atomic Task Execution**
    * Each task completes one full cycle. (Plan → Build → Review → Save)
    * Executes an agent once per phase (no iterative re-calls).
    * Moves cleanly to the next task after cycle completion.

2.  **Cost Minimization per Task**
    * `@builder` (Haiku): Handles implementation (lowest resource consumption based on API pricing).
    * `@planner` (Sonnet): Architecture design (balanced capability and cost).
    * **Opus**: Escalation only when necessary (most expensive based on API pricing).

3.  **Context Size Reduction**
    * **Sequential Execution:** Prevents context duplication by running only one agent at a time. (Prohibits 3~4 parallel executions)
    * **Interruptible:** Can be stopped at any time between tasks.
    * **CLI Filtering:** Drastically reduces tool output tokens.

4.  **Safe Escalation Path (Safety Ladder)**
    * Haiku failure (after 2 retries) → Escalate to Sonnet (`/do-sonnet`).
    * Sonnet failure → Escalate to Opus (`/do-opus`).
    * Makes cost apparent through explicit model selection.

---

## 📊 Results and Comparison

**What this configuration enables:**
✅ Significantly longer sessions compared to parallel execution.
✅ Predictable usage patterns (ease of task planning).
✅ High success rate through strategic escalation.

> [!NOTE]
> **Note:** Anthropic's exact Quota algorithm is private. This configuration is an optimization based on API pricing and token patterns; actual results may vary depending on task complexity.

### Quota Exhaustion Simulation

```mermaid
gantt
    title ⚡️ Quota Consumption: Parallel (Burst) vs Sequential (Efficient)
    dateFormat HH:mm
    axisFormat %H:%M
    todayMarker off

    section 🔴 Existing (Parallel Execution)
    Agent 1 (Sonnet)      :crit, a1, 00:00, 45m
    Agent 2 (Haiku)       :crit, a2, 00:00, 45m
    Agent 3 (Reviewer)    :crit, a3, 00:00, 45m
    💥 Quota Depleted (45 min) :milestone, 00:45, 0m

    section 🟢 CPMM (Sequential Execution)
    Task 1 (Plan+Build)   :active, s1, 00:00, 1h
    Task 2 (Refactor)     :s2, after s1, 1h
    Task 3 (Test+Fix)     :s3, after s2, 1h
    Task 4 (New Feature)  :s4, after s3, 1h
    ✅ 5-Hour Survival Complete :milestone, 05:00, 0m
```

---



## 🚀 Quick Start

### 🤖 Agent Workflow

CPMM automatically moves between Sonnet (Design) and Haiku (Implementation) based on task complexity to achieve optimal efficiency.

```mermaid
flowchart LR
    Start([User Request]) --> Cmd{Command?}
    
    Cmd -->|/plan| Plan[/"@planner (Sonnet)"/]
    Cmd -->|/do| Build[/"@builder (Haiku)"/]
    
    Plan -->|Blueprint| Build
    Build -- "Success" --> Review[/"@reviewer (Haiku)"/]
    Build -- "Failure (2x)" --> Escalate("🚨 Escalate to Sonnet")
    
    Review --> Done([Done])
    Escalate -.-> Review

    classDef planner fill:#c8e6c9,stroke:#2e7d32,stroke-width:2px;
    classDef builder fill:#bbdefb,stroke:#1565c0,stroke-width:2px;
    classDef reviewer fill:#ffe0b2,stroke:#ef6c00,stroke-width:2px;
    classDef escalate fill:#ffcdd2,stroke:#b71c1c,stroke-width:2px;
    classDef done fill:#e0e0e0,stroke:#9e9e9e,stroke-width:2px,font-weight:bold;

    class Plan planner;
    class Build builder;
    class Review reviewer;
    class Escalate escalate;
    class Done done;
```

### ⌨️ Command Guide

**1. Core Commands**

Essential commands used most frequently.

| Command | Description | Recommended Situation |
| --- | --- | --- |
| `/do [task]` | Rapid implementation with **Haiku** | Simple bug fixes, script writing |
| `/plan [task]` | **Sonnet** Design → **Haiku** Implementation | Feature additions, refactoring, complex logic |
| `/review [target]` | **Haiku** (Read-only) | Code review (Specify file or directory) |

<details>
<summary><strong>🚀 Advanced Commands - Click to Expand</strong></summary>

Full command list for more sophisticated tasks or session management.

| Command | Description | Recommended Situation |
| :--- | :--- | :--- |
| **🧠 Deep Execution** | | |
| `/dplan [task]` | **Sonnet** + Perplexity, Sequential Thinking, Context7 | Library comparison, latest tech research (Deep Research) |
| `/do-sonnet` | Execute directly with **Sonnet** | Manual escalation when Haiku keeps failing |
| `/do-opus` | Execute directly with **Opus** | Resolving extremely complex problems (Cost caution) |
| **💾 Session/Context** | | |
| `/session-save` | Summarize and save session | When pausing work (Auto-removal of secrets) |
| `/session-load` | Load session | Resuming previous work |
| `/compact-phase` | Step-by-step context compaction | When token cleanup is needed mid-session |
| `/load-context` | Load context templates | Initial setup for frontend/backend |
| **🛠️ Utility** | | |
| `/learn` | Learn and save patterns | Registering frequently recurring errors or preferred styles |
| `/analyze-failures`| Analyze error logs | Identifying causes of recurring errors |
| `/watch` | Process monitoring (tmux) | Observing long-running builds/tests |
| `/llms-txt` | Fetch documentation | Loading official library docs in LLM format |

</details>

---

## 📚 Documentation Hub

This project provides detailed documentation for each component. Refer to the links below for specific operating principles and customization methods.

| Category | Description | Detailed Docs (Click) |
| :--- | :--- | :--- |
| **🤖 Agents** | Definitions of roles and prompts for Planner, Builder, Reviewer, etc. | [📂 **Agents Guide**](.claude/agents/README.md) |
| **🕹️ Commands** | Usage of 14 commands including /plan, /do, /review | [📂 **Commands Guide**](.claude/commands/README.md) |
| **🪝 Hooks** | Logic of 11 automation scripts including Pre-check, Auto-format | [📂 **Hooks Guide**](scripts/hooks/README.md) |
| **📏 Rules** | Policies for Security, Code Style, Critical Actions | [📂 **Rules Guide**](.claude/rules/README.md) |
| **🧠 Skills** | Technical specifications for tools like CLI Wrappers | [📂 **Skills Guide**](.claude/skills/README.md) |
| **🔧 Contexts** | Context templates for Backend/Frontend projects | [📂 **Contexts Guide**](.claude/contexts/README.md) |
| **💾 Sessions** | Structure for session summary storage and management | [📂 **Sessions Guide**](.claude/sessions/README.md) |
| **🛠️ Scripts** | Collection of general-purpose scripts for Verify, Build, Test | [📂 **Scripts Guide**](scripts/README.md) |
| **⚙️ Runtime** | Automatic project language/framework detection system | [📂 **Runtime Guide**](scripts/runtime/README.md) |
| **🔌 Adapters** | Details on build adapters by language (Java, Node, Go, etc.) | [📂 **Adapters Guide**](scripts/runtime/adapters/README.md) |
| **🎓 Learned** | Pattern data accumulated through the /learn command | [📂 **Learned Skills**](.claude/skills/learned/README.md) |

---

## 📂 Project Structure

<details>
<summary><strong>📁 View File Tree (Click to Expand)</strong></summary>

```text
claude-pro-devkit
├── .claude.json                # Global MCP Settings (User Scope)
├── install.sh                  # One-click installation script
├── README.md                   # English Documentation
├── README.ko.md                # Korean Documentation
├── USER-MANUAL.md              # Detailed User Manual (English)
├── USER-MANUAL.ko.md           # Detailed User Manual (Korean)
├── .claude/
│   ├── CLAUDE.md               # Core Instructions (Loaded in all sessions)
│   ├── settings.json           # Project Settings (Permissions, hooks, env vars)
│   ├── settings.local.json     # Local user settings (Excluded from Git)
│   ├── agents/                 # Agent Definitions
│   │   ├── planner.md          # Sonnet: Architecture and design decisions
│   │   ├── dplanner.md         # Sonnet+MCP: Deep planning utilizing external tools
│   │   ├── builder.md          # Haiku: Code implementation and refactoring
│   │   └── reviewer.md         # Haiku: Read-only code review
│   ├── commands/               # Slash Commands
│   │   ├── plan.md             # Architecture planning (Sonnet -> Haiku)
│   │   ├── dplan.md            # Deep research planning (Sequential Thinking)
│   │   ├── do.md               # Direct execution (Default: Haiku)
│   │   ├── do-sonnet.md        # Execute with Sonnet model
│   │   ├── do-opus.md          # Execute with Opus model
│   │   ├── review.md           # Code review command (Read-only)
│   │   ├── watch.md            # File/process monitoring via tmux
│   │   ├── session-save.md     # Save current session state
│   │   ├── session-load.md     # Restore previous session state
│   │   ├── compact-phase.md    # Guide for step-by-step context compaction
│   │   ├── load-context.md     # Load pre-defined context templates
│   │   ├── learn.md            # Save new patterns to memory
│   │   ├── analyze-failures.md # Analyze tool failure logs
│   │   └── llms-txt.md         # View LLM-optimized documentation
│   ├── rules/                  # Behavioral Rules
│   │   ├── critical-actions.md # Block dangerous commands (rm -rf, git push -f, etc.)
│   │   ├── code-style.md       # Coding conventions and standards
│   │   ├── security.md         # Security best practices
│   │   └── language.md         # Language constraints (e.g., Use Korean)
│   ├── skills/                 # Tool Capabilities
│   │   ├── cli-wrappers/       # Lightweight CLI wrappers (Replaces MCP overhead)
│   │   └── learned/            # Patterns accumulated through /learn command
│   ├── contexts/               # Context Templates
│   │   ├── backend-context.md  # Backend-specific instructions
│   │   └── frontend-context.md # Frontend-specific instructions
│   ├── logs/                   # Log Directory
│   │   └── tool-failures.log   # Tool failure records
│   └── sessions/               # Saved session summaries (Markdown)
├── scripts/                    # Utilities and Automation
│   ├── verify.sh               # General-purpose verification script
│   ├── build.sh                # General-purpose build script
│   ├── test.sh                 # General-purpose test script
│   ├── lint.sh                 # General-purpose lint script
│   ├── commit.sh               # Standardized git commit helper
│   ├── create-branch.sh        # Branch creation helper
│   ├── analyze-failures.sh     # Log analysis tool for /analyze-failures
│   ├── scrub-secrets.js        # Logic to remove secrets when saving sessions
│   ├── hooks/                  # Zero-Cost Hooks (Automated checks)
│   │   ├── critical-action-check.sh # Pre-block dangerous commands
│   │   ├── tool-failure-log.sh      # Record failure log files
│   │   ├── pre-compact.sh           # Compaction pre-processor
│   │   ├── compact-suggest.sh       # Propose compaction when threshold is reached
│   │   ├── post-edit-format.sh      # Automatic formatting after editing
│   │   ├── readonly-check.sh        # Enforce read-only for reviewer
│   │   ├── retry-check.sh           # Enforce 2-retry limit for builder
│   │   ├── session-start.sh         # Session initialization logic
│   │   ├── session-cleanup.sh       # Cleanup and secret removal on exit
│   │   ├── stop-collect-context.sh  # Collect context on interruption
│   │   └── notification.sh          # Desktop notifications
│   └── runtime/                # Runtime Auto-detection
│       ├── detect.sh           # Project type detection logic
│       └── adapters/           # Build adapters by language
│           ├── _interface.sh   # Adapter interface definition
│           ├── _template.sh    # Template for new adapters
│           ├── generic.sh      # Generic fallback adapter
│           ├── go.sh           # Go/Golang adapter
│           ├── jvm.sh          # Java/Kotlin/JVM adapter
│           ├── node.sh         # Node.js/JavaScript/TypeScript adapter
│           ├── python.sh       # Python adapter
│           └── rust.sh         # Rust adapter
└── project-templates/          # Language and Framework Templates
    ├── backend/                # Backend project template
    └── frontend/               # Frontend project template
```

</details>

## Supported Runtimes

| Runtime | Build Tool | Detection Files |
|--------|----------|----------|
| JVM | Gradle, Maven | `build.gradle.kts`, `pom.xml` |
| Node | npm, pnpm, yarn, bun | `package.json` |
| Rust | Cargo | `Cargo.toml` |
| Go | Go Modules | `go.mod` |
| Python | pip, poetry, uv | `pyproject.toml`, `requirements.txt` |

To add a new runtime, copy and implement `scripts/runtime/adapters/_template.sh`.

---

## FAQ

<details>
<summary><strong>Q: How does this configuration optimize the Pro Plan quota?</strong></summary>

A: Anthropic's exact quota algorithm is not public. However, optimization is based on the following:
- **API Price** (reflecting compute cost): Haiku is much cheaper than Sonnet/Opus.
- **Token Usage Patterns**: Reduction of input/output tokens through CLI filtering and hooks.
- **Sequential Execution**: Prevents simultaneous quota depletion by multiple agents.

It's similar to fuel efficiency: exact mileage cannot be guaranteed, but using a smaller engine (Haiku) for most tasks and avoiding high-speed driving (parallel execution) can increase driving distance.
</details>

<details>
<summary><strong>Q: Can I use Claude for the full 5 hours?</strong></summary>

A: **It is not guaranteed**. Session length depends on:
- Task complexity (simple fixes vs. large-scale refactoring).
- Model usage (mainly Haiku vs. mainly Opus).
- Context size (small files vs. entire codebase).

This configuration is designed to maximize session length within Pro Plan constraints, but it cannot bypass quota limits.
</details>

<details>
<summary><strong>Q: Can it be used on the Max Plan?</strong></summary>

A: Yes, but these optimizations may not be necessary. The Max Plan provides much higher usage limits, making Pro Plan constraints less relevant. For Max Plan users:
- Parallel agents can be safely activated without rapid quota depletion.
- Git Worktrees for simultaneous sessions are practical.
- A sequential-only strategy is less necessary.

This configuration is specifically designed for the Pro Plan's 5-hour rolling reset and message-based quota system.
</details>

<details>
<summary><strong>Q: Does it conflict with existing Claude Code settings?</strong></summary>

A: It overwrites the `~/.claude/` directory. Please back up your existing settings before installation.
</details>

<details>
<summary><strong>Q: Which OS is supported?</strong></summary>

A: macOS and Linux are supported. Windows is available through WSL.
</details>

<details>
<summary><strong>Q: Why not use Opus for all tasks?</strong></summary>

A: API pricing (reflecting compute cost), Opus is much more expensive than Sonnet or Haiku. While the exact Pro Plan quota impact is not public, using Opus for all tasks would deplete the quota much faster. Explicit model selection (`/do-opus`) is used to ensure awareness when using expensive models.
</details>

---

## Credits

- **[affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)** — Anthropic hackathon winner. The foundation of this project.
- [Claude Code Official Documentation](https://code.claude.com/docs/en/)

## Contributing

This is an open-source project. Contributions are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

## License

MIT License
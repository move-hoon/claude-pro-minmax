> **[한국어 버전](README.ko.md)**

# Runtime Detection Layer

## Purpose
OCP-compliant runtime detection for language-agnostic operations. Add new languages without modifying core scripts.

## Structure

```
runtime/
├── detect.sh         # Auto-detect project runtime
└── adapters/         # Language-specific implementations
```

## detect.sh

Automatically detects project type and outputs JSON.

**Usage:**
```bash
# Basic usage
./detect.sh
# Output: {"runtime":"node","tool":"npm","adapter":"node.sh"}

# Monorepo support (subdirectory)
./detect.sh --path backend
# Output: {"runtime":"jvm","tool":"gradle","adapter":"jvm.sh"}
```

**Detection Priority:**
1. JVM: `build.gradle.kts` > `build.gradle` > `pom.xml`
2. Node: `package.json` (then check lock files for pm)
3. Rust: `Cargo.toml`
4. Go: `go.mod`
5. Python: `pyproject.toml` > `setup.py` > `requirements.txt`
6. Generic: Fallback to Makefile

## Integration

Universal scripts use this layer:

```bash
# scripts/verify.sh
RUNTIME=$("$RUNTIME_DIR/detect.sh" "$@")
ADAPTER=$(echo "$RUNTIME" | jq -r '.adapter')
source "$RUNTIME_DIR/adapters/$ADAPTER"
adapter_verify
```

## Adding New Runtimes

Update `detect.sh` only:

```bash
# Add detection pattern
[[ -f "$dir/mix.exs" ]] && echo '{"runtime":"elixir","tool":"mix","adapter":"elixir.sh"}' && return
```

Then create the adapter in `adapters/elixir.sh`.

> **[한국어 버전](README.ko.md)**

# Adapters Directory

## Purpose
Language-specific implementations following the adapter contract. Each adapter provides a unified interface for build, test, lint operations.

## Available Adapters

| Adapter | Runtime | Build Tools | Languages |
|---------|---------|-------------|-----------|
| `jvm.sh` | JVM | Gradle, Maven | Java, Kotlin |
| `node.sh` | Node | npm, pnpm, yarn, bun | TypeScript, JavaScript |
| `go.sh` | Go | Go modules | Go |
| `rust.sh` | Rust | Cargo | Rust |
| `python.sh` | Python | pip, poetry, uv | Python |
| `generic.sh` | Generic | Makefile | Any |

## Development Utilities

| File | Purpose |
|------|---------|
| `_interface.sh` | Contract validator - verifies adapter implements all required functions |
| `_template.sh` | Adapter template - copy this to create new adapters |

## Adapter Contract

All adapters MUST implement these functions (defined in `_interface.sh`):

```bash
adapter_info()    # Return adapter metadata as JSON
adapter_verify()  # Run full verification (build + test + lint)
adapter_build()   # Build project
adapter_test()    # Run tests
adapter_lint()    # Run linter
adapter_format()  # Format code
adapter_clean()   # Clean build artifacts
```

Optional:
```bash
adapter_run()     # Run dev server
```

## Adding a New Adapter

**3 Steps (OCP - no core modifications):**

1. Copy template:
   ```bash
   cp _template.sh elixir.sh
   ```

2. Implement all `adapter_*` functions

3. Add detection pattern to `../detect.sh`:
   ```bash
   [[ -f "$dir/mix.exs" ]] && echo '{"runtime":"elixir","tool":"mix","adapter":"elixir.sh"}' && return
   ```

Done! Universal scripts automatically use the new adapter.

## Verify Adapter Compliance

```bash
./adapters/_interface.sh ./adapters/elixir.sh
# Output: ✓ Adapter implements all required functions
```

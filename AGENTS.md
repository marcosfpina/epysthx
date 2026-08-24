# Repository Guidelines

## Project Structure & Module Organization

`neutron/` contains the Python 3.13 application. Keep changes within the owning domain package, such as `api/`, `agents/`, `compliance/`, `orchestration/`, `memory/`, or `storage/`. Tests mirror those domains under `tests/`; cross-component scenarios belong in `tests/integration/`. Solidity sources and Foundry tests live in `contracts/src/` and `contracts/test/`. Operational configuration is under `config/`, `nix/`, `flake.nix`, `docker-compose.yml`, and `temporal-config/`. Use `docs/` for user and architecture documentation, `scripts/` for operational helpers, and `demos/` for runnable examples. Do not edit generated `contracts/out/`, caches, or vendored `contracts/lib/` content.

## Build, Test, and Development Commands

- `nix develop`: enter the pinned development environment.
- `just install`: install Python dependencies with Poetry.
- `just test`: run fast Python tests, excluding integration and benchmark markers.
- `just test-all`: run the complete pytest suite.
- `just test-file api/test_auth.py`: run one test module under `tests/`.
- `just lint` / `just typecheck`: run Ruff and mypy checks.
- `just fmt`: format with Black and apply Ruff fixes.
- `just infra-up`: start PostgreSQL, Temporal, and supporting services.
- `just contracts-build` / `just contracts-test`: build and test Solidity contracts with Foundry.
- `nix flake check --no-build`: validate flake outputs as CI does.

## Coding Style & Naming Conventions

Use four-space indentation, type annotations, and a 100-character line limit. Python modules, functions, and variables use `snake_case`; classes use `PascalCase`; constants use `UPPER_SNAKE_CASE`. Ruff enforces imports, naming, modernization, and common errors; Black controls formatting. Keep public interfaces explicit and avoid logging credentials, tokens, personal data, or authorization headers.

## Testing Guidelines

Pytest discovers `test_*.py` files and `test_*` functions. Use `pytest-asyncio` strict mode for async tests. Mark service-dependent tests with `@pytest.mark.integration` and performance tests with `@pytest.mark.benchmark`. Add regression coverage beside the affected domain and test allowed and denied paths for compliance, authentication, and authorization changes.

## Commit & Pull Request Guidelines

Recent history favors Conventional Commit subjects such as `feat(compliance): ...`, `fix: ...`, and `chore: ...`; use an imperative, scoped summary. PRs should explain behavior and risk, link relevant issues, include tests and documentation, and note configuration or migration impact. Add screenshots for frontend changes. Before review, ensure Python, contract, Nix, and integration checks relevant to the patch pass; update `docs/CHANGELOG.md` for user-visible changes.

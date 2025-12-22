# Agent Instructions for Dotfiles Repository

## Build/Lint/Test Commands

- **Full build**: `make` or `make all` - builds and switches NixOS/home-manager configurations
- **Update dependencies**: `make update` - updates flake inputs and app hashes
- **Clean**: `make clean` - garbage collects and optimizes Nix store
- **Pre-commit checks**: `pre-commit run --all-files` - runs linting and formatting checks
- **Specific host build**: `make home-manager` (for home-manager) or `make os` (for NixOS)

## Code Style Guidelines

### Nix Code Style

- Use functional programming patterns with `let ... in` expressions
- Group imports at the top of files using `imports = [ ... ];`
- Use descriptive variable names following camelCase convention
- Maintain consistent 2-space indentation
- Use attribute sets `{ key = value; }` for configuration
- Add comments for complex logic or configuration sections
- Follow the pattern: `inputs@{ ... }: { ... }` for function arguments

### General Guidelines

- Use pre-commit hooks for automatic formatting and linting
- Keep commit messages clear and descriptive using conventional commits
- Organize code into logical modules and separate concerns
- Use relative paths and proper Nix path handling
- Avoid hardcoding system-specific values

### Error Handling

- Use Nix's built-in error handling and validation
- Provide meaningful error messages in assertions
- Handle optional dependencies gracefully with `lib.mkIf`

### Naming Conventions

- Functions: camelCase (`myFunction`)
- Variables: camelCase (`myVariable`)
- Modules: descriptive names matching their purpose
- Configuration attributes: descriptive lowercase with hyphens if needed

### Imports and Dependencies

- Group related imports together
- Use `inputs.self` for self-references within flakes
- Leverage `lib.mkMerge` for combining configurations
- Prefer `lib.mkDefault` for default values that can be overridden

## Testing Approach

Since this is a configuration repository rather than application code:

- Manual testing by running `make` and verifying system state
- Use `nix flake check` to validate flake syntax
- Test configurations on target systems before committing
- No automated unit tests; rely on integration testing

## Commit Message Format

Follow conventional commits:

- `feat: add new configuration`
- `fix: resolve issue with X`
- `docs: update documentation`
- `refactor: restructure Y module`

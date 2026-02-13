# Development Guidelines

## Philosophy

### Core Beliefs

- **Incremental progress over big bangs** - Small changes that compile and pass tests
- **Learning from existing code** - Study and plan before implementing
- **Pragmatic over dogmatic** - Adapt to project reality
- **Clear intent over clever code** - Be boring and obvious

### Simplicity

- **Single responsibility** per function/class
- **Avoid premature abstractions**
- **No clever tricks** - choose the boring solution
- If you need to explain it, it's too complex

## Technical Standards

### Architecture Principles

- **Composition over inheritance** - Use dependency injection
- **Interfaces over singletons** - Enable testing and flexibility
- **Explicit over implicit** - Clear data flow and dependencies
- **Test-driven when possible** - Never disable tests, fix them

### Error Handling

- **Fail fast** with descriptive messages
- **Include context** for debugging
- **Handle errors** at appropriate level
- **Never** silently swallow exceptions

## Project Integration

### Learn the Codebase

- Find similar features/components
- Identify common patterns and conventions
- Use same libraries/utilities when possible
- Follow existing test patterns

### Tooling

- Use project's existing build system
- Use project's existing test framework
- Use project's formatter/linter settings
- Don't introduce new tools without strong justification
- Check if devbox.json exists, and use the tools defined in the file.

### Verification Before Task Completion

Before marking any task as complete, **ALWAYS** run the following if available:

1. **Build** - Run the project's build command to ensure code compiles
   - Check Makefile, package.json scripts, or project documentation
   - Common: `make build`, `make all`, `npm run build`, `cargo build`

2. **Linting** - Run linters to catch style and quality issues
   - Check for pre-commit hooks, lint scripts, or linter configs
   - Common: `make lint`, `npm run lint`, `pre-commit run --all-files`

3. **Tests** - Run test suites to verify functionality
   - Run relevant tests (unit, integration, or full suite)
   - Common: `make test`, `npm test`, `cargo test`, `pytest`

**Skip only if**:

- No build system exists in the project
- No linter configuration is present
- No tests are defined for the project

**Never skip** if these tools are available - catching issues early saves time.

### Code Style

- Follow existing conventions in the project
- Refer to linter configurations and .editorconfig, if present
- Text files should always end with an empty line

## MCP Tool Use

- Use Context7 to validate current documentation about software libraries
- Use ddg-search when looking for code examples or explanations

## Important Reminders

**NEVER**:

- Use `--no-verify` to bypass commit hooks
- Disable tests instead of fixing them
- Commit code that doesn't compile
- Make assumptions - verify with existing code

**ALWAYS**:

- Run build, linting, and tests before completing tasks (if available)
- Commit working code incrementally
- Update plan documentation as you go
- Learn from existing implementations
- Stop after 3 failed attempts and reassess

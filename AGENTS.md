# AGENTS.md - AI Agent Guide for Jovay Examples

This document provides comprehensive guidance for AI agents working with the jovay-examples repository. It covers repository structure, workflows, conventions, and best practices.

## Table of Contents

1. [Repository Overview](#repository-overview)
2. [Examples Registry System](#examples-registry-system)
3. [Adding New Examples](#adding-new-examples)
4. [Modifying Existing Examples](#modifying-existing-examples)
5. [CI/CD Integration](#cicd-integration)
6. [Code Standards](#code-standards)
7. [Common Tasks](#common-tasks)
8. [Related Documentation](#related-documentation)

## Repository Overview

### Purpose

The jovay-examples repository hosts small, focused, runnable examples that help developers build on **Jovay Network**. Each example is self-contained and includes its own README with prerequisites and step-by-step instructions.

### Key Principles

- **Self-contained**: Each example should work independently
- **Minimal dependencies**: Keep examples focused and easy to reproduce
- **Well-documented**: Every example must have a clear README
- **Tested**: Examples should include tests when feasible
- **No secrets**: Never commit private keys, API keys, or sensitive configuration

### Repository Structure

```
.
├── chainlink_examples/          # Chainlink-related examples
│   └── ccip_example/            # Example: CCIP messaging + token transfer
├── ci/                          # CI/CD scripts
│   ├── list_examples.py         # Parses examples.yaml, generates CI matrix
│   ├── run_example.sh          # Main CI runner (dispatches by type)
│   └── solidity_foundry.sh     # Foundry-specific checks
├── .github/workflows/           # GitHub Actions workflows
│   └── examples.yml             # CI workflow definition
├── examples.yaml                # Single source of truth for examples registry
├── README.md                    # Main repository README
├── CONTRIBUTING.md              # Contribution guidelines
└── LICENSE                      # MIT License
```

### Key Files

- **`examples.yaml`**: Registry of all examples with metadata and test configuration
- **`ci/list_examples.py`**: Validates and parses `examples.yaml`, outputs JSON or GitHub Actions matrix
- **`ci/run_example.sh`**: Dispatches to type-specific test runners
- **`ci/solidity_foundry.sh`**: Runs Foundry checks (fmt, build, test)

## Examples Registry System

### Overview

The `examples.yaml` file is the **single source of truth** for all examples in the repository. It defines:

- Example paths (relative to repo root)
- Example types (e.g., `solidity`)
- Descriptions
- Test configurations

### Schema

```yaml
version: 1

examples:
  - path: chainlink_examples/ccip_example
    type: solidity
    description: "Chainlink CCIP example (Foundry): messaging + token transfers between Sepolia and Jovay Testnet."
    test:
      solidity:
        foundry:
          fmt: true          # Run forge fmt --check
          build: true        # Run forge build
          test:              # Run forge test
            offline: true    # Use --offline flag for tests
```

### Validation Rules

The `ci/list_examples.py` script validates:

1. **Version**: Must be `1`
2. **Examples list**: Must be non-empty
3. **Path uniqueness**: Each path must be unique
4. **Path existence**: Each path must exist as a directory
5. **Required fields**: `path`, `type`, `description` must be non-empty strings

### Adding to Registry

When adding a new example:

1. Create the example directory and files
2. Add an entry to `examples.yaml` with:
   - Unique `path` (relative to repo root)
   - `type` (currently `solidity` is supported)
   - Clear `description`
   - Appropriate `test` configuration

### CI Integration

The GitHub Actions workflow (`.github/workflows/examples.yml`):

1. Reads `examples.yaml` via `ci/list_examples.py`
2. Generates a matrix of examples
3. Runs checks for each example in parallel
4. For `solidity` type, executes `ci/solidity_foundry.sh`

## Adding New Examples

### Step-by-Step Process

1. **Create Example Directory**
   ```
   mkdir -p <category>_examples/<example_name>
   ```

2. **Create Example Files**
   - Source code in `src/` (for Foundry projects)
   - Scripts in `script/` (for Foundry deployment scripts)
   - Tests in `test/` (for Foundry tests)
   - `README.md` with prerequisites, setup, and usage
   - `foundry.toml` (for Foundry projects)

3. **Add README.md**
   Must include:
   - Overview and features
   - Prerequisites
   - Installation steps
   - Build and test instructions
   - Usage examples
   - Troubleshooting section

4. **Configure Dependencies**
   - For Foundry: Use git submodules in `lib/`
   - Document submodule setup in README
   - Pin versions (tags/commits) for reproducibility

5. **Add Tests**
   - Create test files in `test/`
   - Ensure tests can run with `forge test`
   - Use `--offline` flag if network access causes issues

6. **Update examples.yaml**
   ```yaml
   - path: <category>_examples/<example_name>
     type: solidity
     description: "Clear description of what this example demonstrates."
     test:
       solidity:
         foundry:
           fmt: true
           build: true
           test:
             offline: true  # Set based on test requirements
   ```

7. **Verify Locally**
   ```bash
   # From example directory
   forge fmt --check
   forge build
   forge test --offline
   ```

8. **Test CI Integration**
   - Push to a feature branch
   - Verify CI runs and passes

### Example Structure (Foundry)

```
<example_name>/
├── src/
│   └── *.sol              # Contract source files
├── script/
│   └── *.s.sol            # Deployment scripts
├── test/
│   └── *.t.sol            # Test files
├── lib/                    # Git submodules (dependencies)
├── foundry.toml           # Foundry configuration
└── README.md              # Example documentation
```

## Modifying Existing Examples

### Best Practices

1. **Maintain Backward Compatibility**
   - Keep existing functionality working
   - Add new features without breaking existing workflows

2. **Update Documentation**
   - Update README.md if behavior changes
   - Update code comments if logic changes

3. **Test Changes**
   - Run `forge fmt --check` to ensure formatting
   - Run `forge build` to ensure compilation
   - Run `forge test` to ensure tests pass

4. **Update examples.yaml if Needed**
   - Update `description` if scope changes
   - Adjust test configuration if needed

5. **Follow Git Workflow**
   - Create feature branch: `feat/<short_name>`
   - Keep commits small and descriptive
   - Ensure CI passes before merging

### Common Modifications

- **Adding new contracts**: Add to `src/`, update tests
- **Adding new scripts**: Add to `script/`, document in README
- **Updating dependencies**: Update submodules, test compatibility
- **Fixing bugs**: Fix code, add tests, update docs if needed

## CI/CD Integration

### Workflow Overview

The CI workflow (`.github/workflows/examples.yml`) runs on:
- Pull requests
- Pushes to `main` branch
- Pushes to `feat/**` branches

### Workflow Steps

1. **Matrix Generation**
   - Reads `examples.yaml`
   - Generates matrix with one job per example

2. **Checkout**
   - Checks out repository with submodules (`submodules: recursive`)

3. **Tool Installation**
   - Installs Foundry (for `solidity` type examples)

4. **Example Checks**
   - Sets environment variables (`EXAMPLE_PATH`, `EXAMPLE_TYPE`, `FOUNDRY_TEST_OFFLINE`)
   - Runs `ci/run_example.sh`
   - Which dispatches to type-specific runners (e.g., `ci/solidity_foundry.sh`)

### Foundry Checks

For `solidity` type examples, `ci/solidity_foundry.sh` runs:

1. **Format Check**: `forge fmt --check`
2. **Build**: `forge build`
3. **Test**: `forge test --force [--offline]`

All checks must pass for CI to succeed.

### Environment Variables

- `EXAMPLE_PATH`: Path to example directory (from repo root)
- `EXAMPLE_TYPE`: Example type (e.g., `solidity`)
- `FOUNDRY_TEST_OFFLINE`: Whether to run tests with `--offline` flag

### Debugging CI Failures

1. Check the failing example path
2. Run checks locally:
   ```bash
   cd <example_path>
   forge fmt --check
   forge build
   forge test --offline
   ```
3. Fix issues and verify locally
4. Push changes and verify CI passes

## Code Standards

### Foundry/Solidity

1. **Formatting**
   - Use `forge fmt` to format code
   - Default: 120 char line length, 4 space tabs
   - Configure in `foundry.toml`:
     ```toml
     [fmt]
     line_length = 120
     tab_width = 4
     bracket_spacing = true
     ```

2. **Compiler Settings**
   - Pin Solidity version (e.g., `solc = "0.8.30"`)
   - Enable optimizer for production-like builds
   - Document compiler version in README

3. **Remappings**
   - Use clear, consistent remapping names
   - Document in `foundry.toml` and README

4. **Testing**
   - Write tests for all contracts
   - Use descriptive test names
   - Test both success and failure cases
   - Use `--offline` if network access causes issues

5. **Scripts**
   - Use Foundry Scripts (`.s.sol`) for deployment
   - Make scripts reusable and configurable
   - Document script usage in README

### Documentation

1. **README.md Requirements**
   - Clear title and overview
   - Prerequisites list
   - Installation instructions
   - Build and test commands
   - Usage examples with commands
   - Troubleshooting section
   - Links to relevant documentation

2. **Code Comments**
   - Comment complex logic
   - Document function parameters and return values
   - Explain non-obvious design decisions

3. **English Only**
   - All code comments and documentation in English
   - Variable and function names in English

### Git Submodules

- Use git submodules for dependencies (e.g., OpenZeppelin, Chainlink)
- Document submodule setup in README
- Pin to specific commits/tags for reproducibility
- Ensure `git clone --recurse-submodules` works

## Common Tasks

### Adding a New Solidity Example

1. Create directory structure
2. Add contracts, scripts, tests
3. Configure `foundry.toml`
4. Add dependencies as submodules
5. Write comprehensive README
6. Add entry to `examples.yaml`
7. Test locally
8. Push and verify CI

### Updating an Existing Example

1. Make changes to code/docs
2. Run `forge fmt --check`
3. Run `forge build`
4. Run `forge test`
5. Update README if needed
6. Test locally end-to-end
7. Commit and push

### Fixing CI Failures

1. Identify failing example from CI logs
2. Reproduce locally:
   ```bash
   cd <example_path>
   forge fmt --check
   forge build
   forge test --offline
   ```
3. Fix issues
4. Verify locally
5. Push fix

### Updating Dependencies

1. Navigate to dependency in `lib/`
2. Update submodule:
   ```bash
   cd lib/<dependency>
   git fetch
   git checkout <tag_or_commit>
   cd ../..
   git add lib/<dependency>
   ```
3. Test compatibility:
   ```bash
   forge build
   forge test
   ```
4. Update README if versions changed
5. Commit submodule update

### Adding a New Example Type

1. Add type-specific runner script in `ci/` (e.g., `ci/python_example.sh`)
2. Update `ci/run_example.sh` to handle new type
3. Update `examples.yaml` schema documentation
4. Update `ci/list_examples.py` if validation needed
5. Add example of new type
6. Update this documentation

## Related Documentation

- **README.md**: Main repository overview
- **CONTRIBUTING.md**: Contribution guidelines and conventions
- **SECURITY.md**: Security policy
- **examples.yaml**: Examples registry (source of truth)
- **.claude/skills/foundry-examples.md**: Detailed Foundry/Solidity example patterns and best practices

## Quick Reference

### Essential Commands

```bash
# Format check
forge fmt --check

# Build
forge build

# Test (offline)
forge test --offline

# List examples (from repo root)
python3 ci/list_examples.py

# Run example checks locally
cd <example_path>
bash ../../ci/solidity_foundry.sh .
```

### File Locations

- Examples registry: `examples.yaml`
- CI scripts: `ci/`
- Workflow: `.github/workflows/examples.yml`
- Example structure: `<category>_examples/<name>/`

### Key Principles

1. **Self-contained**: Examples work independently
2. **Tested**: All examples have tests
3. **Documented**: Every example has a README
4. **Registered**: All examples in `examples.yaml`
5. **CI-validated**: All examples pass CI checks

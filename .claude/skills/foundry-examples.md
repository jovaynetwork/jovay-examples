# Foundry Examples Skill

## Purpose

This skill helps AI agents understand how to create, modify, and maintain Foundry-based Solidity examples in the jovay-examples repository.

## Overview

Foundry is the primary toolchain for Solidity examples in this repository. Examples use Foundry for:

- Compilation (`forge build`)
- Testing (`forge test`)
- Deployment scripts (`forge script`)
- Code formatting (`forge fmt`)

## Example Structure

A typical Foundry example has this structure:

```text
<example_name>/
├── src/                    # Solidity source contracts
│   ├── Contract1.sol
│   └── Contract2.sol
├── script/                 # Deployment scripts (Foundry Scripts)
│   ├── DeployContract1.s.sol
│   └── DeployContract2.s.sol
├── test/                   # Test files (Foundry Tests)
│   └── Contract1.t.sol
├── lib/                    # Git submodules (dependencies)
│   ├── forge-std/
│   ├── openzeppelin-contracts/
│   └── <other-dependencies>/
├── foundry.toml           # Foundry configuration
└── README.md              # Example documentation
```

## Foundry Configuration (`foundry.toml`)

### Basic Structure

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.30"              # Pin Solidity version
optimizer = true
optimizer_runs = 200

# Remappings for dependencies
remappings = [
    "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
    "forge-std/=lib/forge-std/src/",
]

# RPC endpoints (optional, for scripts)
[rpc_endpoints]
sepolia = "${SEPOLIA_RPC_URL}"
jovay_testnet = "${JOVAY_TESTNET_RPC_URL}"

# Formatting settings
[fmt]
line_length = 120
tab_width = 4
bracket_spacing = true
```

### Key Settings

- **`solc`**: Pin Solidity compiler version (e.g., `"0.8.30"`)
- **`optimizer`**: Enable optimizer for production-like builds
- **`optimizer_runs`**: Optimization runs (200 is common)
- **`remappings`**: Import path mappings for dependencies
- **`[fmt]`**: Code formatting preferences

### Remappings

Remappings allow clean imports:

```solidity
// Instead of: import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
```

Common remapping patterns:

- `@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/`
- `forge-std/=lib/forge-std/src/`
- `@chainlink/contracts-ccip/=lib/ccip/chains/evm/contracts/`

## Source Contracts (`src/`)

### File Naming

- Use PascalCase: `MyContract.sol`
- Match contract name to file name
- One contract per file (or related contracts)

### Example Contract Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

contract MyContract {
    // State variables
    address public owner;
    
    // Events
    event SomethingHappened(uint256 value);
    
    // Constructor
    constructor(address _owner) {
        owner = _owner;
    }
    
    // Functions
    function doSomething(uint256 value) external {
        emit SomethingHappened(value);
    }
}
```

### Best Practices

- Use SPDX license identifier
- Pin pragma version (match `foundry.toml`)
- Import from remapped paths
- Add NatSpec comments for public functions
- Emit events for important state changes

## Deployment Scripts (`script/`)

### Script File Naming

- Use PascalCase with `.s.sol` extension
- Pattern: `Deploy<ContractName>.s.sol` or `<Action><Target>.s.sol`
- Examples: `DeployReceiver.s.sol`, `SendMessage.s.sol`

### Script Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/MyContract.sol";

contract DeployMyContract is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        MyContract contract = new MyContract(msg.sender);
        
        console.log("Deployed at:", address(contract));
        
        vm.stopBroadcast();
    }
}
```

### Running Scripts

```bash
# Deploy to network
forge script script/DeployMyContract.s.sol:DeployMyContract \
  --rpc-url sepolia \
  --broadcast

# Simulate (dry run)
forge script script/DeployMyContract.s.sol:DeployMyContract \
  --rpc-url sepolia
```

### Environment Variables

Scripts can use environment variables:

- `PRIVATE_KEY`: Deployer private key
- `RPC_URL`: Network RPC endpoint (or use `--rpc-url`)
- Custom variables via `vm.envString()`, `vm.envUint()`, etc.

## Test Files (`test/`)

### Test File Naming

- Use PascalCase with `.t.sol` extension
- Pattern: `<ContractName>.t.sol` or `<Feature>.t.sol`
- Examples: `MyContract.t.sol`, `CCIP.t.sol`

### Test Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/MyContract.sol";

contract MyContractTest is Test {
    MyContract public contract;
    address public owner = address(1);
    
    function setUp() public {
        contract = new MyContract(owner);
    }
    
    function test_DoSomething() public {
        uint256 value = 42;
        contract.doSomething(value);
        // Add assertions
    }
    
    function test_RevertWhen_InvalidInput() public {
        vm.expectRevert();
        contract.doSomething(0);
    }
}
```

### Running Tests

```bash
# Run all tests
forge test

# Run offline (no network access)
forge test --offline

# Run specific test
forge test --match-test test_DoSomething

# Verbose output
forge test -vvv
```

### Test Best Practices

- Use descriptive test names: `test_<Action>`, `test_RevertWhen_<Condition>`
- Set up test state in `setUp()`
- Use `vm.expectRevert()` for failure cases
- Use `vm.prank()`, `vm.deal()`, etc. for state manipulation
- Test both success and failure paths

## Dependencies (Git Submodules)

### Adding Dependencies

1. Add as git submodule:

   ```bash
   git submodule add <repository-url> lib/<dependency-name>
   ```

2. Pin to specific version:

   ```bash
   cd lib/<dependency-name>
   git checkout <tag-or-commit>
   cd ../..
   git add lib/<dependency-name>
   ```

3. Add remapping in `foundry.toml`

4. Document in README.md

### Common Dependencies

- **forge-std**: Foundry standard library (testing utilities)
- **openzeppelin-contracts**: OpenZeppelin contracts
- **ccip**: Chainlink CCIP contracts (for CCIP examples)

### Updating Dependencies

```bash
cd lib/<dependency-name>
git fetch
git checkout <new-tag-or-commit>
cd ../..
git add lib/<dependency-name>
```

Then test:

```bash
forge build
forge test
```

## CI Integration

Foundry examples are validated in CI via `ci/solidity_foundry.sh`:

1. **Format check**: `forge fmt --check`
2. **Build**: `forge build`
3. **Test**: `forge test --force [--offline]`

The `--offline` flag is controlled by `FOUNDRY_TEST_OFFLINE` environment variable (set from `examples.yaml`).

## Common Tasks

### Creating a New Foundry Example

1. Create directory structure
2. Initialize Foundry: `forge init --no-git` (or create manually)
3. Add `foundry.toml` with appropriate settings
4. Add dependencies as submodules
5. Write contracts in `src/`
6. Write tests in `test/`
7. Write deployment scripts in `script/`
8. Add `README.md`
9. Add entry to `examples.yaml`
10. Test locally: `forge fmt --check && forge build && forge test --offline`

### Modifying an Existing Example

1. Make changes to contracts/scripts/tests
2. Format: `forge fmt`
3. Build: `forge build`
4. Test: `forge test --offline`
5. Update README if behavior changes
6. Verify CI passes

### Fixing Format Issues

```bash
# Check formatting
forge fmt --check

# Auto-format
forge fmt

# Then verify
forge fmt --check
```

### Debugging Build Errors

```bash
# Build with verbose output
forge build -vvv

# Check remappings
forge remappings

# Verify dependencies
ls -la lib/
```

### Debugging Test Failures

```bash
# Run with verbose output
forge test -vvv

# Run specific test
forge test --match-test test_MyTest -vvv

# Use debugger
forge test --debug <test_name>
```

## Example: CCIP Example Structure

The `chainlink_examples/ccip_example` demonstrates:

- **Contracts**: `Sender.sol`, `Receiver.sol`, `TokenTransferor.sol`
- **Scripts**: Deployment and interaction scripts
- **Tests**: `CCIP.t.sol` with integration tests
- **Dependencies**: CCIP contracts, OpenZeppelin, forge-std
- **Configuration**: `foundry.toml` with remappings and RPC endpoints

Study this example for patterns and best practices.

## Related Documentation

- **AGENTS.md**: Comprehensive AI agent guide covering repository structure, examples registry, CI/CD workflows, and code standards

## Quick Reference

```bash
# Format check
forge fmt --check

# Build
forge build

# Test (offline)
forge test --offline

# Deploy script
forge script script/Deploy.s.sol:Deploy --rpc-url sepolia --broadcast

# List remappings
forge remappings

# Clean build artifacts
forge clean
```

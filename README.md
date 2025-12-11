# AgriProvenance CLI

Interactive command-line interface for the AgriProvenance smart contract on Polygon Amoy testnet.

## Overview

This CLI tool provides a user-friendly menu-driven interface to interact with the AgriProvenance blockchain smart contract. It supports all contract operations including role management, product registration, batch tracking, and custody transfers.

## Prerequisites

- **Foundry** (cast command-line tool)
- **Bash shell** (Linux/macOS or WSL on Windows)
- **Access to Polygon Amoy RPC**
- **Private key or keystore account** (for write operations)

## Installation

1. Clone or download the `agri.sh` script

2. Make the script executable:
```bash
chmod +x agri.sh
```

3. Create configuration file at `~/.agri-config`:
```bash
cat > ~/.agri-config << EOF
# Polygon Amoy RPC URL
RPC_URL="https://rpc-amoy.polygon.technology"

# AgriProvenance contract address
CONTRACT="0x2c5e8F70139Ac595776434C99526F982B126a858"

# Optional: Private key for transactions (or use keystore)
PRIVATE_KEY="your_private_key_here"
EOF
```

4. Secure your config file:
```bash
chmod 600 ~/.agri-config
```

## Usage

Simply run the script to launch the interactive menu:

```bash
./agri.sh
```

The CLI will present a menu with numbered options. Enter the number corresponding to your desired operation.

## Features

### Read Operations (No Gas Required)

1. **Show total batches** - Display total number of registered batches
2. **Show admin address** - View the contract administrator address
3. **Check user role** - Query role assigned to any address
4. **Check if batch exists** - Verify if a batch ID is registered
5. **Get batch details** - Retrieve complete batch information
6. **Get batch status** - View current status of a batch
7. **Get batch history** - Display full status history timeline

### Write Operations (Requires Gas)

8. **Assign role to address** - Admin function to assign roles
   - Roles: 0=None, 1=Manufacturer, 2=Distributor, 3=Retailer, 4=Regulator
9. **Register new product** - Create new batch entry (Manufacturer only)
10. **Update batch status** - Change batch status (Owner only)
    - Status: 0=Created, 1=InTransit, 2=Delivered
11. **Transfer batch custody** - Transfer ownership (Owner only)

### Utilities

12. **Generate new batch ID** - Create unique batch identifier
13. **Check account balance** - View MATIC balance

## Authentication Methods

For write operations, the CLI supports two authentication methods:

**Option 1: Private Key** (from environment)
- Set `PRIVATE_KEY` in `~/.agri-config`
- Transactions are signed automatically

**Option 2: Keystore Account**
- Use Foundry's cast wallet accounts
- Enter account name when prompted
- Password required for each transaction

## Example Workflow

```bash
# 1. Launch CLI
./agri.sh

# 2. Generate a batch ID (option 12)
# Copy the generated ID

# 3. Register new product (option 9)
# Paste the batch ID when prompted
# Enter IPFS CID, product type, and quality type

# 4. View batch details (option 5)
# Enter the batch ID to see registration details

# 5. Update status (option 10)
# Change status from Created to InTransit

# 6. Transfer custody (option 11)
# Transfer to distributor/retailer address

# 7. Check history (option 7)
# View complete status change timeline
```

## Configuration Reference

**Required Variables:**
- `RPC_URL` - Polygon Amoy RPC endpoint
- `CONTRACT` - AgriProvenance contract address

**Optional Variables:**
- `PRIVATE_KEY` - Your wallet private key (alternative to keystore)

## Security Notes

- **Never commit** `~/.agri-config` with your private key to version control
- Set appropriate file permissions (600) on config file
- Consider using keystore accounts for enhanced security
- Private keys are only used locally and never transmitted except in signed transactions

## Smart Contract Reference

This CLI interacts with the AgriProvenance smart contract deployed at:
- **Address:** `0x2c5e8F70139Ac595776434C99526F982B126a858`
- **Network:** Polygon Amoy Testnet (Chain ID: 80002)
- **Explorer:** [View on PolygonScan](https://amoy.polygonscan.com/address/0x2c5e8F70139Ac595776434C99526F982B126a858)

For complete smart contract documentation, see the main project repository.

## Troubleshooting

**"Error: ~/.agri-config not found"**
- Create the configuration file as shown in Installation step 3

**"cast: command not found"**
- Install Foundry: `curl -L https://foundry.paradigm.xyz | bash && foundryup`

**Transaction failed**
- Ensure you have sufficient MATIC for gas fees
- Verify you have the required role for the operation
- Check that batch ID exists (for update/transfer operations)
- Confirm you're the batch owner (for owner-only operations)

**"PRIVATE_KEY not set in environment"**
- Add PRIVATE_KEY to `~/.agri-config` or use keystore authentication

## Get Test Tokens

Obtain free test MATIC for Polygon Amoy:
- Visit: https://faucet.polygon.technology
- Connect your wallet and request tokens

## License

This CLI tool is part of the AgriProvenance project developed for academic purposes at Arizona State University.

---

**Note:** This tool is designed for use with Polygon Amoy testnet only. It is not intended for production use with real assets.

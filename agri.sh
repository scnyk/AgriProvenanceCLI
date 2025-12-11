#!/bin/bash
# AgriProvenance CLI Helper

# Usage: ./agri.sh --> interactive CLI menu, no commands needed

# Load configuration
if [ -f ~/.agri-config ]; then
    source ~/.agri-config
else
    echo "Error: ~/.agri-config not found"
    echo "Create it with your RPC_URL and CONTRACT variables"
    exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_menu() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   AgriProvenance Smart Contract CLI   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}READ OPERATIONS (No gas required):${NC}"
    echo "  1. Show total batches"
    echo "  2. Show admin address"
    echo "  3. Check user role"
    echo "  4. Check if batch exists"
    echo "  5. Get batch details"
    echo "  6. Get batch status"
    echo "  7. Get batch history"
    echo ""
    echo -e "${YELLOW}WRITE OPERATIONS (Requires gas):${NC}"
    echo "  8. Assign role to address"
    echo "  9. Register new product"
    echo " 10. Update batch status"
    echo " 11. Transfer batch custody"
    echo ""
    echo -e "${BLUE}UTILITIES:${NC}"
    echo " 12. Generate new batch ID"
    echo " 13. Check account balance"
    echo ""
    echo "  0. Exit"
    echo ""
}

read_input() {
    echo -n -e "${GREEN}➜${NC} "
    read choice
}

press_enter() {
    echo ""
    echo -n -e "${BLUE}Press Enter to continue...${NC}"
    read
}

# Function 1: Total Batches
show_total_batches() {
    echo -e "${BLUE}Total Batches in System:${NC}"
    cast call $CONTRACT "totalBatches()(uint256)" --rpc-url $RPC_URL
    press_enter
}

# Function 2: Admin Address
show_admin() {
    echo -e "${BLUE}Admin Address:${NC}"
    cast call $CONTRACT "admin()(address)" --rpc-url $RPC_URL
    press_enter
}

# Function 3: Check Role
check_role() {
    echo -n "Enter address: "
    read address
    echo -e "${BLUE}Role for $address:${NC}"
    cast call $CONTRACT "getUserRole(address)(string)" $address --rpc-url $RPC_URL
    press_enter
}

# Function 4: Check Batch Exists
check_batch_exists() {
    echo -n "Enter batch ID: "
    read batch_id
    echo -e "${BLUE}Batch exists:${NC}"
    cast call $CONTRACT "batchExistsCheck(bytes32)(bool)" $batch_id --rpc-url $RPC_URL
    press_enter
}

# Function 5: Get Batch Details
get_batch_details() {
    echo -n "Enter batch ID: "
    read batch_id
    echo -e "${BLUE}Batch Details:${NC}"
    cast call $CONTRACT "getBatch(bytes32)(bytes32,address,string,string,string,string,uint256,uint256)" $batch_id --rpc-url $RPC_URL
    press_enter
}

# Function 6: Get Status
get_status() {
    echo -n "Enter batch ID: "
    read batch_id
    echo -e "${BLUE}Current Status:${NC}"
    cast call $CONTRACT "getCurrentStatus(bytes32)(string)" $batch_id --rpc-url $RPC_URL
    press_enter
}

# Function 7: Get History
get_history() {
    echo -n "Enter batch ID: "
    read batch_id
    echo -e "${BLUE}Status History:${NC}"
    cast call $CONTRACT "getStatusHistory(bytes32)" $batch_id --rpc-url $RPC_URL
    press_enter
}

# Function 8: Assign Role
assign_role() {
    echo -n "Enter address to assign role: "
    read address
    echo ""
    echo "Roles: 0=None, 1=Manufacturer, 2=Distributor, 3=Retailer, 4=Regulator"
    echo -n "Enter role number: "
    read role
    
    echo ""
    echo -e "${YELLOW}Choose authentication method:${NC}"
    echo "1. Use private key from environment"
    echo "2. Use keystore account"
    read -p "Choice: " auth_choice
    
    if [ "$auth_choice" == "1" ]; then
        if [ -z "$PRIVATE_KEY" ]; then
            echo -e "${RED}Error: PRIVATE_KEY not set in environment${NC}"
            press_enter
            return
        fi
        echo -e "${BLUE}Sending transaction...${NC}"
        cast send $CONTRACT \
            "assignRole(address,uint8)" \
            $address $role \
            --rpc-url $RPC_URL \
            --private-key $PRIVATE_KEY
    else
        echo -n "Enter keystore account name: "
        read account
        echo -e "${BLUE}Sending transaction...${NC}"
        cast send $CONTRACT \
            "assignRole(address,uint8)" \
            $address $role \
            --rpc-url $RPC_URL \
            --account $account
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Role assigned successfully!${NC}"
    else
        echo -e "${RED}✗ Transaction failed${NC}"
    fi
    press_enter
}

# Function 9: Register Product
register_product() {
    echo -e "${BLUE}Generate a batch ID first or enter existing one${NC}"
    echo -n "Enter batch ID (or press Enter to generate): "
    read batch_id
    
    if [ -z "$batch_id" ]; then
        batch_id=$(cast keccak "batch-$(date +%s)")
        echo -e "${GREEN}Generated Batch ID: $batch_id${NC}"
    fi
    
    echo -n "Enter IPFS CID (metadata): "
    read cid
    
    echo ""
    echo "Product Type: 0=Imported, 1=Local"
    echo -n "Enter product type: "
    read ptype
    
    echo ""
    echo "Quality Type: 0=Organic, 1=NonOrganic"
    echo -n "Enter quality type: "
    read qtype
    
    echo ""
    echo -e "${YELLOW}Choose authentication method:${NC}"
    echo "1. Use private key from environment"
    echo "2. Use keystore account"
    read -p "Choice: " auth_choice
    
    if [ "$auth_choice" == "1" ]; then
        if [ -z "$PRIVATE_KEY" ]; then
            echo -e "${RED}Error: PRIVATE_KEY not set in environment${NC}"
            press_enter
            return
        fi
        echo -e "${BLUE}Sending transaction...${NC}"
        cast send $CONTRACT \
            "registerProduct(bytes32,string,uint8,uint8)" \
            $batch_id $cid $ptype $qtype \
            --rpc-url $RPC_URL \
            --private-key $PRIVATE_KEY
    else
        echo -n "Enter keystore account name: "
        read account
        echo -e "${BLUE}Sending transaction...${NC}"
        cast send $CONTRACT \
            "registerProduct(bytes32,string,uint8,uint8)" \
            $batch_id $cid $ptype $qtype \
            --rpc-url $RPC_URL \
            --account $account
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Product registered successfully!${NC}"
        echo -e "${GREEN}Batch ID: $batch_id${NC}"
    else
        echo -e "${RED}✗ Transaction failed${NC}"
    fi
    press_enter
}

# Function 10: Update Status
update_status() {
    echo -n "Enter batch ID: "
    read batch_id
    
    echo ""
    echo "Status: 0=Created, 1=InTransit, 2=Delivered"
    echo -n "Enter new status: "
    read status
    
    echo ""
    echo -e "${YELLOW}Choose authentication method:${NC}"
    echo "1. Use private key from environment"
    echo "2. Use keystore account"
    read -p "Choice: " auth_choice
    
    if [ "$auth_choice" == "1" ]; then
        if [ -z "$PRIVATE_KEY" ]; then
            echo -e "${RED}Error: PRIVATE_KEY not set in environment${NC}"
            press_enter
            return
        fi
        echo -e "${BLUE}Sending transaction...${NC}"
        cast send $CONTRACT \
            "updateStatus(bytes32,uint8)" \
            $batch_id $status \
            --rpc-url $RPC_URL \
            --private-key $PRIVATE_KEY
    else
        echo -n "Enter keystore account name: "
        read account
        echo -e "${BLUE}Sending transaction...${NC}"
        cast send $CONTRACT \
            "updateStatus(bytes32,uint8)" \
            $batch_id $status \
            --rpc-url $RPC_URL \
            --account $account
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Status updated successfully!${NC}"
    else
        echo -e "${RED}✗ Transaction failed${NC}"
    fi
    press_enter
}

# Function 11: Transfer Custody
transfer_custody() {
    echo -n "Enter batch ID: "
    read batch_id
    echo -n "Enter new owner address: "
    read new_owner
    
    echo ""
    echo -e "${YELLOW}Choose authentication method:${NC}"
    echo "1. Use private key from environment"
    echo "2. Use keystore account"
    read -p "Choice: " auth_choice
    
    if [ "$auth_choice" == "1" ]; then
        if [ -z "$PRIVATE_KEY" ]; then
            echo -e "${RED}Error: PRIVATE_KEY not set in environment${NC}"
            press_enter
            return
        fi
        echo -e "${BLUE}Sending transaction...${NC}"
        cast send $CONTRACT \
            "transferCustody(bytes32,address)" \
            $batch_id $new_owner \
            --rpc-url $RPC_URL \
            --private-key $PRIVATE_KEY
    else
        echo -n "Enter keystore account name: "
        read account
        echo -e "${BLUE}Sending transaction...${NC}"
        cast send $CONTRACT \
            "transferCustody(bytes32,address)" \
            $batch_id $new_owner \
            --rpc-url $RPC_URL \
            --account $account
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Custody transferred successfully!${NC}"
    else
        echo -e "${RED}✗ Transaction failed${NC}"
    fi
    press_enter
}

# Function 12: Generate Batch ID
generate_batch_id() {
    batch_id=$(cast keccak "batch-$(date +%s)-$RANDOM")
    echo -e "${GREEN}Generated Batch ID:${NC}"
    echo "$batch_id"
    echo ""
    echo -e "${BLUE}Copy this ID for use in registration${NC}"
    press_enter
}

# Function 13: Check Balance
check_balance() {
    echo -n "Enter address (or press Enter for your address): "
    read address
    
    if [ -z "$address" ]; then
        if [ ! -z "$PRIVATE_KEY" ]; then
            address=$(cast wallet address --private-key $PRIVATE_KEY)
        else
            echo -n "Enter keystore account name: "
            read account
            address=$(cast wallet address --account $account)
        fi
    fi
    
    echo -e "${BLUE}Balance for $address:${NC}"
    balance=$(cast balance $address --rpc-url $RPC_URL --ether)
    echo "$balance MATIC"
    press_enter
}

# Main loop
while true; do
    show_menu
    read_input
    
    case $choice in
        1) show_total_batches ;;
        2) show_admin ;;
        3) check_role ;;
        4) check_batch_exists ;;
        5) get_batch_details ;;
        6) get_status ;;
        7) get_history ;;
        8) assign_role ;;
        9) register_product ;;
        10) update_status ;;
        11) transfer_custody ;;
        12) generate_batch_id ;;
        13) check_balance ;;
        0) 
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            sleep 1
            ;;
    esac
done

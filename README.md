# Aergo Standard Token Contract (ARC1)

ARC1 is a technical standard for smart contracts on the Aergo blockchain, designed to implement fungible tokens with improved functionality and security. It encompasses the best features of popular token standards like ERC-20 and extends them for enhanced usability and safety.

## Key Features

### 1. Enhanced Token Security
The ARC1 standard ensures that when tokens are sent to a contract address, the receiving contract implements a predefined `tokenReceived` function. This feature helps prevent token loss due to incorrect contract interaction.

### 2. Combined Token Transfers and Function Calls
ARC1 enables the direct execution of predefined functions in a single transaction alongside token transfers. This approach improves efficiency and reduces transaction costs.

### 3. Simplified Delegation of Authority
By allowing users to delegate authority to a trusted contract through the `setApprovedForAll` function, ARC1 enables seamless interaction with other smart contracts, such as Decentralized Exchanges (DEXs). Users can trade without the need to deposit and withdraw tokens before transactions.

## ARC1 Extensions

The ARC1 standard includes several extensions that further enhance its functionality:

### 1. Pausable
This feature allows for the suspension of token transfers, providing greater control and security in case of emergencies or unexpected issues.

### 2. Limited Approval
Limited Approval functionality restricts the delegation of authority, preventing excessive access to user tokens.

### 3. Mintable
This extension allows for the creation of new tokens, enabling dynamic token supply management.

### 4. Blacklist
The Blacklist feature enables administrators to manage accounts flagged as malicious or non-compliant. Blacklisted accounts are restricted from transferring or burning tokens.


## Specification

Please check the complete specification [here](specs.md).

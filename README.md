# Aergo Standard Token Contract, ARC1-Extensions

This defines interface and behaviors for aergo token contract.

## Abstract

ARC1-Extensions is an extension of the ARC1Token (https://github.com/aergoio/ARC1Token).

ARC1-Extensions adds the functions missing from ERC20 of the ARC1Token, such as stop transfer (`Pausable`), limited delegation (`Limited approval`), and minting tokens (`Mintable`).

ARC1-Extensions additionally includes a function for managing bad users (`Blasklist`). Restrictions on accounts that have been blacklisted can arbitrarily defined, but the current implementation provides a  transmission function that prevents tokens from being received.

## Specification

### + ARC1 : Core
``` lua
-- Type check
-- @type internal
-- @param x variable to check
-- @param t (string) expected type
local function _typecheck(x, t) end

-- Call this at constructor
-- @type internal
-- @param name (string) name of this token
-- @param symbol (string) symbol of this token
-- @param decimals (number) decimals of this token
local function _init(name, symbol, decimals)

-- Get a token name
-- @type    query
-- @return  (string) name of this token
function name()

-- Get a token symbol
-- @type    query
-- @return  (string) symbol of this token
function symbol()

-- Get a token decimals
-- @type    query
-- @return  (number) decimals of this token
function decimals()

-- Get a balance of an account
-- @type    query
-- @param   owner  (address)
-- @return  (ubig) balance of owner
function balanceOf(owner)

-- Get total supply
-- @type    query
-- @return  (ubig) total supply of this token
function totalSupply()

-- Transfer tokens from an account to another
-- @type    internal
-- @param   from    (address) sender's address
-- @param   to      (address) recipient's address
-- @param   amount   (ubig)   amount of token to send
-- @param   ...     addtional data, MUST be sent unaltered in call to 'tokensReceived' on 'to'
local function _transfer(from, to, amount, ...)

-- Mint new tokens to an account
-- @type    internal
-- @param   to      (address) recipient's address
-- @param   amount  (ubig) amount of tokens to mint
local function _mint(to, amount, ...)

-- Burn tokens from an account
-- @type    internal
-- @param   from   (address) 
-- @param   amount  (ubig) amount of tokens to burn
local function _burn(from, amount)

-- Hook "tokensReceived" function on the recipient after a 'transfer'
-- @type internal
-- @param   from   (address) sender's address
-- @param   to     (address) recipient's address
-- @param   amount (ubig) amount of token to send
-- @param   ...     addtional data, MUST be sent unaltered in call to 'tokensReceived' on 'to'
local function _callTokensReceived(from, to, amount, ...)

-- Transfer tokens to an account (from TX sender)
-- @type    call
-- @param   to      (address) recipient's address
-- @param   amount  (ubig) amount of tokens to send
-- @param   ...     addtional data, MUST be sent unaltered in call to 'tokensReceived' on 'to'
-- @event   transfer(TX sender, to, amount)
function transfer(to, amount, ...)

-- Burn tokens (from TX sender)
-- @type    call
-- @param   amount  (ubig) amount of token to burn
-- @event   burn(TX sender, amount)
function burn(amount)
```


### + ARC1 : Mintable
``` lua
-- Indicate if an account is a minter
-- @type    query
-- @param   account  (address) 
-- @return  (bool) true/false
function isMinter(account)

-- Add an account to minters
-- @type    call
-- @param   account  (address) 
-- @event   addMinter(account)
function addMinter(account)

-- Remove an account from minters
-- @type    call
-- @param   account  (address) 
-- @event   removeMinter(account)
function removeMinter(account)

-- Renounce the Minter Role of TX sender
-- @type    call
-- @event   removeMinter(TX sender)
function renounceMinter()

-- Mint new tokens at an account
-- @type    call
-- @param   account  (address) recipient's address
-- @param   amount   (ubig) amount of tokens to mint
-- @event   mint(TX sender, account, amount)
function mint(account, amount)
```

### + ARC1 : Pausable
``` lua
-- Indicate an account has the Pauser Role
-- @type    query
-- @param   account  (address) 
-- @return  (bool) true/false
function isPauser(account)

-- Grant the Pauser Role to an account
-- @type    call
-- @param   account  (address)
-- @event   addPauser(account)
function addPauser(account)

-- Remove the Pauser Role form an account
-- @type    call
-- @param   account  (address)
-- @event   removePauser(account)
function removePauser(account)

-- Renounce the graned Pauser Role of TX sender
-- @type    call
-- @event   removePauser(TX sender)
function renouncePauser()

-- Indecate if the contract is paused
-- @type    query
-- @return  (bool) true/false
function paused()

-- Trigger stopped state
-- @type    call
-- @event   pause(TX sender)
function pause()

-- Return to normal state
-- @type    call
-- @event   unpause(TX sender)
function unpause()
```

### + ARC1 : All approval
``` lua
-- Indicate the allowance from an account to another
-- @type    query
-- @param   owner       (address) owner's address
-- @param   operator    (address) allowed address
-- @return  (bool) true/false
function isApprovedForAll(owner, operator)

-- Allow an account to use all TX sender's tokens
-- @type    call
-- @param   operator  (address) operator's address
-- @param   approved  (boolean) true/false
-- @event   setApprovalForAll(TX sender, operator, approved)
function setApprovalForAll(operator, approved)

-- Transfer tokens from an account to another, Tx sender have to be approved to spend from the account
-- @type    call
-- @param   from    (address) sender's address
-- @param   to      (address) recipient's address
-- @param   amount  (ubig)    amount of tokens to send
-- @param   ...     addtional data, MUST be sent unaltered in call to 'tokensReceived' on 'to'
-- @event   transferFrom(Tx sender, from, to, amount)
function transferFromAll(from, to, amount, ...)

-- Burn tokens from an account, Tx sender have to be approved to spend from the account
-- @type    call
-- @param   from    (address) sender's address
-- @param   amount  (ubig)    amount of tokens to send
-- @event   burnFrom(Tx sender, from, amount)
function burnFromAll(from, amount)
```

### + ARC1 : Limited approval
``` lua
-- Approve an account to spend the specified amount of Tx sender's tokens
-- @type    call
-- @param   spender (address) spender's address
-- @param   amount  (ubig)    amount of allowed tokens
-- @event   approve(Tx sender, spender, amount)
function approve(spender, amount)

-- Increase the amount of tokens that Tx sender allowed to an account 
-- @type    call
-- @param   spender (address) spender's address
-- @param   amount  (ubig)    amount of increased tokens
-- @event   increaseAllowance(Tx sender, spender, amount)
function increaseAllowance(spender, amount)

-- Decrease the amount of tokens that Tx sender allowed to an account
-- @type    call
-- @param   spender (address) spender's address
-- @param   amount  (ubig)    amount of decreased tokens
-- @event   decreaseAllowance(Tx sender, spender, amount)
function decreaseAllowance(spender, amount)

-- Get amount of remaining tokens that an account allowed to another
-- @type    query
-- @param   owner   (address) owner's address
-- @param   spender (address) spender's address
-- @return  (number) amount of remaining tokens
function allowance(owner, spender)

-- Transfer tokens from an account to another using the allowance mechanism
-- @type    call
-- @param   from   (address) sender's address
-- @param   to     (address) recipient's address
-- @param   amount (ubig)    amount of tokens to send
-- @param   ...     addtional data, MUST be sent unaltered in call to 'tokensReceived' on 'to'
-- @event   transferFrom(Tx sender, from, to, amount)
function transferFromLtd(from, to, amount, ...)

-- Burn tokens from an account using the allowance mechanism
-- @type    call
-- @param   from    (address) sender's address
-- @param   amount  (ubig)    amount of tokens to burn
-- @event   burnFrom(Tx sender, from, amount)
function burnFromLtd(from, amount)
```

### + ARC1 : Blacklist
``` lua
-- Add accounts to blacklist
-- @type    call
-- @param   account_list (list of address)
-- @event   addToBlacklist(account_list)
function addToBlacklist(account_list)

-- Remove accounts from blacklist
-- @type    call
-- @param   account_list  (list of address)
-- @event   removeFromBlacklist(account_list)
function removeFromBlacklist(account_list)

-- Indicate if an account is on blacklist
-- @type    query
-- @param   account   (address)
function isOnBlacklist(account)

-- Transfer tokens from an account to another by filtering with Blacklist
-- @type    call
-- @param   to     (address) recipient's address
-- @param   amount (ubig)    amount of tokens to send
-- @param   ...     addtional data, MUST be sent unaltered in call to 'tokensReceived' on 'to'
-- @event   transfer(Tx sender, to, amount)
function transferByF(to, amount, ...)

```

### + ARC1 : Hook

Contracts, that want to handle tokens, must implement the following functions to define how to handle the tokens they receive. If this function is not implemented, the token transfer will fail. Therefore, it is possible to prevent the token from being lost.

``` lua
-- The ARC1 smart contract calls this function on the recipient after a 'transfer'
-- @type    call
-- @param   operator    (address) a address which called token 'transfer' function
-- @param   from        (address) a sender's address
-- @param   value       (ubig)    amount of tokens to send
-- @param   ...         addtional data, by-passed from 'transfer' arguments
function tokensReceived(operator, from, value, ...)
```
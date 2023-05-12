------------------------------------------------------------------------------
-- Aergo Standard Token Interface (Proposal) - 20211028
-- Mintable
------------------------------------------------------------------------------

extensions["mintable"] = true

state.var {
  _minter = state.map(),       -- address -> boolean
  _max_supply = state.value()  -- unsigned_bignum
}

-- Set the Maximum Supply of tokens
-- @type    internal
-- @param   amount   (ubig) amount of mintable tokens
local function _setMaxSupply(amount)
  _typecheck(amount, 'ubig')
  _max_supply:set(amount)
end

-- Indicate if an account is a minter
-- @type    query
-- @param   account  (address)
-- @return  (bool) true/false
function isMinter(account)
  account = _check_address(account)
  return (account == _contract_owner:get()) or (_minter[account] == true)
end

-- Add an account to minters
-- @type    call
-- @param   account  (address)
-- @event   addMinter(account)
function addMinter(account)
  account = _check_address(account)

  assert(system.getSender() == _contract_owner:get(), "ARC1: only the contract owner can add a minter")

  _minter[account] = true

  contract.event("addMinter", account)
end

-- Remove an account from minters
-- @type    call
-- @param   account  (address)
-- @event   removeMinter(account)
function removeMinter(account)
  account = _check_address(account)

  local contract_owner = _contract_owner:get()
  assert(system.getSender() == contract_owner, "ARC1: only the contract owner can remove a minter")
  assert(account ~= contract_owner, "ARC1: the contract owner is always a minter")
  assert(isMinter(account), "ARC1: not a minter")

  _minter:delete(account)

  contract.event("removeMinter", account)
end

-- Renounce the Minter Role
-- @type    call
-- @event   removeMinter(account)
function renounceMinter()
  local sender = system.getSender()
  assert(sender ~= _contract_owner:get(), "ARC1: contract owner can't renounce minter role")
  assert(isMinter(sender), "ARC1: only minter can renounce minter role")

  _minter:delete(sender)

  contract.event("removeMinter", sender)
end

-- Mint new tokens at an account
-- @type    call
-- @param   account  (address) recipient's address
-- @param   amount   (ubig) amount of tokens to mint
-- @param   ...      additional data, is sent unaltered in call to 'tokensReceived' on 'to'
-- @return  value returned from 'tokensReceived' callback, or nil
-- @event   mint(account, amount) 
function mint(account, amount, ...)
  account = _check_address(account)
  amount = _check_bignum(amount)

  assert(isMinter(system.getSender()), "ARC1: only minter can mint")
  assert(not _max_supply:get() or (_totalSupply:get()+amount) <= _max_supply:get(), "ARC1: totalSupply is over MaxSupply")

  contract.event("mint", account, bignum.tostring(amount))

  return _mint(account, amount, ...)
end

-- Return the Max Supply
-- @type    query
-- @return  amount   (ubig) amount of tokens to mint
function maxSupply()
  return _max_supply:get() or bignum.number(0)
end

-- register the exported functions
abi.register(mint, addMinter, removeMinter, renounceMinter)
abi.register_view(isMinter, maxSupply)

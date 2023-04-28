------------------------------------------------------------------------------
-- Aergo Standard Token Interface (Proposal) - 20211028
-- Blacklist
------------------------------------------------------------------------------

extensions["blacklist"] = true

-- Add accounts to the blacklist
-- @type    call
-- @param   account_list    (list of address)
-- @event   addToBlacklist(account_list)
function addToBlacklist(account_list)
  assert(system.getSender() == _contract_owner:get(), "ARC1: only owner can blacklist accounts")

  for i = 1, #account_list do
    _typecheck(account_list[i], 'address')
    _blacklist[account_list[i]] = true
  end

  contract.event("addToBlacklist", account_list)
end

-- Removes accounts from the blacklist
-- @type    call
-- @param   account_list    (list of address)
-- @event   removeFromBlacklist(account_list)
function removeFromBlacklist(account_list)
  assert(system.getSender() == _contract_owner:get(), "ARC1: only owner can blacklist anothers")

  for i = 1, #account_list do
    _typecheck(account_list[i], 'address')
    _blacklist[account_list[i]] = nil
  end

  contract.event("removeFromBlacklist", account_list)
end

-- Return true when an account is on the blacklist
-- @type    query
-- @param   account   (address)
function isOnBlacklist(account)
  _typecheck(account, 'address')
  return _blacklist[account] == true
end

-- register the exported functions
abi.register(addToBlacklist, removeFromBlacklist)
abi.register_view(isOnBlacklist)

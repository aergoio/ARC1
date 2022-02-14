------------------------------------------------------------------------------
-- Aergo Standard Token Interface (Proposal) - 20211028
-- Burnable
------------------------------------------------------------------------------

extensions["burnable"] = true

-- Burn tokens (from TX sender)
-- @type    call
-- @param   amount  (ubig) amount of token to burn
-- @event   burn(nil, TX sender, amount)

function burn(amount)
  amount = _check_bignum(amount)

  local sender = system.getSender()

  _burn(sender, amount)

  contract.event("burn", sender, bignum.tostring(amount), nil)
end

-- Burn tokens from an account, Tx sender have to be approved to spend from the account
-- @type    call
-- @param   from    (address) sender's address
-- @param   amount  (ubig)    amount of tokens to send
-- @event   burn(Tx sender, from, amount)

function burnFrom(from, amount)
  _typecheck(from, 'address')
  amount = _check_bignum(amount)

  assert(extensions["all_approval"], "ARC1: extension not available")

  local operator = system.getSender()

  assert(operator ~= from, "ARC1: use the burn function")
  assert(isApprovedForAll(from, operator), "ARC1: caller is not approved for holder")

  contract.event("burn", from, bignum.tostring(amount), operator)

  _burn(from, amount)
end

-- Burn tokens from an account using the allowance mechanism
-- @type    call
-- @param   from    (address) sender's address
-- @param   amount  (ubig)    amount of tokens to burn
-- @event   burn(TX Sender, from, amount)

function limitedBurnFrom(from, amount)
  _typecheck(from, 'address')
  amount = _check_bignum(amount)

  assert(extensions["limited_approval"], "ARC1: extension not available")

  local pair = from .. "/" .. system.getSender()

  assert(_allowance[pair], "ARC1: not approved")
  assert(_allowance[pair] >= amount, "ARC1: insufficient allowance")

  _burn(from, amount)
  _allowance[pair] = _allowance[pair] - amount

  contract.event("burn", from, bignum.tostring(amount), system.getSender())
end


abi.register(burn, burnFrom, limitedBurnFrom)

------------------------------------------------------------------------------
-- Aergo Standard Token Interface (Proposal) - 20211028
-- Burnable
------------------------------------------------------------------------------

extensions["burnable"] = true

-- Burn tokens from the caller account
-- @type    call
-- @param   amount  (ubig) amount of tokens to burn
-- @event   burn(account, amount)
function burn(amount)
  amount = _check_bignum(amount)

  local sender = system.getSender()

  _burn(sender, amount)

  contract.event("burn", sender, bignum.tostring(amount))
end

-- register the exported functions
abi.register(burn)

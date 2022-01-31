------------------------------------------------------------------------------
-- Aergo Standard Token Interface (Proposal) - 20211028
-- All approval
------------------------------------------------------------------------------

state.var {
  -- All Approval
  _operators = state.map(),   -- address/address -> boolean
}

-- Indicate the allowance from an account to another
-- @type    query
-- @param   owner       (address) owner's address
-- @param   operator    (address) allowed address
-- @return  (bool) true/false

function isApprovedForAll(owner, operator)
  return (owner == operator) or (_operators[owner.."/".. operator] == true)
end


-- Allow an account to use all TX sender's tokens
-- @type    call
-- @param   operator  (address) operator's address
-- @param   approved  (boolean) true/false
-- @event   setApprovalForAll(TX sender, operator, approved)

function setApprovalForAll(operator, approved)
  _typecheck(operator, 'address')
  _typecheck(approved, 'boolean')

  assert(system.getSender() ~= operator, "cannot set approve self as operator")

  if approved then
     _operators[system.getSender().."/".. operator] = true
  else
    _operators[system.getSender().."/".. operator] = nil
  end

  contract.event("setApprovalForAll", system.getSender(), operator, approved)
end


-- Transfer tokens from an account to another, Tx sender have to be approved to spend from the account
-- @type    call
-- @param   from    (address) sender's address
-- @param   to      (address) recipient's address
-- @param   amount  (ubig)    amount of tokens to send
-- @param   ...     addtional data, MUST be sent unaltered in call to 'tokensReceived' on 'to'
-- @event   transfer(TX Sender, from, to, amount)

function transferFromAll(from, to, amount, ...)
  _typecheck(from, 'address')
  _typecheck(to, 'address')
  amount = _check_bignum(amount)

  assert(isApprovedForAll(from, system.getSender()), "caller is not approved for holder")
  _transfer(from, to, amount, ...)

  contract.event("transfer", system.getSender(), from, to, bignum.tostring(amount))
end


-- Burn tokens from an account, Tx sender have to be approved to spend from the account
-- @type    call
-- @param   from    (address) sender's address
-- @param   amount  (ubig)    amount of tokens to send
-- @event   burn(Tx sender, from, amount)

function burnFromAll(from, amount)
  _typecheck(from, 'address')
  amount = _check_bignum(amount)

  assert(isApprovedForAll(from, system.getSender()), "caller is not approved for holder")
  _burn(from, amount)

  contract.event("burn", system.getSender(), from, bignum.tostring(amount))
end


abi.register(transferFromAll, setApprovalForAll, burnFromAll)
abi.register_view(isApprovedForAll)

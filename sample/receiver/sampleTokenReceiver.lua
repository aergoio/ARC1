function constructor(tokenContractAddress)
  assert(tokenContractAddress ~= nil)
  system.setItem("tokenCtr", tokenContractAddress)
end

function default()
  -- send same amount of token to tx sender
  contract.call(system.getItem("tokenCtr"), "transfer", system.getSender(), system.getAmount(), "send token back")
end

-- ************************************************
-- This function is called when a token is sent to this contract
-- But it is also called by any account, so do not trust it without making checks first

function tokensReceived(operator, from, amount, ...)

  local token_contract = system.getSender()
  assert(token_contract == system.getItem("tokenCtr"), "token not supported")

  -- print additional arguments
  for k, v in pairs({...}) do system.print("Arg#"..k.."="..tostring(v)) end

  -- send same amount of aergo to token sender
  contract.send(from, amount)

end

-- ************************************************

function contractTransferFrom(to, value, ...)
  contract.call(system.getItem("tokenCtr"), "transferFrom", system.getSender(), to, value, ...)
end

function contractBurnFrom(value)
  contract.call(system.getItem("tokenCtr"), "burnFrom", system.getSender(), value)
end

abi.register(contractTransferFrom, contractBurnFrom, tokensReceived)
abi.payable(default)

------------------------------------------------------------------------------
-- Aergo Standard Token Interface (Proposal) - 20211028
-- Core
------------------------------------------------------------------------------

extensions = {}

---- State Data for Token
state.var {
  _contract_owner = state.value(),

  _balances = state.map(),        -- address -> unsigned_bignum
  _totalSupply = state.value(),   -- unsigned_bignum

  _name = state.value(),          -- string
  _symbol = state.value(),        -- string
  _decimals = state.value(),      -- string

  -- Token Metadata
  _metakeys = state.map(),        -- number -> string
  _metadata = state.map(),        -- string -> string

  -- Pausable
  _paused = state.value(),        -- boolean

  -- Blacklist
  _blacklist = state.map()        -- address -> boolean
}

address0 = '1111111111111111111111111111111111111111111111111111' -- null address

-- Type check
-- @type internal
-- @param x variable to check
-- @param t (string) expected type
local function _typecheck(x, t)
  if (x and t == 'address') then -- a string containing an address
    assert(type(x) == 'string', "ARC1: address must be string type")
    -- check address length
    assert(#x == 52, string.format("ARC1: invalid address length (%s): %s", #x, x))
    -- check characters. alphanumeric except for '0, I, O, l'
    local invalidChar = string.match(x, '[^123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]')
    assert(invalidChar == nil, string.format("ARC1: invalid address format: %s contains invalid char %s", x, invalidChar or 'nil'))
    -- check address checksum
    if x ~= address0 then
      local success = pcall(system.isContract, x)
      assert(success, "ARC1: invalid address: " .. x)
    end
  elseif (x and t == 'ubig') then   -- a positive big integer
    -- check unsigned bignum
    assert(bignum.isbignum(x), string.format("ARC1: invalid type: %s != %s", type(x), t))
    assert(x >= bignum.number(0), string.format("ARC1: %s must be positive number", bignum.tostring(x)))
  elseif (x and t == 'uint') then   -- a positive integer
    assert(type(x) == 'number', string.format("ARC1: invalid type: %s != number", type(x)))
    assert(math.floor(x) == x, "ARC1: the number must be an integer")
    assert(x >= 0, "ARC1: the number must be 0 or positive")
  else
    -- check default lua types
    assert(type(x) == t, string.format("ARC1: invalid type: %s != %s", type(x), t or 'nil'))
  end
end

-- check or convert the input to a bignum
function _check_bignum(x)
  -- if the input is a string, convert it to bignum
  if type(x) == 'string' then
    -- check for valid characters: 0-9 and .
    assert(string.match(x, '[^0-9.]') == nil, "ARC1: amount contains invalid character")
    -- count the number of dots
    local _, count = string.gsub(x, "%.", "")
    assert(count <= 1, "ARC1: the amount is invalid")
    -- if the number has a dot
    if count == 1 then
      local num_decimals = _decimals:get()
      -- separate the integer part and the decimal part
      local p1, p2 = string.match('0' .. x .. '0', '(%d+)%.(%d+)')
      -- calculate the number of digits to add
      local to_add = num_decimals - #p2
      if to_add > 0 then
        -- add trailing zeros
        p2 = p2 .. string.rep('0', to_add)
      elseif to_add < 0 then
        -- do not remove trailing digits
        --p2 = string.sub(p2, 1, num_decimals)
        assert(false, "ARC1: too many decimal digits")
      end
      -- join the integer part and the decimal part
      x = p1 .. p2
      -- remove leading zeros
      x = string.gsub(x, '0*', '', 1)
      -- if the result is an empty string, set it to '0'
      if #x == 0 then x = '0' end
    end
    -- convert the string to bignum
    x = bignum.number(x)
  end
  -- check if it is a valid unsigned bignum
  _typecheck(x, 'ubig')
  return x
end

-- initialize the token contract
-- this function should be called by the constructor
-- this function can be called only once
-- @type internal
-- @param name (string) name of this token
-- @param symbol (string) symbol of this token
-- @param decimals (number) decimals of this token
-- @param owner (optional:address) the owner of this contract
local function _init(name, symbol, decimals, owner)

  -- check if the contract is already initialized
  assert(_name:get() == nil, "ARC1: the contract is already initialized")

  if owner == nil or owner == '' then
    owner = system.getCreator()
  elseif owner == 'none' then
    owner = nil
  else
    _typecheck(owner, "address")
  end
  _contract_owner:set(owner)

  _typecheck(name, 'string')
  _typecheck(symbol, 'string')
  _typecheck(decimals, 'uint')

  assert(decimals >= 0 and decimals <= 18, "decimals must be between 0 and 18")

  _name:set(name)
  _symbol:set(symbol)
  _decimals:set(decimals)

  _totalSupply:set(bignum.number(0))
  _paused:set(false)

end

-- Get the token name
-- @type    query
-- @return  (string) name of this token
function name()
  return _name:get()
end

-- Get the token symbol
-- @type    query
-- @return  (string) symbol of this token
function symbol()
  return _symbol:get()
end

-- Get the token decimals
-- @type    query
-- @return  (number) decimals of this token
function decimals()
  return _decimals:get()
end

-- Store token metadata
-- @type    call
-- @param   metadata (table)  lua table containing key-value pairs
function set_metadata(metadata)

  assert(system.getSender() == _contract_owner:get(), "ARC1: permission denied")

  for key,value in pairs(metadata) do
    for i=1,1000,1 do
      local skey = _metakeys[tostring(i)]
      if skey == nil then
        _metakeys[tostring(i)] = key
        break
      end
      if skey == key then
        break
      end
    end
    _metadata[key] = value
  end

end

-- Get token metadata
-- @type    query
-- @return  (string) if key is nil, return all metadata from token,
--                   otherwise return the value linked to the key
function get_metadata(key)

  if key ~= nil then
    return _metadata[key]
  end

  local items = {}
  for i=1,1000,1 do
    key = _metakeys[tostring(i)]
    if key == nil then break end
    local value = _metadata[key]
    items[key] = value
  end
  return items

end

-- Get the balance of an account
-- @type    query
-- @param   owner  (address)
-- @return  (ubig) balance of owner
function balanceOf(owner)
  if owner == nil then
    owner = system.getSender()
  else
    _typecheck(owner, 'address')
  end

  return _balances[owner] or bignum.number(0)
end

-- Return the total supply of this token
-- @type    query
-- @return  (ubig) total supply of this token
function totalSupply()
  return _totalSupply:get()
end

-- register exported functions
abi.register(set_metadata)
abi.register_view(name, symbol, decimals, get_metadata, totalSupply, balanceOf)

-- Call the tokensReceived() function on the recipient contract after a transfer or mint
-- @type internal
-- @param   from   (address) sender's address
-- @param   to     (address) recipient's address
-- @param   amount (ubig) the amount of token that was sent
-- @param   ...    additional data which is sent unaltered in the call
-- @return  value returned from the 'tokensReceived' callback, or nil
local function _callTokensReceived(from, to, amount, ...)
  if to ~= address0 and system.isContract(to) then
    return contract.call(to, "tokensReceived", system.getSender(), from, amount, ...)
  else
    return nil
  end
end

-- Transfer tokens from an account to another
-- @type    internal
-- @param   from    (address) sender's address
-- @param   to      (address) recipient's address
-- @param   amount  (ubig)    amount of token to send
-- @param   ...     additional data, is sent unaltered in call to 'tokensReceived' on 'to'
-- @return  value returned from 'tokensReceived' callback, or nil
local function _transfer(from, to, amount, ...)
  assert(not _paused:get(), "ARC1: paused contract")
  assert(not _blacklist[from], "ARC1: sender is on blacklist")
  assert(not _blacklist[to], "ARC1: recipient is on blacklist")

  -- block transfers of `0` amount
  assert(amount > bignum.number(0), "ARC1: invalid amount")

  local balance = _balances[from] or bignum.number(0)
  assert(balance >= amount, "ARC1: not enough balance")

  _balances[from] = balance - amount
  _balances[to] = (_balances[to] or bignum.number(0)) + amount

  return _callTokensReceived(from, to, amount, ...)
end

-- Mint new tokens to an account
-- @type    internal
-- @param   to      (address) recipient's address
-- @param   amount  (ubig) amount of tokens to mint
-- @param   ...     additional data, is sent unaltered in call to 'tokensReceived' on 'to'
-- @return  value returned from 'tokensReceived' callback, or nil
local function _mint(to, amount, ...)
  assert(not _paused:get(), "ARC1: paused contract")
  assert(not _blacklist[to], "ARC1: recipient is on blacklist")

  _totalSupply:set((_totalSupply:get() or bignum.number(0)) + amount)
  _balances[to] = (_balances[to] or bignum.number(0)) + amount

  return _callTokensReceived(system.getSender(), to, amount, ...)
end

-- Burn tokens from an account
-- @type    internal
-- @param   from   (address)
-- @param   amount  (ubig) amount of tokens to burn
local function _burn(from, amount)
  assert(not _paused:get(), "ARC1: paused contract")
  assert(not _blacklist[from], "ARC1: sender is on blacklist")

  assert(amount > bignum.number(0), "ARC1: invalid amount")

  local balance = _balances[from] or bignum.number(0)
  assert(balance >= amount, "ARC1: not enough balance")

  _balances[from] = balance - amount
  _totalSupply:set(_totalSupply:get() - amount)
end

-- Transfer tokens to an account (from caller)
-- @type    call
-- @param   to      (address) recipient's address
-- @param   amount  (ubig) amount of tokens to send
-- @param   ...     additional data, is sent unaltered in call to 'tokensReceived' on 'to'
-- @return  value returned from 'tokensReceived' callback, or nil
-- @event   transfer(from, to, amount)
function transfer(to, amount, ...)
  _typecheck(to, 'address')
  amount = _check_bignum(amount)
  local from = system.getSender()

  contract.event("transfer", from, to, bignum.tostring(amount))

  return _transfer(from, to, amount, ...)
end

-- Define a new contract owner
function set_contract_owner(address)
  assert(system.getSender() == _contract_owner:get(), "ARC1: permission denied")
  _typecheck(address, "address")
  _contract_owner:set(address)
end

-- Returns a JSON string containing the list of ARC1 extensions
-- that were included on the contract
function arc1_extensions()
  local list = {}
  for name,_ in pairs(extensions) do
    table.insert(list, name)
  end
  return list
end

-- register exported functions
abi.register(transfer, set_contract_owner)
abi.register_view(arc1_extensions)

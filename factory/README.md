# ARC1 Token Factory

It is a contract that is used to create ARC1 token contracts

We create a new token by calling the `new_token` function and informing
the arguments:

* Name
* Symbol
* Decimals
* Initial Supply
* Options (optional)
* Owner   (optional)

The options is a table informing which extensions to add to the token:

* burnable
* mintable
* blacklist
* pausable
* all_approval
* limited_approval

The `owner` is the address that will be registered as the owner of the
token contract. By default it is the entity calling the factory, but
we can specify any address.


## Creating from another contract

The call uses this format:

```lua
contract.call(arc1_factory, "new_token", name, symbol, decimals,
              initial_supply, options)
```

The function returns the contract address.

Here is an example:

```lua
local token = contract.call(arc1_factory, "new_token", name, symbol, 18,
                            '1000000', {mintable=true,burnable=true})
```

And how to inform a max supply (for mintable tokens):

```lua
local token = contract.call(arc1_factory, "new_token", name, symbol, 18,
                            '1000000', {mintable=true,max_supply='5000000'})
```

> :warning: The `initial_supply` and `max_supply` should NOT contain the decimal part!

They can be either string or bignum.

The factory can also be called from herajs, herapy, libaergo...


## Token Factory Address

<table>
  <tr><td>testnet</td><td>AmgSDUteTX3oRdQKUqChQjjdw5roEuxtFxYh8DLpQ29PRNeBWtjj</td></tr>
  <tr><td>alphanet</td><td>AmgcqYVDY9tzuv65QxeX5SrW43KJ3uQuzACZn9KQPqSxtLbR8NvC</td></tr>
</table>


## Updating the Factory

If some of the contract files were modified, you can build a new factory and deploy it.

Then update the services that use it to point to the new address.


## Deploy the Factory

Run:

```
./build.sh
```

Then deploy the generated `ARC1-Factory.lua` to the desired blockchain network.

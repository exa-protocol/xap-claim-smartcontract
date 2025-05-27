# XAP Withdrawal Contract

A Solidity smart contract that enables distribution of XAP tokens to specific wallet addresses. The contract owner can allocate withdrawal allowances to users who can then claim their tokens. This contract has been audited and includes mechanisms for fee detection and allowance adjustment on transfer, emergency pausing, ERC20 token sweeping, and native Ether (ETH) handling.

## Overview

The XAPWithdrawal contract manages XAP token distribution and funds by:

1. Allowing the contract owner to specify how much XAP each address can withdraw.
2. Permitting users to withdraw their allocated tokens up to their allowance.
3. Keeping track of remaining balances for each user.
4. Providing emergency pause functionality for critical operations.
5. Accepting native Ether (ETH) sent to the contract, which can be recovered by the owner using the `sweepETH` function.

## Contract Details

- **Token Standard**: ERC20 (XAP)
- **Native Currency**: Accepts and allows owner to sweep ETH.
- **Access Control**: Ownable pattern (only owner can set allowances and manage contract state).
- **Batch Operations Limit**: `MAX_BATCH_SIZE` (currently 200) for `setAllowanceBatch` and `addAllowanceBatch`.

## Functions

### For Contract Owner

#### `constructor(address _xapTokenAddress)`

- Creates the contract, setting the XAP token address and the deployer as owner.
- Example: `new XAPWithdrawal("0x123...789")`

#### `setAllowance(address _recipient, uint256 _amount)`

- Sets a specific withdrawal allowance for a single address (overwrites any previous amount).
- Must be called when the contract is not paused.
- Example: To allow withdrawal of 5 XAP: `setAllowance("0xabc...def", 500000000)`

#### `addAllowance(address _recipient, uint256 _amountToAdd)`

- Adds to the existing allowance for a single address.
- Must be called when the contract is not paused.
- Example: To add 2.5 XAP to existing allowance: `addAllowance("0xabc...def", 250000000)`

#### `setAllowanceBatch(address[] _recipients, uint256[] _amounts)`

- Sets allowances for multiple addresses in one transaction (gas-efficient).
- Array lengths must match and not exceed `MAX_BATCH_SIZE`.
- Must be called when the contract is not paused.
- **Gas Consideration (M-3)**: Be mindful of gas limits, especially on L2 rollups or when setting allowances for many _new_ addresses. Each new address initialized in `withdrawableBalance` incurs a significant SSTORE gas cost (approx. 20,000 gas). Large batches for new users can approach block gas limits. Consider using smaller chunks (e.g., 50-100 addresses) if you encounter issues on gas-sensitive networks.
- Example:
  ```
  setAllowanceBatch(
    ["0xabc...def", "0x123...456", "0x789...abc"],
    [100000000, 200000000, 300000000]
  )
  ```

#### `addAllowanceBatch(address[] _recipients, uint256[] _amountsToAdd)`

- Adds allowances for multiple addresses in one transaction.
- Array lengths must match and not exceed `MAX_BATCH_SIZE`.
- Must be called when the contract is not paused.
- **Gas Consideration (M-3)**: Similar to `setAllowanceBatch`, be mindful of gas limits, especially on L2 rollups or when adding allowances for many _new_ addresses. Each new address initialized incurs a significant SSTORE gas cost. Consider using smaller chunks.
- Example:
  ```
  addAllowanceBatch(
    ["0xabc...def", "0x123...456"],
    [50000000, 75000000]
  )
  ```

#### `sweep(address _token, address _to, uint256 _amount)`

- Allows the owner to rescue any ERC20 tokens accidentally sent to this contract, including the primary XAP token.
- This is a recovery mechanism.
- Example: `sweep("0xTOKEN_ADDRESS", "0xRECIPIENT_ADDRESS", 1000000000)`

#### `sweepETH(address payable _to, uint256 _amount)`

- Allows the owner to withdraw native Ether (ETH) that may have been accidentally sent or forced (e.g., via `selfdestruct`) into the contract.
- Can only be called when the contract is not paused.
- If `_to` is `address(0)`, Ether is sent to the contract owner.
- If `_amount` is `0`, the entire ETH balance of the contract will be swept. Otherwise, the specified `_amount` is swept.
- Emits an `EtherSwept` event.
- Example: `sweepETH(payable(owner()), 1000000000000000000)` (to sweep 1 ETH to owner)
- Example (sweep all ETH): `sweepETH(payable(owner()), 0)`

#### `pause()`

- Pauses critical contract functions.
- Can only be called by the owner when the contract is not already paused.
- Emits a `Paused` event.

#### `unpause()`

- Resumes critical contract functions.
- Can only be called by the owner when the contract is paused.
- Emits an `Unpaused` event.

#### `transferOwnership(address newOwner)`

- Transfers contract ownership to another address.
- Example: `transferOwnership("0xnew...owner")`

#### `getTotalPendingXAPWithdrawals()`

- Returns the total sum of all XAP allowances currently pending withdrawal.
- This is a public view function.
- This provides a quick way to see the contract's total XAP liabilities.

### For Users

#### `withdraw(uint256 _amount)`

- Allows a user to withdraw their allocated XAP tokens.
- The user requests `_amount`. Their `withdrawableBalance` is debited by this `_amount`.
- The contract attempts to transfer `_amount` of XAP tokens to the user.
- For fee-on-transfer or deflationary tokens, the user will receive the net amount (after fees), and their `withdrawableBalance` is debited by the full `_amount` requested.
- Reverts on insufficient initial allowance, insufficient contract balance for the transfer, or if the contract is paused.
- Emits a `Withdrawn` event on success (logging the `amount` withdrawn, which is both the requested and actual amount from the contract's perspective).
- Example: To request a withdrawal of 1 XAP: `withdraw(100000000)`

#### `fundContract(uint256 _amount)`

- Allows anyone to deposit XAP tokens directly to the contract to fund withdrawals.
- Must be called when the contract is not paused.
- Emits a `ContractFunded` event.
- Example: To deposit 10 XAP: `fundContract(1000000000)` (caller must have approved the contract to spend their XAP).

#### `paused()`

- Returns `true` if the contract is paused, `false` otherwise.

#### `MAX_BATCH_SIZE()`

- Returns the maximum number of addresses that can be processed in batch operations (currently 200).

#### `getTotalPendingXAPWithdrawals()`

- Returns the total sum of all XAP allowances currently pending withdrawal. (Public)

### Other Contract Interactions

#### `receive() external payable`

- Allows the contract to receive native Ether (ETH) through direct transfers or via `selfdestruct` from other contracts.
- Emits an `EtherReceived` event when ETH is sent to the contract.
- This ETH can then be managed by the owner using the `sweepETH` function.

### View Functions

#### `withdrawableBalance(address user)`

- Returns the current amount a specific address is allowed to withdraw.

#### `owner()`

- Returns the current contract owner's address.

#### `xapToken()`

- Returns the address of the XAP token contract.

## Events

- `OwnershipTransferred(address indexed previousOwner, address indexed newOwner)`
- `AllowanceSet(address indexed recipient, uint256 amount)`
- `AllowanceAdded(address indexed recipient, uint256 amountAdded)`
- `Withdrawn(address indexed recipient, uint256 actualAmount, uint256 requestedAmount)`
- `TokensSwept(address indexed token, address indexed recipient, uint256 amount)`
- `ContractFunded(address indexed funder, uint256 amount)`
- `Paused(address account)`
- `Unpaused(address account)`
- `EtherReceived(address indexed from, uint256 amount)`
- `EtherSwept(address indexed to, uint256 amount)`

## Deployment

1. Deploy the contract with the XAP token contract address as the constructor parameter.
2. Fund the contract with XAP tokens (e.g., using `fundContract` or direct transfer).
3. The contract can also receive ETH at its address.
4. Set allowances for users.

## Usage Example

### For Contract Owner:

1. **Deploy contract.**
2. **Fund with XAP tokens.**
3. **Set allowances.** (Be mindful of gas for batch operations, see Notes below)
4. **Emergency Pause (if needed):** `withdrawalContract.pause();`
5. **Sweep accidentally sent ETH (if any):**
   ```solidity
   // Assuming 0.5 ETH was sent to the contract
   withdrawalContract.sweepETH(payable(owner()), 500000000000000000);
   // To sweep all ETH from the contract to the owner:
   // withdrawalContract.sweepETH(payable(owner()), 0);
   ```

### For Users:

1. **Check allowance:** `uint256 myAllowance = withdrawalContract.withdrawableBalance(myAddress);`
2. **Withdraw tokens:** `withdrawalContract.withdraw(300000000);`
3. **Use `sweepETH` to rescue accidentally sent/forced Ether. If an amount of `0` is specified, the entire ETH balance of the contract is swept.**
4. **Use `pause` or `unpause` to manage contract state.**

## Interacting on Etherscan

### For Contract Owner:

1. Navigate to the verified contract on Etherscan and connect your wallet.
2. Go to "Write Contract" tab.
3. Use `setAllowance`, `addAllowance`, `setAllowanceBatch`, or `addAllowanceBatch` to grant withdrawal permissions. (Note gas implications for batches of new users).
4. Use `sweep` to rescue ERC20 tokens if necessary.
5. Use `sweepETH` to rescue accidentally sent/forced Ether.
6. Use `pause` or `unpause` to manage contract state.

### For Users:

1. Navigate to the verified contract on Etherscan and connect your wallet.
2. Go to "Write Contract" tab.
3. Use the `withdraw` function with the amount you wish to withdraw.
4. Use `fundContract` if you wish to add XAP to the contract's balance.
5. **Use `sweepETH` to rescue accidentally sent/forced Ether. If an amount of `0` is specified, the entire ETH balance of the contract is swept.**
6. **Use `pause` or `unpause` to manage contract state.**

## Notes

- All token amounts are specified in their smallest unit (e.g., if XAP has 18 decimals, 1 XAP = 10^18 units).
- The contract can receive Ether; the owner can withdraw this Ether using `sweepETH`. An amount of `0` in `sweepETH` will sweep the entire contract balance.
- For fee-on-transfer tokens, the user's `withdrawableBalance` is debited by the full requested amount. The user will receive the net amount after any fees imposed by the token contract itself.
- The contract must have sufficient XAP balance for withdrawals to succeed.
- **Gas Considerations for Batch Operations (M-3)**: While `MAX_BATCH_SIZE` is 200, using the maximum batch size for `setAllowanceBatch` or `addAllowanceBatch` can lead to very high gas costs, especially if many of the recipients are new (i.e., not previously having an allowance). Each new storage slot initialization (SSTORE for a zero to non-zero value) costs significantly more gas. On networks with lower block gas limits (like some L2s), large batches for new users might exceed the limit. It is strongly recommended to:
  - Test batch sizes on your target network.
  - Implement chunking logic in your calling scripts/frontend to break large allowance updates into smaller transactions if you are dealing with many new addresses or operating on a gas-sensitive network.
  - Consider a smaller `MAX_BATCH_SIZE` if deploying to a known low-gas L2, though this requires a contract modification.

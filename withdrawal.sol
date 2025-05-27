//
//  ███████╗██╗  ██╗ █████╗     ██████╗ ██████╗  ██████╗ ████████╗ ██████╗  ██████╗ ██████╗ ██╗
//  ██╔════╝╚██╗██╔╝██╔══██╗    ██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔═══██╗██╔════╝██╔═══██╗██║
//  █████╗   ╚███╔╝ ███████║    ██████╔╝██████╔╝██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║
//  ██╔══╝   ██╔██╗ ██╔══██║    ██╔═══╝ ██╔══██╗██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║
//  ███████╗██╔╝ ██╗██║  ██║    ██║     ██║  ██║╚██████╔╝   ██║   ╚██████╔╝╚██████╗╚██████╔╝███████╗
//  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝
//

// Project website: https://www.exaprotocol.com
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC20
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

/**
 * @title Address
 * @dev Collection of functions related to the address type
 */
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @title Ownable
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @title ReentrancyGuard
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

/**
 * @title Pausable
 * @dev Contract module which allows children to implement an emergency stop mechanism.
 */
abstract contract Pausable is Ownable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state. Can only be called by the owner.
     */
    function pause() public virtual onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state. Can only be called by the owner.
     */
    function unpause() public virtual onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

/**
 * @title XAPWithdrawal
 * @dev This contract allows the owner to allocate XAP tokens to specific addresses,
 * which can then withdraw their allocated amount. The contract must hold the XAP tokens
 * intended for withdrawal.
 */
contract XAPWithdrawal is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    IERC20 public immutable xapToken;
    uint256 public constant MAX_BATCH_SIZE = 150;

    // Mapping from user address to the remaining amount they are allowed to withdraw
    mapping(address => uint256) public withdrawableBalance;

    // Sum of all withdrawable balances
    uint256 public totalPendingXAPWithdrawals;

    // Custom errors for gas optimization
    error ZeroAddress();
    error ZeroAmount();
    error InsufficientBalance();
    error ArrayLengthMismatch();
    error EmptyArray();
    error BatchSizeExceeded();
    error AllowanceOverflow();
    error ETHTransferFailed();
    error InsufficientContractBalance();

    event AllowanceSet(address indexed recipient, uint256 amount);
    event AllowanceAdded(address indexed recipient, uint256 amountAdded);
    event Withdrawn(
        address indexed recipient,
        uint256 actualAmount,
        uint256 requestedAmount
    );
    event TokensSwept(
        address indexed token,
        address indexed recipient,
        uint256 amount
    );
    event ContractFunded(address indexed funder, uint256 amount);
    event EtherReceived(address indexed from, uint256 amount);
    event EtherSwept(address indexed to, uint256 amount);

    // Add this validation to all allowance-setting functions
    modifier sufficientContractBalance() {
        _;
        if (xapToken.balanceOf(address(this)) < totalPendingXAPWithdrawals) {
            revert InsufficientContractBalance();
        }
    }

    /**
     * @dev Sets the XAP token address. The deployer becomes the owner.
     * @param _xapTokenAddress The address of the XAP ERC20 token contract.
     */
    constructor(address _xapTokenAddress) Ownable(msg.sender) {
        if (_xapTokenAddress == address(0)) revert ZeroAddress();
        xapToken = IERC20(_xapTokenAddress);
    }

    /**
     * @dev Sets the total withdrawable balance for a recipient. Overwrites any existing balance.
     * Can only be called by the owner.
     * @param _recipient The address receiving the allowance.
     * @param _amount The total amount they are allowed to withdraw.
     */
    function setAllowance(
        address _recipient,
        uint256 _amount
    ) external onlyOwner whenNotPaused sufficientContractBalance {
        if (_recipient == address(0)) revert ZeroAddress();

        uint256 oldBalance = withdrawableBalance[_recipient];
        withdrawableBalance[_recipient] = _amount;

        unchecked {
            totalPendingXAPWithdrawals =
                (totalPendingXAPWithdrawals - oldBalance) +
                _amount;
        }

        emit AllowanceSet(_recipient, _amount);
    }

    /**
     * @dev Sets the total withdrawable balance for multiple recipients in a single transaction.
     * Overwrites any existing balances. Can only be called by the owner.
     * This function saves gas when setting allowances for many addresses at once.
     * @param _recipients Array of addresses receiving the allowances.
     * @param _amounts Array of amounts they are allowed to withdraw.
     *
     * @notice WARNING: Large batches may exceed block gas limits, especially on L2s or when
     * setting allowances for many new addresses (which incurs higher SSTORE costs).
     * It's recommended to limit batches (e.g., to ~100-200, see MAX_BATCH_SIZE)
     * and handle chunking in the frontend or calling script.
     */
    function setAllowanceBatch(
        address[] calldata _recipients,
        uint256[] calldata _amounts
    ) external onlyOwner whenNotPaused sufficientContractBalance {
        uint256 length = _recipients.length;
        if (length != _amounts.length) revert ArrayLengthMismatch();
        if (length == 0) revert EmptyArray();
        if (length > MAX_BATCH_SIZE) revert BatchSizeExceeded();

        for (uint256 i = 0; i < length; ) {
            address recipient = _recipients[i];
            if (recipient == address(0)) revert ZeroAddress();

            uint256 oldBalance = withdrawableBalance[recipient];
            uint256 newBalance = _amounts[i];
            withdrawableBalance[recipient] = newBalance;

            unchecked {
                totalPendingXAPWithdrawals =
                    (totalPendingXAPWithdrawals - oldBalance) +
                    newBalance;
                ++i;
            }

            emit AllowanceSet(recipient, newBalance);
        }
    }

    /**
     * @dev Adds to the withdrawable balance for multiple recipients in a single transaction.
     * Can only be called by the owner.
     * @param _recipients Array of addresses receiving the additional allowances.
     * @param _amountsToAdd Array of amounts to add to their withdrawable balances.
     *
     * @notice WARNING: Large batches may exceed block gas limits, especially on L2s or when
     * adding allowances for many new addresses (which incurs higher SSTORE costs).
     * It's recommended to limit batches (e.g., to ~100-200, see MAX_BATCH_SIZE)
     * and handle chunking in the frontend or calling script.
     */
    function addAllowanceBatch(
        address[] calldata _recipients,
        uint256[] calldata _amountsToAdd
    ) external onlyOwner whenNotPaused sufficientContractBalance {
        uint256 length = _recipients.length;
        if (length != _amountsToAdd.length) revert ArrayLengthMismatch();
        if (length == 0) revert EmptyArray();
        if (length > MAX_BATCH_SIZE) revert BatchSizeExceeded();

        for (uint256 i = 0; i < length; ) {
            address recipient = _recipients[i];
            if (recipient == address(0)) revert ZeroAddress();

            uint256 currentBalance = withdrawableBalance[recipient];
            uint256 amountToAdd = _amountsToAdd[i];
            uint256 newBalance = currentBalance + amountToAdd;

            if (newBalance < currentBalance) revert AllowanceOverflow();

            withdrawableBalance[recipient] = newBalance;
            totalPendingXAPWithdrawals += amountToAdd;

            emit AllowanceAdded(recipient, amountToAdd);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Adds to the withdrawable balance for a recipient.
     * Can only be called by the owner.
     * @param _recipient The address receiving the additional allowance.
     * @param _amountToAdd The amount to add to their withdrawable balance.
     */
    function addAllowance(
        address _recipient,
        uint256 _amountToAdd
    ) external onlyOwner whenNotPaused sufficientContractBalance {
        if (_recipient == address(0)) revert ZeroAddress();

        uint256 currentBalance = withdrawableBalance[_recipient];
        uint256 newBalance = currentBalance + _amountToAdd;

        if (newBalance < currentBalance) revert AllowanceOverflow();

        withdrawableBalance[_recipient] = newBalance;
        totalPendingXAPWithdrawals += _amountToAdd;

        emit AllowanceAdded(_recipient, _amountToAdd);
    }

    /**
     * @dev Allows a user to withdraw their allocated XAP tokens.
     * The user must have sufficient withdrawable balance, and the contract must hold enough tokens.
     * Protected against reentrancy attacks with nonReentrant modifier.
     * @param _amount The amount of XAP tokens to withdraw.
     *
     * @notice For fee-on-transfer or deflationary tokens, this function will debit the full
     * requested amount from the user's withdrawable balance, even if they receive less due to fees.
     */
    function withdraw(uint256 _amount) external nonReentrant whenNotPaused {
        if (_amount == 0) revert ZeroAmount();

        uint256 availableBalance = withdrawableBalance[msg.sender];
        if (availableBalance < _amount) revert InsufficientBalance();

        // Effect: Update user's XAP allowance
        unchecked {
            withdrawableBalance[msg.sender] = availableBalance - _amount;
            totalPendingXAPWithdrawals -= _amount;
        }

        // Interaction: Transfer XAP token. SafeERC20's safeTransfer will handle
        // reverts if the contract has insufficient balance or other transfer issues.
        xapToken.safeTransfer(msg.sender, _amount);

        emit Withdrawn(msg.sender, _amount, _amount);
    }

    /**
     * @dev Allows the owner to rescue any ERC20 tokens accidentally sent to this contract,
     * @param _token The address of the token to sweep
     * @param _to The address to send the tokens to
     * @param _amount The amount of tokens to sweep
     */
    function sweep(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyOwner nonReentrant {
        if (_token == address(0)) revert ZeroAddress();
        if (_to == address(0)) revert ZeroAddress();

        IERC20(_token).safeTransfer(_to, _amount);
        emit TokensSwept(_token, _to, _amount);
    }

    /**
     * @dev Allows anyone to deposit XAP tokens directly to the contract to fund withdrawals.
     * @param _amount The amount of XAP tokens to deposit
     */
    function fundContract(uint256 _amount) external nonReentrant whenNotPaused {
        if (_amount == 0) revert ZeroAmount();
        xapToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit ContractFunded(msg.sender, _amount);
    }

    /**
     * @dev Allows the owner to withdraw accidentally sent ETH from the contract.
     * Can only be called by the owner when the contract is not paused.
     * @param _to The address to send the ETH to. Defaults to owner if address(0).
     * @param _amount The amount of ETH to sweep. If 0, sweeps the entire contract ETH balance.
     */
    function sweepETH(
        address payable _to,
        uint256 _amount
    ) external onlyOwner nonReentrant whenNotPaused {
        address payable recipient = _to;
        if (recipient == address(0)) {
            recipient = payable(owner());
        }
        if (recipient == address(0)) revert ZeroAddress();

        uint256 amountToSweep = _amount;
        if (amountToSweep == 0) {
            amountToSweep = address(this).balance;
        }

        if (amountToSweep == 0) revert ZeroAmount();
        if (amountToSweep > address(this).balance) revert InsufficientBalance();

        (bool success, ) = recipient.call{value: amountToSweep}("");
        if (!success) revert ETHTransferFailed();

        emit EtherSwept(recipient, amountToSweep);
    }

    /**
     * @dev Accepts Ether sent directly to the contract and emits an EtherReceived event.
     * This allows the contract to gracefully handle accidental or forced ETH transfers.
     * ETH can be swept later using the sweepETH function.
     */
    receive() external payable {
        emit EtherReceived(msg.sender, msg.value);
    }

    /**
     * @dev Returns the total sum of all pending XAP withdrawals.
     * This is a public view function.
     */
    function getTotalPendingXAPWithdrawals() external view returns (uint256) {
        return totalPendingXAPWithdrawals;
    }
}

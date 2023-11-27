//SPDX-Liscense-Identifier: MIT

pragma solidity 0.8.10;


import "https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPoolAddressesProvider.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract ArbitrageFlashLoan is FlashLoanSimpleReceiverBase {
    address payable owner;

    constructor(address _addressProvider)
        FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
    {
        owner = payable(msg.sender);
    }

    function fn_RequestFlashLoan(address _token, uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        //Requesting from the pool

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );

    }
    //simple arbitrage assuming where user gets 10 percent profit of whatever the amount he puts in 
    function arbitrageUSDC(address _tokenAddress, uint256 _amount) private returns(bool) {
        uint256 arbitraged_amount = (_amount / 10);
        IERC20 token = IERC20(_tokenAddress);
        return token.transfer(owner, arbitraged_amount);
    }




    /**
        This function is called after your contract has received the flash loaned amount
     */
    function  executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    )  external override returns (bool) {
        //
        // This contract now has the funds requested.
        // Your logic goes here.
        //
        bool status = arbitrageUSDC(asset, amount);
        // At the end of your logic above, this contract owes
        // the flashloaned amount + premiums.
        // Therefore ensure your contract has enough to repay
        // these amounts.

        // Approve the Pool contract allowance to *pull* the owed amount
        uint256 totalAmount = amount + premium;
        IERC20(asset).approve(address(POOL), totalAmount);

        return true;
    }

    receive() external payable {}

}


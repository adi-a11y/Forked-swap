pragma solidity 0.6.6;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract ForkedToken is ERC20('Forked Token','FKT') {
    address public admin;
    address public liquidator;

    constructor() public {
        admin = msg.sender;
    }

    function setLiquidator(address _liquidator) external {
        require(msg.sender == admin,'Only admin');
        liquidator = _liquidator;
    }

    function mint(address to,uint amount) external {
        require(msg.sender == liquidator,'Only liquidator');
        _mint(to,amount);
    }
}
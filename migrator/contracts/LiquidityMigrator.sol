pragma solidity 0.6.6;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import './IUniswapV2Pair.sol';
import './ForkedToken.sol';

contract liquidator {
    IUniswapV2Router02 public router;
    IUniswapV2Pair public pair;
    IUniswapV2Router02 public routerFork;
    IUniswapV2Pair public pairFork;
    ForkedToken public forkedToken;
    address public admin;

    mapping(address => uint) public unclaimedBalances;
    bool public migrationDone;

    constructor(
        address _router,
        address _pair,
        address _routerFork,
        address _pairFork,
        address _forkedToken
    ) public {
        router = IUniswapV2Router02(_router);
        pair = IUniswapV2Pair(_pair);
        routerFork = IUniswapV2Router02(_routerFork);
        pairFork = IUniswapV2Pair(_pairFork);
        forkedToken = ForkedToken(_forkedToken);
        admin = msg.sender;
    }

    function deposit(uint amount) external {
        require(migrationDone == false,'Migration has already been done');
        pair.transferFrom(msg.sender, address(this),amount);
        forkedToken.mint(msg.sender,amount);
        unclaimedBalances[msg.sender] += amount;
    }

    function migrate() external {
        require(msg.sender == admin,'only admin');
        require(migrationDone == false,'Migration has already been done');
        IERC20 token0 = IERC20(pair.token0());
        IERC20 token1 = IERC20(pair.token1());
        uint totalBalance = pair.balanceOf(address(this));
        router.removeLiquidity(
            address(token0),
            address(token1),
            totalBalance,
            0,
            0,
            address(this),
            block.timestamp
        );
        uint token0balance = token0.balanceOf(address(this));
        uint token1balance = token1.balanceOf(address(this));
        token0.approve(address(routerFork),token0balance);
        token1.approve(address(routerFork),token1balance);
        routerFork.addLiquidity(
            address(token0),
            address(token1),
            token0balance,
            token1balance,
            token0balance,
            token1balance,
            address(this),
            block.timestamp
        );
    
    migrationDone = true;
    }

    function claimLptokens() external {
        require(unclaimedBalances[msg.sender] > 0,'No unclaimed balances');
        require(migrationDone == true, 'Migration not done yet');
        uint amountTosend = unclaimedBalances[msg.sender];
        unclaimedBalances[msg.sender] = 0;
        pairFork.transfer(msg.sender,amountTosend);
    }
 
}
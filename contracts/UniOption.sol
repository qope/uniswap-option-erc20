// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@prb/math/contracts/PRBMathSD59x18.sol";

contract UniOption {
    IERC20 private _dai;
    IERC20 private _weth;
    IUniswapV3Factory private _factory;
    IUniswapV3Pool private _pool;

    constructor(
        address daiAddress, 
        address wethAddress, 
        address factoryAddress,
        uint24 fee
        ) {
        _dai = IERC20(daiAddress);
        _weth = IERC20(wethAddress);
        _factory = IUniswapV3Factory(factoryAddress);
        address poolAddress = _factory.getPool(daiAddress, wethAddress, fee);
        _pool = IUniswapV3Pool(poolAddress);
    }

    function getAveragePrice() public view returns (uint){
        (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) = _pool.observe([0, 100]);
        int128 a0 = tickCumulatives[0];
        int128 a1 = tickCumulatives[1];
        int128 p = (a1 - a0)/100;
        if (p > 0) {
            uint num = 10000**p;
            uint den = 10001**p + 10000**p;
            return num/den;
        } else {
            uint num = 10001**(-p);
            uint den = 10001**(-p) + 10000**(-p);
            return num/den;
        }
    }
}

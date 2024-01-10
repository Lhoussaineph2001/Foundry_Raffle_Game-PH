// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library ETH_USD  {

    

    function getPrice( AggregatorV3Interface  Usd) internal view returns(uint256){

        (,int256 Price,,,)  =  Usd.latestRoundData();

         
        return uint256(Price * 1e10); 

    }

    function getConverter( uint256 amount , AggregatorV3Interface converttoUSD) internal view returns(uint256) {

        
        uint256 price  = getPrice(converttoUSD);

        uint256 amounttousd = (amount * price) / 1e18;

        return amounttousd;

    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Script , console} from 'forge-std/Script.sol';
import { VRFCoordinatorV2Mock } from '../test/Mocks/VRFCoordinatorV2Mock.sol';
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

import { HelperConfig } from './HelperConfig.s.sol';

contract  CreateSubscription is Script {

    HelperConfig heleprconfig;


    function run() external returns(uint64) {

        return createSubscriptionUsingConfig();

    }

     function createSubscriptionUsingConfig() public returns(uint64){

        heleprconfig = new HelperConfig();

        (,,,address vrfCoordinator,,, ,uint256 deployKey) = heleprconfig.ActiveNetwork();

        return createSubscription(vrfCoordinator ,deployKey);

    }
       
    function createSubscription( address vrfCoordinator ,uint256 deployerkey) public returns(uint64 subId) {

    
        vm.startBroadcast(deployerkey);

        subId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();

        vm.stopBroadcast();

        return subId;

    }
}
 

contract FundSubcription is Script {

        uint96 public constant FUND_AMOUNT = 3 ether;  // 3 link each run

        function run() external {

            fundSubscriptionUsingConfig();

        }
    
       function fundSubscriptionUsingConfig() public {

        HelperConfig helperconfig = new HelperConfig();

        (,,, address vrfCoordinator, uint64 subId, , address link ,uint256 deployerkey) = helperconfig.ActiveNetwork();
  
         fundSubscription(subId,vrfCoordinator , link  ,deployerkey);

       }


       function fundSubscription(uint64 subId , address vrfCoordinator  , address link  ,uint256 deployerkey) public  {


        if (block.chainid == 31337){ // 31337 => anvil running
        
        vm.startBroadcast(deployerkey);
        
        VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(subId,FUND_AMOUNT);

        vm.stopBroadcast();

        }else {

           vm.startBroadcast(deployerkey);
                
                LinkToken(link).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subId)
              );


            vm.stopBroadcast();
        }

       }
       
       }

    contract AddConsumer is Script {

     function addConsumer(address contractToAddToVrf,address vrfCoordinator,uint64 subId, uint256 deployKey

      ) public {

        vm.startBroadcast(deployKey);
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(
            subId,
            contractToAddToVrf
        );
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig(address mostRecentlyDeployed) public {

        HelperConfig helperConfig = new HelperConfig();
        

        (,,,address vrfCoordinator,uint64 subId,,,uint256 deployKey) = helperConfig.ActiveNetwork();

        addConsumer(mostRecentlyDeployed, vrfCoordinator, subId, deployKey);
    }

    function run() external {

        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );

        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}


 


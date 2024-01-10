// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Script , console} from 'forge-std/src/Script.sol';
import { VRFCoordinatorV2Mock } from '../test/Mocks/VRFCoordinatorV2Mock.sol';
import { HelperConfig } from './HelperConfig.s.sol';

contract  CreateSubscription is Script {

    HelperConfig heleprconfig;


    function run() external returns(uint64) {

        return createSubscriptionUsingConfig();

    }

     function createSubscriptionUsingConfig() public returns(uint64){

        heleprconfig = new HelperConfig();

        (,,address vrfCoordinator,,,uint256 deployKey) = heleprconfig.ActiveNetwork();

        return createSubscription(vrfCoordinator, deployKey);

    }
       function createSubscription( address vrfCoordinator /** , address Link */ ,uint256 deployerkey) public returns(uint64 subId) {

    
        vm.startBroadcast(deployerkey);

       subId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();

        vm.stopBroadcast();

        return subId;

    }
}
 

contract FundSubcription is Script {

        uint96 public constant FUND_AMOUT = 3 ether;  // 3 link each run

        function run() external {

            fundSubscriptionUsingConfig();

        }
    
       function fundSubscriptionUsingConfig() public {

        HelperConfig helperconfig = new HelperConfig();

        (,, address vrfCoordinator, uint64 subId,/** , address Link */,uint256 deployerkey) = helperconfig.ActiveNetwork();
  
         fundSubscription(subId,vrfCoordinator /**, Link */ ,deployerkey);

       }


       function fundSubscription(uint64 subId , address vrfCoordinator /** , address Link */ ,uint256 deployerkey) public  {


        if (block.chainid == 31337){ // 31337 => anvil running
        
        vm.startBroadcast(deployerkey);
        
        VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(subId,FUND_AMOUT);

        vm.stopBroadcast();

        }else {}

       }
       
       }

contract AddConsumer is Script {

    HelperConfig heleprconfig;

      function run(address consumer ) external  {

       addConsumerUsingConfig(consumer );

    }

    function addConsumerUsingConfig( address consumer  ) public {

        heleprconfig = new HelperConfig();

        (,,address vrfCoordinator,uint64 subId,,uint256 deployKey) = heleprconfig.ActiveNetwork();

        addConsumer(subId , vrfCoordinator,consumer , deployKey);

    }

    function addConsumer( uint64 subId , address vrfCoordinator ,address consumer , uint256 deployKey) public{

        vm.startBroadcast(deployKey);

        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId,consumer);

        vm.stopBroadcast();


    }

} 


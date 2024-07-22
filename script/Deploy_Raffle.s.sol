// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import { Script , console} from 'forge-std/Script.sol';
import { RaffleGame } from '../src/Raffle_Game.sol';
import { HelperConfig } from './HelperConfig.s.sol';
import { CreateSubscription , FundSubcription , AddConsumer} from './Interaction.s.sol';


contract DeployRaffle is Script {

    HelperConfig heleprconfig;
    RaffleGame rafflegame;

    uint96 private constant AMOUNT = 1 ether;


    function run() external returns(RaffleGame , HelperConfig) {

        heleprconfig = new HelperConfig();
        
        (
        
        address pricefee,
        bytes32 gasLane,
        uint256  interval,
        address vrfCoordinator,
        uint64 subId,
        uint32 callbackGasLimit,
        address link,
        uint256 deployKey

        ) = heleprconfig.ActiveNetwork();

        if( subId == 0 ) {

            CreateSubscription subscription = new CreateSubscription();

            subId = subscription.createSubscription(vrfCoordinator,deployKey);

            FundSubcription fundsubcription = new FundSubcription();

            fundsubcription.fundSubscription( subId , vrfCoordinator , link ,deployKey);

        }



        vm.startBroadcast(deployKey);

        rafflegame = new RaffleGame(
        
         pricefee,
         gasLane,
         interval,
         vrfCoordinator,
         subId,
         callbackGasLimit,
         deployKey

        );

        vm.stopBroadcast();


        AddConsumer consumer = new AddConsumer();

        consumer.addConsumer(address(rafflegame) ,vrfCoordinator,subId , deployKey);
        
        return (rafflegame , heleprconfig);
        
    }


}
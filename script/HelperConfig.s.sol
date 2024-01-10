// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import { Script } from 'forge-std/src/Script.sol';
import { VRFCoordinatorV2Mock } from '../test/Mocks/VRFCoordinatorV2Mock.sol';
import { MockV3Aggregator } from '../test/Mocks/MockV3Aggregator.sol';


contract HelperConfig is Script {


    uint256 public constant DEFAULT_ANVIL_PRIVATE_KEY = 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6;
    uint256 private constant SEPOLIA_CHAINID = 11155111 ;
    uint96 private constant BASE_FEE = 0.25 ether;
    uint96 private constant GAS_PRICE_LINK = 1e9;
    uint8 private constant ID = 3 ;
    uint8 private constant DECIMAL = 8;
    int256 private constant INITAIL_ANWSER = 2000;

    Networkconfig public ActiveNetwork;


    struct Networkconfig {

        
        address pricefee;
        uint256  interval;
        address vrfCoordinator;
        uint64 subId;
        uint32 callbackGasLimit;
        uint256 deployKey;


    }


    constructor () {

        if( block.chainid == SEPOLIA_CHAINID){

            ActiveNetwork = getSepoliaConfig();

        }

        else {

            ActiveNetwork = getOrCreateAnvil();
            
        }
    }


    function getSepoliaConfig() public view returns(Networkconfig memory){

        return Networkconfig({

            pricefee : 0xc934f4B8b3657D86918FD74c398E2aD9A83D78DA,
            interval : 30,
            vrfCoordinator  :0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            subId : 0,
            callbackGasLimit  : 5000,
            deployKey : vm.envUint('PRIVATE_KEY') // Sepolia Private Key  

        });

    }


    function getOrCreateAnvil() public  returns(Networkconfig memory) {

        if ( ActiveNetwork.vrfCoordinator != address(0)){

            return ActiveNetwork;

        }

        vm.startBroadcast();

        VRFCoordinatorV2Mock vrf = new VRFCoordinatorV2Mock(BASE_FEE,GAS_PRICE_LINK);
        MockV3Aggregator price = new MockV3Aggregator(DECIMAL , INITAIL_ANWSER);

        vm.stopBroadcast();

         return Networkconfig({

            pricefee : address(price),
            interval : 30,
            vrfCoordinator  : address(vrf),
            subId : 0,
            callbackGasLimit  : 5e7,
            deployKey : DEFAULT_ANVIL_PRIVATE_KEY
            
        });

    }
}
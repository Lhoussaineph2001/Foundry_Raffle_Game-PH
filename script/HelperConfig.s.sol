// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import { Script } from 'forge-std/Script.sol';
import { VRFCoordinatorV2Mock } from '../test/Mocks/VRFCoordinatorV2Mock.sol';
import { MockV3Aggregator } from '../test/Mocks/MockV3Aggregator.sol';
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {


    uint256 private constant SEPOLIA_CHAINID = 11155111 ;
    uint96 private constant BASE_FEE = 0.25 ether;
    uint96 private constant GAS_PRICE_LINK = 1e9;
    uint8 private constant ID = 3 ;
    uint8 private constant DECIMAL = 8;
    int256 private constant INITAIL_ANWSER = 2000;

    Networkconfig public ActiveNetwork;


    struct Networkconfig {

        
        address pricefee;
        bytes32 gasLane ;
        uint256  interval;
        address vrfCoordinator;
        uint64 subId;
        uint32 callbackGasLimit;
        address link ;
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
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            interval : 30,
            vrfCoordinator  :0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            subId : 0,
            callbackGasLimit  : 5000,
            link : 0x779877A7B0D9E8603169DdbD7836e478b4624789,
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
        LinkToken link = new LinkToken();
        
        vm.stopBroadcast();

         return Networkconfig({

            pricefee : address(price),
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, // doesn't really matter
            interval : 30,
            vrfCoordinator  : address(vrf),
            subId : 0,
            callbackGasLimit  : 5e7,
            link : address(link),
            deployKey : vm.envUint('DEFAULT_ANVIL_KEY')
            
        });

    }
}
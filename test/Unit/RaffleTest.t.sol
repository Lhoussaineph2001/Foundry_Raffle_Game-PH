// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Test , console} from 'forge-std/src/Test.sol';
import { Vm } from 'forge-std/src/Vm.sol';
import { VRFCoordinatorV2Mock } from '../Mocks/VRFCoordinatorV2Mock.sol';
import { RaffleGame } from '../../src/Raffle_Game.sol';
import { DeployRaffle } from '../../script/Deploy_Raffle.s.sol';
import { HelperConfig  }  from '../../script/HelperConfig.s.sol';

contract RaffleTest is Test {

    RaffleGame  raffle;

    address public immutable  USER = makeAddr("Lhoussaine Ph");
    uint256 public constant  BALANCE_USER = 10 ether;


    event AddressPlayer(address indexed player);
    event ReceiveWinner(address indexed winner);
    event RequestID(uint256 indexed requestid);

        address private pricefee;
        uint256 private interval;
        uint256 private deployKey;
        address private vrfCoordinator;
        uint64 private subId;
        uint32 private callbackGasLimit;

        HelperConfig heleprconfig;

        

    function setUp() public {

        DeployRaffle deployer = new DeployRaffle();

        (raffle,heleprconfig) = deployer.run();

        (
        
         pricefee,
         interval,
         vrfCoordinator,
         subId,
         callbackGasLimit,
         deployKey
        
        ) = heleprconfig.ActiveNetwork();

        vm.deal(USER, BALANCE_USER);
    }

    ////////////////
    // Modifier  //
    //////////////

       modifier UpkeepIsTure() {

        vm.prank(USER);
        raffle.addPlayer{ value : 1 ether}();
        vm.warp(block.timestamp +  interval - 1);
        vm.roll(block.number + 1);

        _;

    }

    ////////////////////////
    // Initailization ////
    ////////////////////

    function testInitializationRaffleState() public view {

        assert(raffle.getRaffleState() == RaffleGame.RaffleState.OPEN);

    }

    ////////////////////
    // NotEnoughPrice //
    ////////////////////

    function testNotEnoughETH() public {

        vm.prank(USER);
        vm.expectRevert(RaffleGame.Raffle__NotEnoughPrice.selector);
        raffle.addPlayer();
    }

    

     ////////////////////////////////
     // Error : RaffleStateNotOPEN //
     ///////////////////////////////

      function testCheckUpReturnFalseIfNotOPEN() public UpkeepIsTure{

        raffle.performUpkeep("");
        vm.prank(USER);
        vm.expectRevert(RaffleGame.Raffle__RaffleStateNotOPEN.selector);
        raffle.addPlayer{ value : 1 ether}();

      }  

     

    /////////////////////
    //    Events    ////
    ////////////////////

     /////////////
     // Player //
     ///////////

    function testEventsPlayer() public {

        vm.prank(USER);
        vm.expectEmit(true,false,false,false , address(raffle));
        emit  AddressPlayer(USER);
        raffle.addPlayer{ value : 1 ether}();

    }

     ////////////////
     // RequestID //
     //////////////

    function testEventsRequestID() public UpkeepIsTure{

        vm.expectEmit(true,false,false,false,address(raffle));
        emit RequestID(1);
        raffle.performUpkeep("");

    }

     /////////////
     // Winner //
     ///////////

    function testEventsWinner() public UpkeepIsTure{

        vm.recordLogs();

        raffle.performUpkeep("");

        Vm.Log[] memory players = vm.getRecordedLogs();

        bytes32 requestid = players[1].topics[1];
        vm.expectEmit(true,false,false,false,address(raffle));
        emit ReceiveWinner(USER);
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(uint256(requestid), address(raffle));
        
    }

    /////////////////
    // addPlayer ///
    ///////////////

    function testaddPLayer() public {

        vm.prank(USER);
        raffle.addPlayer{ value : BALANCE_USER}();

        assert(raffle.getPlayer(0) == USER);

    }

    /////////////////////
    // checkUpkeep /////
    //////////////////

    function testcheckUpkeep()public UpkeepIsTure{

         (bool upkeep, ) = raffle.checkUpkeep("");

        assert(upkeep == true);

    }

    //////////////////////
    // performUpkeep ////
    ////////////////////

    function testperformUpkeepRevertifUpkeepFalse() public {

        vm.prank(USER);
        raffle.addPlayer{ value : BALANCE_USER}();
        vm.roll(block.number + 1);
        vm.warp(block.timestamp +  interval + 1); // lasttimpstamp > interval 

         vm.expectRevert(abi.encodeWithSelector(
            
                    RaffleGame.Raffle__UpkeepSetFalse.selector,
                    address(raffle).balance,
                    raffle.getPlayers(),
                    raffle.getRaffleState() 
                    ));

         raffle.performUpkeep("");

    }

    function testperformUpkeepRevertifUpkeeptrue() public UpkeepIsTure{

        raffle.performUpkeep("");

        assert( raffle.getRaffleState() == RaffleGame.RaffleState.CACULATING);


    }


    /////////////////////////
    // fulfillRandomWords //
    ///////////////////////

    function testfulfillRandomWordsNonexisterequest() public {

        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(0, address(raffle));


    }

    function testfulfillRandomWords()public UpkeepIsTure{

        for (uint160 i = 1 ; i < 6 ; i++){

            hoax(address(i) , BALANCE_USER);

            raffle.addPlayer{ value : 1 ether }();

        }

        uint256 prize = 6 ether;

        vm.recordLogs();

        raffle.performUpkeep("");

        Vm.Log[] memory players = vm.getRecordedLogs();

        bytes32 requestid = players[1].topics[1];

        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(uint256(requestid), address(raffle));
        
        uint256 ReceiveWinnerBalance = raffle.getRecentWinner().balance;

        assert( ReceiveWinnerBalance ==   prize + BALANCE_USER - 1 ether);
        
    }

 

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/** 

 * @title A simple Raffle Game Contract
 * @author Lhoussaine Ait Aissa
 * @notice This contract is for creating a simple raffle game !
 * @dev Implement Chainlink VRFv2
 * @dev Implements price feeds as our library

**/


import  { VRFCoordinatorV2Interface } from '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
import  { VRFConsumerBaseV2 } from '@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol';
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { ETH_USD } from './ETH_USD.sol';


contract RaffleGame is VRFConsumerBaseV2 {

    using ETH_USD for uint256;


      //////////////////
     // Errors       //
    //////////////////

    error Raffle__NotEnoughPrice();
    error Raffle__RaffleStateNotOPEN();
    error Raffle__UpkeepSetFalse(uint256,uint256,RaffleState);
    error Raffle__FailTransaction();

    //////////////////////////////
    // Type Declarations       //
    ////////////////////////////

    enum RaffleState{

        OPEN,        // 0
        CACULATING   // 1

    }

    ////////////////////////////
    // State Variables       //
    //////////////////////////

    VRFCoordinatorV2Interface private  s_vrfCoordinator;
    AggregatorV3Interface     private  s_pricefee;

    address payable [] private s_palayers;
    address payable private    s_recentWinner;
    RaffleState private        s_RaffleState;

    uint256 private   s_lasttimestamp;
    uint256 private    s_requestId;
    uint64 private immutable  i_subscriptionid;
    uint32 private immutable  i_callbackGasLimit;
    uint256 private immutable  i_interval;
    uint256 private immutable  i_deploykey;


    uint16 private constant REQUESTCONFIRMATION = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private constant PRICE = 5 ; // USD


      //////////////////
     // Events       //
    //////////////////

    event AddressPlayer(address indexed player);
    event ReceiveWinner(address indexed winner);
    event RequestID(uint256 indexed requestid);



    constructor (

        address pricefee,
        uint256  interval,
        address vrfCoordinator,
        uint64 subId,
        uint32 callbackGasLimit,
        uint256 deployKey
     
    ) VRFConsumerBaseV2(vrfCoordinator) {

        i_interval       = interval;
        s_pricefee  =   AggregatorV3Interface(pricefee);
        s_vrfCoordinator  =  VRFCoordinatorV2Interface(vrfCoordinator);
        i_subscriptionid  = subId;
        i_callbackGasLimit  =  callbackGasLimit;
        s_lasttimestamp = block.timestamp;
        s_RaffleState = RaffleState.OPEN;
        i_deploykey = deployKey;
        
    }



    function addPlayer() public payable {

        if (msg.value.getConverter(s_pricefee) < PRICE) {

            revert Raffle__NotEnoughPrice();

        }

        if ( s_RaffleState != RaffleState.OPEN){

            revert Raffle__RaffleStateNotOPEN();

        }

        s_palayers.push(payable(msg.sender));

        emit AddressPlayer(msg.sender);


    }

/**

* @dev This is the function that the Chainlink Automation nodes 
* call to see if it's  to perform an upkeep.
*  The following should be true for this to return true :
*  1. The time interval has passed between raffle runs 
*  2. The Raffle is in the open state 
*  3. The contract ETH (aka , players)
*  4. (Implicit) the subscription is funded with Link (Link faucet in Chainlink) 
* @return upkeepNeeded

*/

    
    function checkUpkeep(
             bytes memory /** check Data  */
             ) public view returns( bool upkeepNeeded , bytes memory perforData ){

                bool timestamp = (block.timestamp - s_lasttimestamp) <= i_interval;
                bool rafflestate = s_RaffleState == RaffleState.OPEN;
                bool players = s_palayers.length > 0 ;
                bool balance  = address(this).balance > 0 ;

                upkeepNeeded = (timestamp && rafflestate && players && balance);

                return (upkeepNeeded , "");

             }

    function performUpkeep( 
        bytes calldata  /** performData  */
        ) external  {

            (bool upkeepNeeded, ) = checkUpkeep("");

            if (! upkeepNeeded){

                revert Raffle__UpkeepSetFalse(
                    address(this).balance,
                    s_palayers.length,
                    s_RaffleState
                );
            }

            else {


                s_RaffleState = RaffleState.CACULATING;



              s_requestId = s_vrfCoordinator.requestRandomWords(

                i_subscriptionid,
                REQUESTCONFIRMATION,
                i_callbackGasLimit,
                NUM_WORDS

             );

             emit RequestID(s_requestId);


            }


        }
    
    function fulfillRandomWords( 
             uint256 /** requestId */,
             uint256 [] memory randomWords
             ) internal override {

                uint256 index = randomWords[0] % s_palayers.length;
               
                address payable winner = s_palayers[index];

                s_recentWinner = winner;

                s_RaffleState = RaffleState.OPEN;

                s_palayers = new address payable[](0);

                s_lasttimestamp = block.timestamp;


                (bool success , ) = winner.call{ value : address(this).balance}("");

                if ( ! success){

                    revert Raffle__FailTransaction();
                }

                emit ReceiveWinner(winner);
             }


    //////////////////////////////
    // Getters Functions       //
    ////////////////////////////

    
    function getRaffleState() external view returns(RaffleState){

        return s_RaffleState;
    }

    function getPlayer(uint256 id) external view returns(address){

        return s_palayers[id];
    }

    function getPlayers() external view returns(uint256) {

        return s_palayers.length;
    }
   

    function getRecentWinner() external view returns(address) {

        return s_recentWinner;
    }

    
}
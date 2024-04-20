// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/////////////
///Imports///
/////////////
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

////////////
///Errors///
////////////

///////////////////////////
///Interfaces, Libraries///
///////////////////////////
import {BlackHoleLib} from "./utils/BlackHoleLib.sol";

contract BlackHole is Ownable, VRFConsumerBaseV2{
    ///////////////////////
    ///Type declarations///
    ///////////////////////

    ///////////////
    ///Variables///
    ///////////////
    uint256 private constant ONE = 1;

    /////////////////////////
    ///CHAINLINK VARIABLES///
    /////////////////////////
    VRFCoordinatorV2Interface private immutable COORDINATOR;
    LinkTokenInterface private immutable i_linkToken;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    mapping(uint256 requestId => BlackHoleLib.RequestStatus) private s_requests;

    ////////////
    ///Events///
    ////////////

    ///////////////
    ///Modifiers///
    ///////////////

    ///////////////
    ///Functions///
    ///////////////

    /////////////////
    ///constructor///
    /////////////////
    constructor(address _vrfCoordinator,
                bytes32 _keyHash,
                uint64 _subscriptionId,
                uint32 _callbackGasLimit,
                address _linkToken,
                address _owner
                )VRFConsumerBaseV2(_vrfCoordinator) Ownable(_owner){
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        i_keyHash = _keyHash;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimit = _callbackGasLimit;
        i_linkToken = LinkTokenInterface(_linkToken);
    }

    ///////////////////////
    ///receive function ///
    ///fallback function///
    ///////////////////////

    //////////////
    ///external///
    //////////////
        /*
        * @notice Chainlink VRF. Função responsável por chamar o vrfCoordinator
        * @notice vrfCoordinator vai retornar o número sorteado diretamente para a função fulfillRandomWords
        * @param _titleId ID do Consórcio que está sendo sorteado.
    */
    function requestRandomWords() external onlyOwner returns(uint256 requestId) {

        //External call !!! [Interaction with Chainlink VRF]
        requestId = COORDINATOR.requestRandomWords(i_keyHash, i_subscriptionId, REQUEST_CONFIRMATIONS, i_callbackGasLimit, NUM_WORDS);

        //Effetcs
        s_requests[requestId] = BlackHoleLib.RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            randomValue: 0
        });

        return requestId;
    }
    ////////////
    ///public///
    ////////////

    //////////////
    ///internal///
    //////////////
    /*
        * @notice Função Chainlink VRF chamada diretamente pelo vrfCoordinator
        * @param _requestId número da requisição feita
        * @param _randomWords o número aleatório gerado
        * @dev em condições normais essa função não pode reverter.
        * @dev é preciso considerar mover as funções VRF para um novo contrato e torná-lo ajustável
        * @dev considerando que o vrfCoordinator pode ser atualizado e esse parar de funcionar.
    */
    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        //Checks
        if(msg.sender != address(COORDINATOR)){
            revert BlackHoleLib.BlackHole_RequestNotFoundOrNotFulfilled(_requestId);
        }

        //Effects
        BlackHoleLib.RequestStatus storage request = s_requests[_requestId];

        request.fulfilled = true;
        request.randomWords = _randomWords ;
        request.randomValue = (request.randomWords[0] % 10) + ONE; //@AJUSTE. 10 foi aleatório

        emit BlackHoleLib.BlackHole_RequestFulfilled(_requestId, _randomWords, request.randomValue);
    }

    /////////////
    ///private///
    /////////////

    /////////////////
    ///view & pure///
    /////////////////
}

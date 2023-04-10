//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Vipsland is ERC1155Supply, Ownable, PaymentSplitter, ReentrancyGuard {
    using SafeMath for uint;
    using Counters for Counters.Counter;

    //main nft start
    string public name = "VIPSLAND GENESIS";
    string public symbol = "VPSL";

    function concatenate(string memory a, uint b) public pure returns (string memory) {
        return string(abi.encodePacked(a, ",", Strings.toString(b)));
    }

    //MerkleProof
    function setMerkleRoot(bytes32 merkleroot, uint8 stage) public onlyOwner {
        if (stage == 2) {
            rootint = merkleroot;
        }
        if (stage == 1) {
            rootair = merkleroot;
        }
    }

    modifier isValidMerkleProof(bytes32[] calldata _proof, uint8 stage) {
        require(MerkleProof.verify(_proof, stage ==  1 ? rootair : rootint, keccak256(abi.encodePacked(msg.sender))) == true, "e24");
        _;
    }

    //reveal start
    string internal notRevealedUri;
    string internal revealedUri;
    bool public revealed = false;
    mapping(uint => string) private _uris;

    function toggleReveal() public onlyOwner {
        revealed = !revealed;
    }

    function uri(uint) public view override returns (string memory) {
        if (revealed == false) {
            return notRevealedUri;
        }
        return (string(abi.encodePacked(revealedUri, "{id}", ".json")));
    }

    //reveal end
    //main nft end

    //MP
    uint public constant PRTID = 20000;
    uint public qntmintmpfornormaluser = 0;
    uint public qntmintmpforinternalteam = 0;
    uint public qntmintmpforairdrop = 0;
    uint public constant MAX_SUPPLY_MP = 20000;
    uint8 public constant NUM_TOTAL_FOR_MP = 100;
    uint8 public xrand = 18;
    Counters.Counter public _counter_for_generatelucky_mp;
    Counters.Counter public _counter_for_generatelucky_mp_internalteam;
    Counters.Counter public _counter_for_generatelucky_mp_airdrop;
    uint64 public numIssuedForMP = 4;
    uint[] private intArr;

    //NONMP
    mapping(uint => address) public prtPerAddress;
    mapping(address => uint8) public userNONMPs; //each address can get 100/17=~6

    function getAddrFromNONMPID(uint _winnerTokenNONMPID) internal view returns (address) {
        if (exists(_winnerTokenNONMPID) && balanceOf(prtPerAddress[_winnerTokenNONMPID], _winnerTokenNONMPID) > 0) {
            return prtPerAddress[_winnerTokenNONMPID];
        }

        return address(0);
    }

    // limit normal user
    uint8 public constant MAX_PRT_AMOUNT_PER_ACC = 100;
    uint8 public constant MAX_PRT_AMOUNT_PER_ACC_PER_TRANSACTION = 35;

    // limits airdrop
    uint8 public constant MAX_PRT_AMOUNT_PER_ACC_AIRDROP = 3;
    uint8 public constant MAX_PRT_AMOUNT_PER_ACC_PER_TRANSACTION_AIRDROP = 3;

    // limits internal
    uint8 public MAX_PRT_AMOUNT_PER_ACC_INTERNAL = 25;
    uint8 public MAX_PRT_AMOUNT_PER_ACC_PER_TRANSACTION_INTERNAL = 25;

    function set_MAX_PRT_AMOUNT_PER_ACC_AND_TRANSACTION_INTERNAL(uint8 amount, uint8 amount_per_transaction) public onlyOwner {
        require(amount_per_transaction <= amount, "e23");
        MAX_PRT_AMOUNT_PER_ACC_INTERNAL = amount;
        MAX_PRT_AMOUNT_PER_ACC_PER_TRANSACTION_INTERNAL = amount_per_transaction;
    }

    //NONMP NORMAL 20001-160000
    uint public PRICE_PRT = 0.123 ether;

    function setPRICE_PRT(uint price) public onlyOwner {
        PRICE_PRT = price;
    }

    uint public constant MAX_SUPPLY_FOR_PRT_TOKEN = 140000;
    uint public qntmintnonmpfornormaluser = 0;
    uint public constant EACH_RAND_SLOT_NUM_TOTAL_FOR_PRT = 10000;
    uint public numIssuedForNormalUser = 0;
    uint public constant STARTINGIDFORPRT = 20001;
    uint[] private intArrPRT;

    //NONMP INTERNAL TEAM - 160001-180000
    uint public PRICE_PRT_INTERNALTEAM = 0 ether;

    function setPRICE_PRT_INTERNALTEAM(uint price) public onlyOwner {
        PRICE_PRT_INTERNALTEAM = price;
    }

    uint public constant MAX_SUPPLY_FOR_INTERNALTEAM_TOKEN = 20000;
    uint public qntmintnonmpforinternalteam = 0;
    uint public constant EACH_RAND_SLOT_NUM_TOTAL_FOR_INTERNALTEAM = 1000;
    uint public numIssuedForInternalTeamIDs = 0;
    uint public constant STARTINGIDFORINTERNALTEAM = 160001;
    uint[] private intArrPRTInternalTeam;

    //NONMP AIRDROP8888 - 180001-188888
    uint public PRICE_PRT_AIRDROP = 0 ether;

    function setPRICE_PRT_AIRDROP(uint price) public onlyOwner {
        PRICE_PRT_AIRDROP = price;
    }

    uint public constant MAX_SUPPLY_FOR_AIRDROP_TOKEN = 8888;
    uint public qntmintnonmpforairdrop = 0;
    uint public constant EACH_RAND_SLOT_NUM_TOTAL_FOR_AIRDROP = 1111;
    uint public numIssuedForAIRDROP = 0;
    uint public constant STARTINGIDFORAIRDROP = 180001;
    uint[] public intArrPRTAIRDROP;

    //toggle start
    uint8 public presalePRT = 0;
    bool public mintMPIsOpen = false;
    bool public mintInternalTeamMPIsOpen = false;
    bool public mintAirdropMPIsOpen = false;


    //sendMP start, mint MP start
    function random(uint number) internal view returns (uint8) {
        return uint8(uint(blockhash(block.number - 1)) % number);
    }

    function getNextMPID() internal returns (uint) {
        require(numIssuedForMP < MAX_SUPPLY_MP, "e8");

        uint8 randval = random(intArr.length); //0 - 199
        uint8 iCheck = 0;

        while (iCheck < uint8(intArr.length)) {
            //below line is perfect if intArr[randval] == 100
            if (intArr[randval] == (MAX_SUPPLY_MP / intArr.length)) {
                //if randval == 199
                if (randval == (intArr.length - 1)) {
                    randval = 0;
                } else {
                    randval++;
                }
            } else {
                break;
            }
            iCheck++;
        }
        /** end chk and reassign IDs */
        uint256 mpid;

        //intArr[randval] cannot be more than 100
        if (intArr[randval] < NUM_TOTAL_FOR_MP / 2) {
            mpid = ((intArr[randval] + 1) * 2) + (uint(randval) * NUM_TOTAL_FOR_MP); //100
        } else {
            if (randval == 0 && intArr[randval] == NUM_TOTAL_FOR_MP / 2) {
                intArr[randval] = intArr[randval] + 2;
            }
            mpid = (intArr[randval] - NUM_TOTAL_FOR_MP / 2) * 2 + 1 + (uint(randval) * NUM_TOTAL_FOR_MP); //100
        }

        intArr[randval] += 1;
        numIssuedForMP++;
        return mpid;
    }


    //WOOHOO! Randomizing 140,000 NFTs on smart contract! 
    //Will work for 1 billion NFTs too... maybe?
    function getNextNONMPID(
        uint8 qnt,
        uint initialNum,
        uint numIssued,
        uint max_supply_token,
        uint each_rand_slot_num_total,
        uint[] memory intArray
    ) internal view returns (uint, uint8, uint, uint8) {
        require(numIssued < max_supply_token, "e20");

        uint8 randval = random(max_supply_token / each_rand_slot_num_total); //0 to 15
        uint8 iCheck = 0;
        //uint8 randvalChk = randval;

        while (iCheck != (max_supply_token / each_rand_slot_num_total)) {
            if (intArray[randval] == each_rand_slot_num_total) {
                if (randval == ((max_supply_token / each_rand_slot_num_total) - 1)) {
                    randval = 0;
                } else {
                    randval++;
                }
            } else {
                break;
            }
            iCheck++;
        }

        uint mpid = (intArray[randval]) + (uint(randval) * each_rand_slot_num_total);

        if (intArray[randval] + qnt > each_rand_slot_num_total) {
            qnt = uint8(each_rand_slot_num_total - intArray[randval]);
        }

        numIssued = uint(qnt + numIssued);
        return (uint(mpid + initialNum), qnt, numIssued, randval);
    }

    //NONMP mint end


    function setPreSalePRT(uint8 num) public onlyOwner onlyAllowedNum(num) {
        presalePRT = num;
    }

    function toggleMintMPIsOpen() public onlyOwner {
        mintMPIsOpen = !mintMPIsOpen; //only owner can toggle presale
    }

    function toggleMintInternalTeamMPIsOpen() public onlyOwner {
        mintInternalTeamMPIsOpen = !mintInternalTeamMPIsOpen; //only owner can toggle presale
    }

    function toggleMintAirdropMPIsOpen() public onlyOwner {
        mintAirdropMPIsOpen = !mintAirdropMPIsOpen; //only owner can toggle presale
    }

    //toggle end

    // events start
    event DistributePRTs(address indexed acc, uint minted_amount, uint last_minted_NONMPID);
    event WinnersMP(address indexed acc, uint winnerTokenPRTID);
    event SelectedNONMPIDTokens(uint _winnerTokenNONMPID, uint max_nonmpid_minus_xrand);
    event MPAllDone(bool sendMPAllDone);
    event RemainMessageNeeds(address indexed acc, uint256 qnt);

    // events end

    //MerkleProof
    bytes32 public rootair;
    bytes32 public rootint;

    constructor(
        address[] memory _team,
        uint[] memory _teamShares,
        string memory _notRevealedUri,
        string memory _revealedUri,
        bytes32 merklerootair,
        bytes32 merklerootint
    )
        ERC1155(_notRevealedUri)
        PaymentSplitter(_team, _teamShares) // Split the payment based on the teamshares percentages
        ReentrancyGuard() //A modifier that can prevent reentrancy during certain functions
    {
        //MerkleProof
        rootair = merklerootair;
        rootint = merklerootint;

        //metadata
        notRevealedUri = _notRevealedUri;
        revealedUri = _revealedUri;

        //for mp
        intArr = new uint[](MAX_SUPPLY_MP / NUM_TOTAL_FOR_MP);
        intArr[0] = 2;

        //for normal user
        intArrPRT = new uint[](MAX_SUPPLY_FOR_PRT_TOKEN / EACH_RAND_SLOT_NUM_TOTAL_FOR_PRT);

        //for internal team
        intArrPRTInternalTeam = new uint[](MAX_SUPPLY_FOR_INTERNALTEAM_TOKEN / EACH_RAND_SLOT_NUM_TOTAL_FOR_INTERNALTEAM);

        //for airdrop
        intArrPRTAIRDROP = new uint[](MAX_SUPPLY_FOR_AIRDROP_TOKEN / EACH_RAND_SLOT_NUM_TOTAL_FOR_AIRDROP);
    }

    //modifier start
    modifier onlyAccounts() {
        require(msg.sender == tx.origin, "e3");
        _;
    }

    modifier onlyForCaller(address _account) {
        require(msg.sender == _account, "e4");
        _;
    }

    modifier onlyAllowedNum(uint num) {
        require(num >= 0 && num <= 7, "e22");
        _;
    }

    modifier mintMPIsOpenModifier() {
        require(mintMPIsOpen, "e5");
        _;
    }

    modifier mintAirdropMPIsOpenModifier() {
        require(mintAirdropMPIsOpen, "e6");
        _;
    }

    modifier mintInternalTeamMPIsOpenModifier() {
        require(mintInternalTeamMPIsOpen, "e7");
        _;
    }


    //Guaranteed headache if you try to decode our spaghetti
    function moreOrLessFunc(uint _lastWinnerTokenIDNormalUserDiff) internal view returns (uint8, uint24) {
        if (_lastWinnerTokenIDNormalUserDiff >= uint24(140000 + PRTID + 1 + xrand)) {
            return (1, uint24(_lastWinnerTokenIDNormalUserDiff) - uint24(140000 + PRTID + 1 + xrand));
        }
        return (0, uint24(140000 + PRTID + 1 + xrand) - uint24(_lastWinnerTokenIDNormalUserDiff));
    }

    function checkTheWinner(uint24 _winnerTokenNONMPID, uint max_nonmpid, uint8 _xrand, uint qntminting) internal returns (uint) {
        emit SelectedNONMPIDTokens(_winnerTokenNONMPID, (max_nonmpid - _xrand));

        address winneraddr = getAddrFromNONMPID(_winnerTokenNONMPID);

        if (winneraddr != address(0)) {
            //Lucky bum function.
            uint tokenID = getNextMPID();
            _mint(msg.sender, tokenID, 1, ""); //minted one MP
            safeTransferFrom(msg.sender, winneraddr, tokenID, 1, "");
            qntminting += 1;
            emit WinnersMP(winneraddr, tokenID);
        }

        return (qntminting);
    }

    uint private idx = 0;
    uint private idxInternalTeam = 0;
    uint private idxAirdrop = 0;
    //sendMPLastID up to 10000, and stop executing sendMP()
    //uint public sendMPLastID = 0;

    //once sendMPAllDoneForNormalUsers is true only can you call sendMPInternalTeamOrAirdrop()
    bool public sendMPAllDoneForNormalUsers = false;
    bool public sendMPAllDoneForAirdrop = false;
    bool public sendMPAllDoneForInternalTeam = false;

    uint lastWinnerTokenIDNormalUserDiff = 0;
    uint lastWinnerTokenIDAirdropDiff = 0;

    uint8 moreOrLess = 0;

    //call 10 times
    function sendMPNormalUsers() public onlyAccounts onlyOwner mintMPIsOpenModifier {
        //fix
        require(sendMPAllDoneForNormalUsers == false, "e9");
        if (xrand == 18) {
            xrand = random(17);
        }
        _counter_for_generatelucky_mp.increment();
        uint counter = _counter_for_generatelucky_mp.current();
        uint24 _prevwinnerTokenNONMPID;
        for (uint i = idx; i < 1000 * counter; i++) {
            uint24 _winnerTokenNONMPID = uint24(PRTID + 1 + xrand + uint24(uint((168888 * i) / 10000))); //updated here
            uint max_nonmpid = PRTID + MAX_SUPPLY_FOR_PRT_TOKEN;
            uint24 _nextwinnerTokenNONMPID = uint24(PRTID + 1 + xrand + uint24(uint((168888 * i + 1) / 10000)));

            sendMPAllDoneForNormalUsers = (_nextwinnerTokenNONMPID > max_nonmpid) || (_winnerTokenNONMPID > max_nonmpid);
            emit MPAllDone(sendMPAllDoneForNormalUsers);

            if (sendMPAllDoneForNormalUsers) {
                lastWinnerTokenIDNormalUserDiff = uint(_nextwinnerTokenNONMPID);

                uint24 lastDiff = 0;
                (moreOrLess, lastDiff) = moreOrLessFunc(lastWinnerTokenIDNormalUserDiff);
                if (moreOrLess == 1) {
                    lastWinnerTokenIDAirdropDiff = uint(140000 + lastDiff + PRTID + 1 + xrand + uint24(uint((168888 * 1000 * 19) + 1) / 10000));
                } else {
                    lastWinnerTokenIDAirdropDiff = uint(140000 - lastDiff + PRTID + 1 + xrand + uint24(uint((168888 * 1000 * 19) + 1) / 10000));
                }

                break;
            }

            qntmintmpfornormaluser = checkTheWinner(_winnerTokenNONMPID, max_nonmpid, xrand, qntmintmpfornormaluser);

            emit MPAllDone(sendMPAllDoneForNormalUsers);
            _prevwinnerTokenNONMPID = _winnerTokenNONMPID;
        }

        //update idx
        idx = 1000 * counter;
    }

    function sendMPInternalTeam() public onlyAccounts onlyOwner mintInternalTeamMPIsOpenModifier {
        require(sendMPAllDoneForNormalUsers == true, "e10");
        require(sendMPAllDoneForInternalTeam == false, "e11");

        _counter_for_generatelucky_mp_internalteam.increment();
        uint counter = _counter_for_generatelucky_mp_internalteam.current();

        uint24 lastDiff = 0;
        (moreOrLess, lastDiff) = moreOrLessFunc(lastWinnerTokenIDNormalUserDiff);

        for (uint i = idxInternalTeam; i < 1000 * counter; i++) {
            uint24 _winnerTokenNONMPID = 0;
            uint24 _nextwinnerTokenNONMPID = 0;
            if (moreOrLess == 1) {
                _winnerTokenNONMPID = uint24(140000 + lastDiff + PRTID + 1 + xrand + uint24(uint((168888 * i) / 10000))); //updated
                _nextwinnerTokenNONMPID = uint24(140000 + lastDiff + PRTID + 1 + xrand + uint24(uint((168888 * i + 1) / 10000)));
            } else {
                _winnerTokenNONMPID = uint24(140000 - lastDiff + PRTID + 1 + xrand + uint24(uint((168888 * i) / 10000))); //updated
                _nextwinnerTokenNONMPID = uint24(140000 - lastDiff + PRTID + 1 + xrand + uint24(uint((168888 * i + 1) / 10000)));
            }

            uint max_nonmpid = PRTID + MAX_SUPPLY_FOR_PRT_TOKEN + MAX_SUPPLY_FOR_INTERNALTEAM_TOKEN;
            sendMPAllDoneForInternalTeam = (_nextwinnerTokenNONMPID > max_nonmpid) || (_winnerTokenNONMPID > max_nonmpid);

            emit MPAllDone(sendMPAllDoneForInternalTeam);

            if (sendMPAllDoneForInternalTeam) {
                break;
            }

            qntmintmpforinternalteam = checkTheWinner(_winnerTokenNONMPID, max_nonmpid, xrand, qntmintmpforinternalteam);

            emit MPAllDone(sendMPAllDoneForInternalTeam);
        }

        idxInternalTeam = 1000 * counter;
    }

    function sendMPAirdrop() public onlyAccounts onlyOwner mintAirdropMPIsOpenModifier {
        require(sendMPAllDoneForNormalUsers == true, "e12");
        require(sendMPAllDoneForAirdrop == false, "e13");

        _counter_for_generatelucky_mp_airdrop.increment();
        uint counter = _counter_for_generatelucky_mp_airdrop.current();

        uint24 lastDiff = 0;
        (moreOrLess, lastDiff) = moreOrLessFunc(lastWinnerTokenIDNormalUserDiff);

        for (uint i = idxAirdrop; i < 1000 * counter; i++) {
            uint24 _nextwinnerTokenNONMPID = 0;
            uint24 _winnerTokenNONMPID = 0;
            if (moreOrLess == 1) {
                _winnerTokenNONMPID = uint24(160000 + lastDiff + PRTID + 1 + xrand + uint24(uint((168888 * i) / 10000))); //updated here
                _nextwinnerTokenNONMPID = uint24(160000 + lastDiff + PRTID + 1 + xrand + uint24(uint((168888 * i + 1) / 10000)));
            } else {
                _winnerTokenNONMPID = uint24(160000 - lastDiff + PRTID + 1 + xrand + uint24(uint((168888 * i) / 10000))); //updated here
                _nextwinnerTokenNONMPID = uint24(160000 - lastDiff + PRTID + 1 + xrand + uint24(uint((168888 * i + 1) / 10000)));
            }
            uint max_nonmpid = PRTID + MAX_SUPPLY_FOR_PRT_TOKEN + MAX_SUPPLY_FOR_INTERNALTEAM_TOKEN + MAX_SUPPLY_FOR_AIRDROP_TOKEN;

            sendMPAllDoneForAirdrop = (_nextwinnerTokenNONMPID > max_nonmpid) || (_winnerTokenNONMPID > max_nonmpid);

            emit MPAllDone(sendMPAllDoneForAirdrop);

            if (sendMPAllDoneForAirdrop) {
                break;
            }
            qntmintmpforairdrop = checkTheWinner(_winnerTokenNONMPID, max_nonmpid, xrand, qntmintmpforairdrop);

            emit MPAllDone(sendMPAllDoneForAirdrop);
        }

        idxAirdrop = 1000 * counter;
    }

    //sendMP end

    modifier presalePRTisActive() {
        require(presalePRT != 0, "e14");
        _;
    }

    //Are we moon yet?
    function mintNONMPForAIRDROP(
        address account,
        uint8 _amount_wanted_able_to_get,
        bytes32[] calldata _proof
    ) external payable onlyForCaller(account) onlyAccounts presalePRTisActive nonReentrant isValidMerkleProof(_proof, 1) {
        require(_amount_wanted_able_to_get > 0, "e15");
        require(msg.sender != address(0), "e16");

        _mintNONMPForAIRDROP(_amount_wanted_able_to_get);
    }

    function _mintNONMPForAIRDROP(uint8 qnt) internal {
        bool isRemainMessageNeeds = false;

        //added:0
        require(presalePRT & 0x1 == 1, "e21");
        require(userNONMPs[msg.sender] <= MAX_PRT_AMOUNT_PER_ACC_AIRDROP, "e17");
        require(qnt <= MAX_PRT_AMOUNT_PER_ACC_PER_TRANSACTION_AIRDROP, "e18");

        //added:1
        if (userNONMPs[msg.sender] + qnt > MAX_PRT_AMOUNT_PER_ACC_AIRDROP) {
            qnt = uint8(MAX_PRT_AMOUNT_PER_ACC_AIRDROP - userNONMPs[msg.sender]);
            isRemainMessageNeeds = true;
        }

        //AIRDROP8888 - 180001-188888
        (uint initID, uint8 _qnt, uint _numIssued, uint8 _randval) = getNextNONMPID(
            qnt,
            STARTINGIDFORAIRDROP,
            numIssuedForAIRDROP,
            MAX_SUPPLY_FOR_AIRDROP_TOKEN,
            EACH_RAND_SLOT_NUM_TOTAL_FOR_AIRDROP,
            intArrPRTAIRDROP
        );
        if (_qnt != qnt) {
            isRemainMessageNeeds = true;
        }

        //added:2

        //added:3
        uint weiBalanceWallet = msg.value;
        require(weiBalanceWallet >= PRICE_PRT_AIRDROP * _qnt, "e19");

        //added:4
        //You buy, I buy.
        payable(owner()).transfer(PRICE_PRT_AIRDROP * _qnt); //Send money to owner of contract

        //added:5
        uint[] memory ids = new uint[](_qnt);
        uint[] memory amounts = new uint[](_qnt);
        for (uint i = 0; i < _qnt; i++) {
            ids[i] = uint(initID + i);
            amounts[i] = 1;
        }

        _mintBatch(msg.sender, ids, amounts, "");

        //add event
        for (uint i = 0; i < _qnt; i++) {
            prtPerAddress[uint(ids[i])] = msg.sender;
        }

        //added:6
        userNONMPs[msg.sender] = uint8(userNONMPs[msg.sender] + ids.length);

        //added:7
        //update:
        numIssuedForAIRDROP = _numIssued;
        intArrPRTAIRDROP[_randval] = intArrPRTAIRDROP[_randval] + _qnt;

        //added:8
        qntmintnonmpforairdrop += _qnt;
        if (qntmintnonmpforairdrop >= MAX_SUPPLY_FOR_AIRDROP_TOKEN) {
            mintAirdropMPIsOpen = true;
        }

        //added:9
        emit DistributePRTs(msg.sender, userNONMPs[msg.sender], ids[_qnt - 1]);
        //show message to user mint only remaining quantity
        if (isRemainMessageNeeds) {
            emit RemainMessageNeeds(msg.sender, _qnt);
        }
    }


    function mintNONMPForInternalTeam(
        address account,
        uint8 _amount_wanted_able_to_get,
        bytes32[] calldata _proof
    ) external payable onlyForCaller(account) onlyAccounts presalePRTisActive nonReentrant isValidMerkleProof(_proof, 2) {
        require(_amount_wanted_able_to_get > 0, "e15");
        require(msg.sender != address(0), "e16");

        _mintNONMPForInternalTeam(_amount_wanted_able_to_get);
    }

    function _mintNONMPForInternalTeam(uint8 qnt) internal {
        bool isRemainMessageNeeds = false;

        //added:0
        require(presalePRT & 0x2 == 2, "e21");
        require(userNONMPs[msg.sender] <= MAX_PRT_AMOUNT_PER_ACC_INTERNAL, "e17");
        require(qnt <= MAX_PRT_AMOUNT_PER_ACC_PER_TRANSACTION_INTERNAL, "e18");

        //added:1
        if (userNONMPs[msg.sender] + qnt > MAX_PRT_AMOUNT_PER_ACC_INTERNAL) {
            qnt = uint8(MAX_PRT_AMOUNT_PER_ACC_INTERNAL - userNONMPs[msg.sender]);
            isRemainMessageNeeds = true;
        }

        //INTERNAL TEAM - 160001-180000
        (uint initID, uint8 _qnt, uint _numIssued, uint8 _randval) = getNextNONMPID(
            qnt,
            STARTINGIDFORINTERNALTEAM,
            numIssuedForInternalTeamIDs,
            MAX_SUPPLY_FOR_INTERNALTEAM_TOKEN,
            EACH_RAND_SLOT_NUM_TOTAL_FOR_INTERNALTEAM,
            intArrPRTInternalTeam
        );
        if (_qnt != qnt) {
            isRemainMessageNeeds = true;
        }

        //added:2

        //added:3
        uint weiBalanceWallet = msg.value;
        require(weiBalanceWallet >= PRICE_PRT_INTERNALTEAM * _qnt, "e19");

        //added:4
        //You buy, I buy.
        payable(owner()).transfer(PRICE_PRT_INTERNALTEAM * _qnt); //Send money to owner of contract

        //added:5
        uint[] memory ids = new uint[](_qnt);
        uint[] memory amounts = new uint[](_qnt);
        for (uint i = 0; i < _qnt; i++) {
            ids[i] = initID + i;
            amounts[i] = 1;
        }

        _mintBatch(msg.sender, ids, amounts, "");

        //add event
        for (uint i = 0; i < _qnt; i++) {
            prtPerAddress[uint(ids[i])] = msg.sender;
        }

        //added:6
        userNONMPs[msg.sender] = uint8(userNONMPs[msg.sender] + ids.length);

        //added:7
        //update:
        numIssuedForInternalTeamIDs = _numIssued;
        intArrPRTInternalTeam[_randval] = intArrPRTInternalTeam[_randval] + _qnt;

        //added:8
        qntmintnonmpforinternalteam += _qnt;
        if (qntmintnonmpforinternalteam >= MAX_SUPPLY_FOR_INTERNALTEAM_TOKEN) {
            mintInternalTeamMPIsOpen = true;
        }

        //added:9
        emit DistributePRTs(msg.sender, userNONMPs[msg.sender], ids[_qnt - 1]);
        if (isRemainMessageNeeds) {
            emit RemainMessageNeeds(msg.sender, _qnt);
        }
    }


    //Our code is endorsed by witches*. 
    //Now that you read our code, 
    //witches will follow u everywhere until 
    //you get 10 people each to buy 1 NFT from us. 
    //You have been forewarned...:)
    function mintNONMPForNormalUser(address account, uint8 _amount_wanted_able_to_get) external payable onlyForCaller(account) onlyAccounts presalePRTisActive nonReentrant {
        require(_amount_wanted_able_to_get > 0, "e15");
        require(msg.sender != address(0), "e16");

        _mintNONMPForNormalUser(_amount_wanted_able_to_get);
    }


    function _mintNONMPForNormalUser(uint8 qnt) internal {
        bool isRemainMessageNeeds = false;

        //added:0
        require(presalePRT & 0x4 == 4, "e21");
        require(userNONMPs[msg.sender] <= MAX_PRT_AMOUNT_PER_ACC, "e17");
        require(qnt <= MAX_PRT_AMOUNT_PER_ACC_PER_TRANSACTION, "e18");

        //added:1
        if (userNONMPs[msg.sender] + qnt > MAX_PRT_AMOUNT_PER_ACC) {
            qnt = uint8(MAX_PRT_AMOUNT_PER_ACC - userNONMPs[msg.sender]);
            isRemainMessageNeeds = true;
        }

        //NORMAL 20001-160000
        (uint initID, uint8 _qnt, uint _numIssued, uint8 _randval) = getNextNONMPID(
            qnt,
            STARTINGIDFORPRT,
            numIssuedForNormalUser,
            MAX_SUPPLY_FOR_PRT_TOKEN,
            EACH_RAND_SLOT_NUM_TOTAL_FOR_PRT,
            intArrPRT
        );
        if (_qnt != qnt) {
            isRemainMessageNeeds = true;
        }

        //added:2
        //extra logic only for normal user
        uint _PRICE_PRT = PRICE_PRT;
        if (_qnt >= 5 && _qnt <= 10) {
            _PRICE_PRT = (PRICE_PRT * 4) / 5;
        } else if (_qnt > 10) {
            _PRICE_PRT = (PRICE_PRT * 3) / 5;
        }

        //added:3
        uint weiBalanceWallet = msg.value;
        require(weiBalanceWallet >= _PRICE_PRT * _qnt, "e19");

        //added:4
        //You buy, I buy.
        payable(owner()).transfer(_PRICE_PRT * _qnt); //Send money to owner of contract

        //added:5
        uint[] memory ids = new uint[](_qnt);
        uint[] memory amounts = new uint[](_qnt);
        for (uint i = 0; i < _qnt; i++) {
            ids[i] = initID + i;
            amounts[i] = 1;
        }
        _mintBatch(msg.sender, ids, amounts, "");

        //add event
        for (uint i = 0; i < _qnt; i++) {
            prtPerAddress[uint(ids[i])] = msg.sender;
        }

        //added:6
        userNONMPs[msg.sender] = uint8(userNONMPs[msg.sender] + ids.length);

        //added:7
        //update:
        numIssuedForNormalUser = _numIssued;
        intArrPRT[_randval] = intArrPRT[_randval] + _qnt;

        //added:8
        qntmintnonmpfornormaluser += _qnt;
        if (qntmintnonmpfornormaluser >= MAX_SUPPLY_FOR_PRT_TOKEN) {
            mintMPIsOpen = true;
        }
        //added:9
        emit DistributePRTs(msg.sender, userNONMPs[msg.sender], ids[_qnt - 1]);
        //show message to user mint only remaining quantity
        if (isRemainMessageNeeds) {
            emit RemainMessageNeeds(msg.sender, _qnt);
        }
    }

    //withdraw logic start
    function balanceOfAccount() public payable onlyOwner returns (uint) {
        return msg.value;
    }

    function contractBalance() public view onlyOwner returns (uint) {
        return address(this).balance; //This function allows the owner to withdraw from the contract
    }

    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance); //This function allows the owner to withdraw from the contract
    }
    //withdraw logic end

    //*Just kidding. Our code is actually endorsed by goddesses. 
    //Now that you read our code, to claim your blessings, 
    //buy 1 VIPSLAND NFT and get 10 others to buy an NFT from us
    //to be blessed likewise and YOU will be blessed forever! 
    //You can be an angel too! Thanks!

}
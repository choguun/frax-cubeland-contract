// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Profile} from "./Profile.sol";
import {Token} from "./Token.sol";
import {Item} from "./Item.sol";
import {Raffle} from "./Raffle.sol";
import {CraftSystem} from "./CraftSystem.sol";
import {Banking} from "./Banking.sol";
import {ERC6551Registry} from "./ERC6551Registry.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

contract World is Raffle, Banking, Ownable, ReentrancyGuard {
    // Data Structures
    enum QuestType {
        DAILY_CHECK_IN,
        PLAY_MINIGAME,
        CRAFT
    }

    enum ExchangeType {
        BUY,
        SELL
    }

    struct Player {
        uint256 tokenId;
        uint256 score;
        uint256 lastCheckIn;
        uint256 streak;
        uint256 lastRaffle;
        uint256 lastDoCraft;
        uint256 ticket;
    }
    struct Quest {
        string name;
        string description;
        uint256 reward;
        QuestType questType;
    }
    struct GameItem {
        string name;
        string description;
        uint256 price;
    }
    // Data Structures

    // External Contract
    address public profile; // Profile
    address public token; // Token
    address public item; // Item
    address public craft; // Craft System
    address public registry; // Registry
    address public account; // Token Bound Account
    // address public banking; // Banking
    uint256 public chainId;
    // External Contract

    // Game data
    mapping(address => Player) public players;
    mapping(uint256 => Quest) public quests;
    mapping(uint256 => GameItem) public gameItems;

    uint256 public questCount = 0;
    uint256 public itemCount = 0;
    uint256 public marketfees = 20; // 20%

    uint256 public constant CHECK_IN_WINDOW = 24 hours;
    uint256 public constant DENOMINATOR = 10 ** 16; // FRAX 10 ** 18 // 1 = 0.01 
    // address public constant FRAX = 0xFc00000000000000000000000000000000000001;
    // address public constant sFRAXVault = 0xBFc4D34Db83553725eC6c768da71D2D9c1456B55;
    // Game data

    // Events
    event PlayerCreated(
        uint256 tokenId,
        address owner,
        uint256 timestamp
    );
    event PlayerUpdated(
        uint256 tokenId,
        address owner,
        uint256 timestamp
    );
    event PlayerDeleted(
        uint256 tokenId,
        address owner,
        uint256 timestamp
    );
    event QuestCreated(
        uint256 questId,
        uint256 reward,
        QuestType questType,
        uint256 timestamp
    );
    event QuestUpdated(
        uint256 questId,
        uint256 reward,
        QuestType questType,
        uint256 timestamp
    );
    event GameItemCreated(
        uint256 itemId,
        uint256 price,
        uint256 timestamp
    );
     event GameItemUpdated(
        uint256 itemId,
        uint256 price,
        uint256 timestamp
    );
    event CheckedIn(address indexed user, uint256 timestamp, uint256 newStreak);
    event RaffleResulted(address indexed user, uint256 timestamp, bool result);
    event MarketFeesUpdated(
        uint256 fees,
        uint256 timestamp
    );
    // Events

    // Modifiers
    modifier onlyUser() {
        require(Profile(profile).balanceOf(_msgSender()) > 0, "Only user can call this function");
        _;
    }
    modifier onlyTokenOwner(uint256 _tokenId) {
        require(Profile(profile).ownerOf(_tokenId) == _msgSender(), "Only owner of the token can exchange item");
        _;
    }
    // Modifiers

    // constructor
    constructor(address _initialOwner) Ownable(_initialOwner) {}

    // Player functions
    // TODO: call createPlayer after register token bound account
    function createPlayer(uint256 _tokenId) external onlyUser onlyTokenOwner(_tokenId) {
        players[_msgSender()] = Player(_tokenId, 0, 0, 0, 0, 0, 0);
        emit PlayerCreated(_tokenId, _msgSender(), block.timestamp);
    }

    function getPlayer(address _player) external view returns (Player memory) {
        return players[_player];
    }
    // Player functions

    // Market functions
    function setMarketFees(uint256 fees) external onlyOwner {
        require(fees > 0 && fees <= 100, "feed require between 0 - 100");
        marketfees = fees;
        emit MarketFeesUpdated(fees, block.timestamp);
    }
    // Market functions

    // Exchange functions
    function exchangeItem(uint256 _tokenId, uint256 _itemId, ExchangeType exchangeType) external onlyUser onlyTokenOwner(_tokenId) nonReentrant {
        address tokenBoundAccount = _getTokenBoundAccount(_tokenId);
        uint256 price = _getItemPrice(_itemId);

        if(exchangeType == ExchangeType.BUY) {
            require(Token(FRAX).balanceOf(_msgSender()) >= price, "FRAX Token is not enough to buy item");
            Token(FRAX).approve(address(this), price);
            Token(FRAX).transferFrom(_msgSender(), address(this), price);
            Item(item).mint(tokenBoundAccount, _itemId, 1);
        } else {
            require(Item(item).balanceOf(tokenBoundAccount, _itemId) > 0, "Item Token is not enough to sell item");
            Item(item).burn(_msgSender(), _itemId, 1);
            Token(FRAX).transfer(_msgSender(), (price * (100 - marketfees)) / 100);
        }
        // TODO: change CUBE token to FRAX and reduce pricing
        // TODO: Normal PICKAXE = 0.01 FRAX(BUY) for sell reduce 20% from PRICE
        // TODO: no need to burn but send to world contract
        // TODO: move code to Market contract and add config sell price percentage
        // TODO: exchange between FRAX and Item, FRAX will send to World Contract when
        // TODO: player buy items for example PICKAXE = 0.01 USD(FRAX) it will mint PICKAXE to buyer
        // TODO: playser sell items for example PIXAXE = 0.008 USD(FRAX) it will burn PICKAXE and return FRAX
    }

    // 1 = 0.01 FRAX
    function _getItemPrice(uint256 _itemId) internal view returns (uint256) {
        require(gameItems[_itemId].price > 0, "Item not found");
        return  gameItems[_itemId].price * DENOMINATOR;
    }
    // Exchange functions

    // Quest functions
    function doQuest(uint256 _tokenId, uint256 _questId, uint256 _data) external onlyUser onlyTokenOwner(_tokenId) {
        if(quests[_questId].questType == QuestType.DAILY_CHECK_IN) {
            // Quest 1: Daily check-in
            _dailyCheckIn(_tokenId, quests[_questId].reward);
        } else if(quests[_questId].questType == QuestType.PLAY_MINIGAME) {
            // Quest 3: Play Mini game
            _dailyPlayMinigame(_tokenId, quests[_questId].reward, _data);
        } else if(quests[_questId].questType == QuestType.CRAFT) {
            // Quest 2: craft
            _doCraft(_tokenId, quests[_questId].reward, _data);
        }
        else {
            revert("Invalid quest id");
        }
    }

    // FRAX Integration
    function doDeposit(uint256 _tokenId, uint256 _amount) external onlyUser onlyTokenOwner(_tokenId) {
        // address tokenBoundAccount = _getTokenBoundAccount(_tokenId);
        uint256 balance = Token(FRAX).balanceOf(_msgSender());
        require(balance > 0, "FRAX Balance <= 0");
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= balance, "Amount must not be greater than balance");
        require(Token(FRAX).transferFrom(_msgSender(), address(this), _amount), "Transfer failed");
        require(Token(FRAX).approve(sFRAXVault, _amount), "Approve failed");
        (bool success, uint256 share) = _depositFraxVault(_amount, _msgSender());
        // TODO: improve sFRAX store in world contract instead and mapping player address and sFRAX amount
        
        if(share > 0) {
            players[_msgSender()].ticket += 1;
        }
    }

    function doRedeem(uint256 _tokenId, uint256 _amount) external onlyUser onlyTokenOwner(_tokenId) {
        // address tokenBoundAccount = _getTokenBoundAccount(_tokenId);
        uint256 balance = Token(sFRAX).balanceOf(_msgSender());
        require(balance > 0, "sFRAX Balance <= 0");
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= balance, "Amount must not be greater than balance");
        require(Token(sFRAX).transferFrom(_msgSender(), address(this), _amount), "Transfer failed");
        require(Token(sFRAX).approve(sFRAXVault, _amount), "Approve failed");
        (bool success, uint256 share) = _redeemFraxVault(_amount, _msgSender());
        
        if(share > 0) {
            _distributeRewardandScore(_tokenId, 20);
        }
    }

    // TODO: swap feature in game integrate with FRAX Swap router
    function doSwap(uint256 _tokenId) external onlyUser onlyTokenOwner(_tokenId) {

    }
    // FRAX Integration

    function _distributeRewardandScore(uint256 _tokenId, uint256 _reward) internal {
        // address tokenBoundAccount = _getTokenBoundAccount(_tokenId);
        Token(token).mint(_msgSender(), _reward * DENOMINATOR * 100);
    }

    function _dailyCheckIn(uint256 _tokenId, uint256 _reward) internal {
        // address tokenBoundAccount = _getTokenBoundAccount(_tokenId);
        Player storage userCheckInInfo = players[_msgSender()];
        require(block.timestamp >= userCheckInInfo.lastCheckIn + CHECK_IN_WINDOW, "Too early for next check-in");

        if (block.timestamp > userCheckInInfo.lastCheckIn + (CHECK_IN_WINDOW * 2)) {
            // Reset the streak if checking in after the 48-hour window
            userCheckInInfo.streak = 1;
        } else {
            // Increment streak if within the 24-48 hour window
            userCheckInInfo.streak++;
        }

        _distributeRewardandScore(_tokenId, _reward);

        userCheckInInfo.lastCheckIn = block.timestamp;
        emit CheckedIn(_msgSender(), block.timestamp, userCheckInInfo.streak);
    }

    function _dailyPlayMinigame(uint256 _tokenId, uint256 _reward, uint256 _guess) internal {
        require(players[_msgSender()].ticket > 0 , "No ticket is avaliabe");
        uint256 r = _enterRaffle();
        players[_msgSender()].ticket = players[_msgSender()].ticket - 1;
       // TODO: deposit in vault to raffle ticket
       // TODO: 100 $CUBE = 1 ticket
       // TODO: doeposit CUBE will be prize pool
        if(r == _guess) {
            _distributeRewardandScore(_tokenId, _reward);
            emit RaffleResulted(_msgSender(), block.timestamp, true);
        } else {
            emit RaffleResulted(_msgSender(), block.timestamp, false);
        }
    }

    function _doCraft(uint256 _tokenId, uint256 _reward, uint256 _recipeId) internal {
        address tokenBoundAccount = _getTokenBoundAccount(_tokenId);
        (bool success, ) = CraftSystem(craft).craftItem(_recipeId, tokenBoundAccount);
        if(success) {
            _distributeRewardandScore(_tokenId, _reward);
        }
    }

    function checkCurrentQuestStatus(uint256 _tokenId) public view returns (bool isCheckIn, bool isPlayMinigame, bool lastDoCraft) {
        address tokenBoundAccount = _getTokenBoundAccount(_tokenId);
        Player storage userCheckInInfo = players[_msgSender()];
        isCheckIn = false;
        isPlayMinigame = false;
        lastDoCraft = false;

        if(block.timestamp >= userCheckInInfo.lastCheckIn - CHECK_IN_WINDOW && block.timestamp < userCheckInInfo.lastCheckIn + CHECK_IN_WINDOW) {
            isCheckIn = true;
        }
        if(block.timestamp < userCheckInInfo.lastRaffle - CHECK_IN_WINDOW && block.timestamp < userCheckInInfo.lastRaffle + CHECK_IN_WINDOW) {
            isPlayMinigame = true;
        }
        if(block.timestamp < userCheckInInfo.lastDoCraft - CHECK_IN_WINDOW && block.timestamp < userCheckInInfo.lastDoCraft + CHECK_IN_WINDOW) {
            lastDoCraft = true;
        }
        
        return (isCheckIn, isPlayMinigame, lastDoCraft);
    }

    function getQuests() external view returns (Quest[] memory) {
        Quest[] memory questArray = new Quest[](questCount);
        for (uint256 i = 0; i < questCount; i++) {
            questArray[i] = quests[i];
        }
        return questArray;
    }
    // Quest functions

    // Helper functions
    function _getTokenBoundAccount(uint256 _tokenId) internal view returns (address) {
        return ERC6551Registry(registry).account(account, chainId, profile, _tokenId, 1);
    }
    // Helper functions

    // Admin functions
    // config world
    function setProfile(address _profile) public onlyOwner {
        profile = _profile;
    }

    function setToken(address _token) public onlyOwner {
        token = _token;
    }

    function setItem(address _item) public onlyOwner {
        item = _item;
    }

    function setCraft(address _craft) public onlyOwner {
        craft = _craft;
    }

    // function setBanking(address _banking) public onlyOwner {
    //     banking = _banking;
    // }

    function configTokenBound(address _registry, address _account, uint256 _chainId) public onlyOwner {
        registry = _registry;
        account = _account;
        chainId = _chainId;
    }
    // config world

    // Quest functions
    function createQuest(string memory _name, string memory _description, uint256 _reward, QuestType _questType) public onlyOwner {
        quests[questCount] = Quest(_name, _description, _reward, _questType);
        emit QuestCreated(questCount, _reward, _questType, block.timestamp);
        questCount++;
    }

    function setQuest(uint256 _questId, string memory _name, string memory _description, uint256 _reward, QuestType _questType) public onlyOwner {
        quests[_questId] = Quest(_name, _description, _reward, _questType);
        emit QuestUpdated(_questId, _reward, _questType, block.timestamp);
    }
    // Quest functions

    // Player functions
    function deletePlayer(address _player) public onlyOwner {
        uint256 _tokenId = players[_player].tokenId;
        delete players[_player];
        emit PlayerDeleted(_tokenId, _player, block.timestamp);
    }
    // Player functions

    // Exchange functions
    function createItem(uint256 _itemId, string memory _name, string memory _description, uint256 _price) public onlyOwner {
        gameItems[_itemId] = GameItem(_name, _description, _price);
        emit GameItemCreated(_itemId, _price, block.timestamp);
        itemCount++;
    }

    function setItemPrice(uint256 _itemId, string memory _name, string memory _description, uint256 _price) public onlyOwner {
        gameItems[_itemId] = GameItem(_name, _description, _price);
        emit GameItemCreated(_itemId, _price, block.timestamp);
    }
    // Exchange functions

    // Craft System functions
    function addRecipe(uint256[] memory _inputs, uint256[] memory _quantities, uint256 _result) public onlyOwner {
        CraftSystem(craft).addReccipe(_inputs, _quantities, _result);
    }

    function setRecipe(uint256 _recipeId, uint256[] memory _inputs, uint256[] memory _quantities, uint256 _result) public onlyOwner {
        CraftSystem(craft).setRecipe(_recipeId, _inputs, _quantities, _result);
    }

    function getRecipe(uint256 _recipeId) public view returns (CraftSystem.Recipes memory) {
        return CraftSystem(craft).getRecipe(_recipeId);
    }

    function getAllRecipes() public view returns (CraftSystem.Recipes[] memory) {
        return CraftSystem(craft).getAllRecipes();
    }

    function addItems(uint256 _id, CraftSystem.ItemType _itemType) public onlyOwner {
        CraftSystem(craft).addItems(_id, _itemType);
    }

    function getItem(uint256 _itemId) public view returns (CraftSystem.Items memory) {
        return CraftSystem(craft).getItem(_itemId);
    }
    // Craft System functions
    // Admin functions
}
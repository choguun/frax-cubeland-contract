# frax-cubeland-contract

### How to deploy frax-cubeland-contract

* npx hardhat run scripts/01_deploy_protocol.ts --network mainnet
* config contract address to all deploy scripts.
* npx hardhat run scripts/02_setup_world.ts --network mainnet
* npx hardhat run scripts/03_add_quest.ts --network mainnet
* npx hardhat run scripts/04_add_recipe.ts --network mainnet
* npx hardhat run scripts/05_add_gameitem.ts --network mainnet 

### Technologies Used:

1. Smart Contract \
1.1 On-chain in-game Items and Token \
1.2 World (Game Logic)
3. IPFS Storage to store game metadata
4. WebGL to render game on browser
5. Game Engine(Real-time Open World, Indexer)
6. AI-generated content & LLM

### Key Features:

1. On-chain Game Logic eg. Quest(Daily Check-in, Raffle, Mini game), Craft, Item, Token, Profile, and World.
2. Token bound account; user truly owns their asset on their Profile NFT.
3. Multiplayer
4. Supported Multi-Platform on browser

### How it works:
![How it works](/howitwork.png "How it works")

Demo:
https://www.cubesland.xyz

### Business Model
1. Sell NFT and in-game items
2. Platform fees

### Deployed Smart Contract
1.Profile - NFT Profile to identify unique user https://mainnet.opbnbscan.com/address/0xb98624b9f6e3eadcb696947138aee682ba486b8d \
2.Token - ERC20 In-game token https://mainnet.opbnbscan.com/address/0x5f0285eb417412047442075d8898f04344ca65c8 \
3.Item - ERC1155 game item https://mainnet.opbnbscan.com/address/0xd7e17a079150d9fd1d0df31c649f2e237489cec0 \
4.World - On-chain game logic https://mainnet.opbnbscan.com/address/0xd3a85ead10da64d3028a4e147256b66e449c0450 \
5.Raffle - Raffle Module for mini game https://mainnet.opbnbscan.com/address/0xd3a85ead10da64d3028a4e147256b66e449c0450 \
6.ERC6551Account - Token bound account module https://mainnet.opbnbscan.com/address/0x0e0eb0122843947526bd486370ed248f83678de6 \
7.ERC6551Registry - Token bound account module https://mainnet.opbnbscan.com/address/0x03cd67a9bcd6b1bdd26846ba0ec6f0ea41f2c47b \
8.CraftSystem - Craft system module https://mainnet.opbnbscan.com/address/0x18edb95a5696d4cc9d9ee3311797404ea02e61ee

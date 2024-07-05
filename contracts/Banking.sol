// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

contract Banking is Ownable {
    address public world;
    address public sFRAXVault = 0xBFc4D34Db83553725eC6c768da71D2D9c1456B55;

    modifier onlyWorld() {
        require(_msgSender() == world, "Only world can call this function");
        _;
    }

    constructor(address _initialOwner, address _world) Ownable(_initialOwner) {
        world = _world;
    }

    function deposit(uint256 _amount, address _reciever) public onlyWorld returns (bool, uint256) {
        IERC4626(sFRAXVault).deposit(_amount, _reciever);

        return (true, 0);
    }

    function redeem(uint256 _amount, address _reciever) public onlyWorld returns (bool, uint256) {
        IERC4626(sFRAXVault).redeem(_amount, _reciever, _reciever);

        return (true, 0);
    }
    // TODO: integrate with sFRAX Vault call deposit FRAX token to recieve sFRAX token
    // TODO: sFRAX token will store in World contract and Banking contract will mapping address and FRAX deposit amount
    // TODO: when players withdraw their deposit get will get principal back with yield after fees 10% and CUBE token bonus(+10% APY)
}
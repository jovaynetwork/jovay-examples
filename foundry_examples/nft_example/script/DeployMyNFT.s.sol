// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { MyNFT } from "../src/MyNFT.sol";

contract DeployNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MyNFT nft = new MyNFT();

        vm.stopBroadcast();
        console.log("MyNFT deployed at:", address(nft));
    }
}

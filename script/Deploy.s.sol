// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Agent.sol";
import "../src/ChatOracle.sol";

contract DeployScript is Script {
    function run() external {
        uint256 caller = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(caller);

        vm.startBroadcast(caller);

        // @dev Uncomment this line to deploy ChatOracle use foundry and anvil
        ChatOracle oracle = new ChatOracle();
        console.log("Oracle address: ", address(oracle));
        oracle.updateWhitelist(deployerAddress, true);

        // @dev Uncomment this line to use Oracle deploy by hardhat
        // ChatOracle oracle = ChatOracle(vm.envAddress("ORACLE_ADDRESS"));

        Agent agent = new Agent(address(oracle), "", "PoP", 1000 * 10 ** 18);
        console.log("Deployer address: ", deployerAddress);
        console.log("Agent address: ", address(agent));

        vm.stopBroadcast();
    }
}

source .env

forge script script/Deploy.s.sol:DeployScript --rpc-url $RPC --gas-price 1000000000 --gas-limit 8000000 --via-ir --legacy --broadcast
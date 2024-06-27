source .env
 
forge script script/ChangeOracle.s.sol:ChangeOracle --rpc-url $RPC --gas-price 1000000000 --gas-limit 1000000 --via-ir --legacy --private-key $PRIVATE_KEY --broadcast

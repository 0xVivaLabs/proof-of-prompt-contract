source .env

forge script script/Query.s.sol:QueryScript --rpc-url $RPC --gas-price 1000000000 --gas-limit 1000000 --legacy --via-ir --broadcast
 

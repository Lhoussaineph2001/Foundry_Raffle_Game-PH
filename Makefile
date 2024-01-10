-include .env
help:
	@echo "Usage:"
	@echo "make deploy [ARG=...]"
	
build:; forge build

DEFAULT_ANVIL_KEY :=0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6
# if --network-sepolia is sepolia used , the use sepolia stuff , otherwise use anvil stuff

NETWORK_ARGS := --rpc-url $(ANVIL_URL) --private-key DEFAULT_ANVIL_KEY
ifeq ($(findstring --network-seploia,$(ARGS)), --network-sepolia)

NETWORK_ARGS := --rpc-url $(SEPOLIA) --private-key $(PRIVATE_KEY) --broadcast --verify --ethreum-api-key $(ETHEUM_API_KEY) -vvvv

endif 

deploy: 
	
	@forge script script/Deploy_Raffle.s.sol:Deploy_Raffle $("NETWORK_ARGS")
	   
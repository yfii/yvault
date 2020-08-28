import json

from web3 import Web3, HTTPProvider

w3url = "https://mainnet.infura.io/v3/998f64f3627548bbaf2630599c1eefca"

w3 = Web3(HTTPProvider(w3url))

with open("abi/crvdeposit.json") as f:
    abi = json.loads(f.read())

contract_instance = w3.eth.contract(abi=abi,address=w3.toChecksumAddress('0x7ca5b0a2910B33e9759DC7dDB0413949071D7575'))  

contract_instance.functions.claimable_tokens('0xEfb684AB29371e701CCe3CA9e3FD8f5E33042eee').call()  

if __name__ == "__main__":
    pass
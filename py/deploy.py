from web3.auto import w3
from web3 import Web3
from solc import compile_standard
import os
import json

w3.eth.defaultAccount = w3.eth.accounts[0]


def geneateCompiled_sol(sol_name, contract_name):
    basedir = "/Users/gaojin/Documents/GitHub/yvault/contracts"
    fname = os.path.join(basedir, sol_name)
    with open(fname) as f:
        content = f.read()
    _compile_standard = {
        "language": "Solidity",
        "sources": {sol_name: {"content": content}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["metadata", "evm.bytecode", "evm.bytecode.sourceMap"]}
            }
        },
    }
    compiled_sol = compile_standard(_compile_standard)
    bytecode = compiled_sol["contracts"][sol_name][contract_name]["evm"]["bytecode"][
        "object"
    ]
    abi = json.loads(compiled_sol["contracts"][sol_name][contract_name]["metadata"])[
        "output"
    ]["abi"]

    c = w3.eth.contract(abi=abi, bytecode=bytecode)
    return c, abi


def deploy():
    ## Controller
    Controller, abi = geneateCompiled_sol("Controller.sol", "Controller")
    tx_hash = Controller.constructor().transact()
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    controller_instance = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)

    Yfii, abi = geneateCompiled_sol("yfiicontract.sol", "YFII")
    tx_hash = Yfii.constructor("YFII", "YFII").transact()
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    yfii_instance = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
    print(yfii_instance.functions.name().call())

    token, abi = geneateCompiled_sol("yfiicontract.sol", "NewToken")
    tx_hash = token.constructor("NewToken", "NewToken").transact()
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    token_instance = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
    print(token_instance.functions.name().call())

    StrategyYfii, abi = geneateCompiled_sol("StrategyCurveYfii.sol", "StrategyYfii")
    tx_hash = StrategyYfii.constructor(controller_instance.address).transact()
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    strategyYfii_instance = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
    # print(strategyYfii_instance.functions.controller().call())
    assert (
        strategyYfii_instance.functions.controller().call()
        == controller_instance.address
    )

    yVault, abi = geneateCompiled_sol("yvault.sol", "yVault")
    tx_hash = yVault.constructor(
        token_instance.address, controller_instance.address, yfii_instance.address
    ).transact()
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    yVault_instance = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)

    assert yVault_instance.functions.controller().call() == controller_instance.address
    assert yVault_instance.functions.Yfiitoken().call() == yfii_instance.address
    assert yVault_instance.functions.token().call() == token_instance.address


if __name__ == "__main__":
    deploy()

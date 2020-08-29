import json

from web3 import Web3, HTTPProvider

w3url = "https://mainnet.infura.io/v3/998f64f3627548bbaf2630599c1eefca"

w3 = Web3(HTTPProvider(w3url))

with open("abi/vault.json") as f:
    abi = json.loads(f.read())


def get_total_out(contract_address):
    contract_address = w3.toChecksumAddress(contract_address)
    contract_instance = w3.eth.contract(abi=abi, address=contract_address)
    total_out = contract_instance.functions.global_(0).call()[1]
    return total_out


if __name__ == "__main__":
    vaults_address = set(
        [
            "0xf693705e79ccc8707D3FcB4D89381CaC28e45a22",
            "0xd4bEf8D8D8d7cBB89f63933Db6907439f9E6Fd0f",
            "0xA2D35bcDFc271767903f0Ed4aF56a066F6c99Ae7",
            "0x537350b9301fCf045Eaf1CEa2F225276C89D5f6D",
            "0x4BD410A06FBB3A22C31017964D13Cbc5867d3d61",
            "0xCda9230923FCb25e26a20D7D9D12e1744405C9fC",
            "0x7AEFB9DCE3700B7CE8B1f556043BB1D436C77e0d",
            "0x2f4Ae3a95C7B457DB53706EEE8979aEca4ec0082",
            "0xD2db1EF55549eCdacb4e7da081216AE96f0Eedcb",
            "0xf5a232b1325769E09B303D7292589a2C7AEe2Aa4",
            "0x804a3DBb6C1f4c379B3ee985488Ef37C4cBbac5C",
            "0x35a228bBe17F7c6D1ebaCc59fcA3aC6733135E63",
            "0x8FDD31b72Cc18c965E6a7BC85174994e72799732",
            "0xA9C7216650dA5A9bbC049ffa56008029344DB010",
            "0x956da37db508901294f62488e030ce0871293270",
            "0x5c8Bb2C9C0bC2655dE05198de50651820b95C541",
            "0xed288394e3086fb90e43f4919b5d3661c05278be",
            "0xD2db1EF55549eCdacb4e7da081216AE96f0Eedcb",
            "0x7b0f825efe96dd46f1460227d634ea37b10ca7c5",
            "0xd0249f2e69098029b2b37c888c061a0d95f989a2",
            "0xa407c685422d6b4bf07809216bb597125312a790",
            "0xab721be37a57b7f91098cb5f11ae423dc76350a9",
            "0xf811c062D14fdF9Fda95D6A2C54e137afE80De45",
        ]
    )

    total_out = sum([get_total_out(i) for i in vaults_address])
    total_out = total_out / 1e18
    print(total_out)

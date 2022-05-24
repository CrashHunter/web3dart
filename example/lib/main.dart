import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

const String privateKey =
    '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
const String rpcUrl = 'http://localhost:8545';

Future<void> main() async {
  // start a client we can use to send transactions
  final client = Web3Client(rpcUrl, Client());
  client.getNetworkId().then((id) {
    print('Network id: $id');
  });
  client.getChainId().then((id) {
    print('Chain id: $id');
  });

  final credentials = EthPrivateKey.fromHex(privateKey);
  final address = credentials.address;

  print(address.hexEip55);
  print(await client.getBalance(address));

  await client.sendTransaction(
    credentials,
    Transaction(
      to: EthereumAddress.fromHex('0x70997970C51812dc3A010C7d01b50e0d17dc79C8'),
      gasPrice: EtherAmount.inWei(BigInt.from(875000000)),
      maxGas: 100000,
      value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
    ),
    chainId: 31337,
  );

  await client.dispose();
}

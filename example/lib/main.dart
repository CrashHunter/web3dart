import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

const String privateKey =
    'a0a4aa9b726b2d189ddb1b97836ddc7e88ff1641182f1d504122bb5aa3eb458f';
const String rpcUrl = 'https://goerli.infura.io/v3/ae34a04dea934286a1e6aaf22fac4999';

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
  print('1111111');
  print(address.hexEip55);
  print(await client.getBalance(address));

  await client.sendTransaction(
    credentials,
    Transaction(
      to: EthereumAddress.fromHex('0x70997970C51812dc3A010C7d01b50e0d17dc79C8'),
      gasPrice: EtherAmount.inWei(BigInt.from(875000000)),
      maxGas: 100000,
      value: EtherAmount.fromUnitAndValue(EtherUnit.wei, 1),
    ),
    chainId: 5,
  );

  await client.dispose();
}

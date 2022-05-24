import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

const String privateKey =
    'f7e5913cf852c8ff7be4dfa2560dacbbba56ce361d41af11efe8360e7ac414f1';
const String rpcUrl = 'http://localhost:7545';

Future<void> main() async {
  // start a client we can use to send transactions
  final client = Web3Client(rpcUrl, Client());
  client.getNetworkId().then((id) {
    print('Network id: $id');
  });

  final credentials = EthPrivateKey.fromHex(privateKey);
  final address = credentials.address;

  print(address.hexEip55);
  print(await client.getBalance(address));

  await client.sendTransaction(
    credentials,
    Transaction(
      to: EthereumAddress.fromHex('0xD295C6e98Af937A32C84219eA1D30c127C0b34a5'),
      gasPrice: EtherAmount.inWei(BigInt.one),
      maxGas: 100000,
      value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
    ),
  );

  await client.dispose();
}

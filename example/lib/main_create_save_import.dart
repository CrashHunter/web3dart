import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math';

const String rpcUrl = 'http://localhost:7545';

Future<void> main() async {
  // start a client we can use to send transactions
  final client = Web3Client(rpcUrl, Client());


  // 生成一个新的地址
  var rng = Random.secure();
  Credentials random = EthPrivateKey.createRandom(rng);
  var address = await random.extractAddress();
  print(address.hexEip55);
  print(await client.getBalance(address));

  // Wallet wallet = Wallet.createNew(credentials, "password", random);
  // print(wallet.toJson());


  await client.dispose();
}

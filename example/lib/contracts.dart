import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import 'MetaCoin.g.dart';

const String rpcUrl = 'http://localhost:8545';
const String wsUrl = 'ws://localhost:8545';

const String privateKey =
    '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

final EthereumAddress contractAddr =
    EthereumAddress.fromHex('0x5FC8d32690cc91D4c39d9d3abcBD16989F875707');
final EthereumAddress receiver =
    EthereumAddress.fromHex('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');

/*
Examples that deal with contracts. The contract used here is from the truffle
example:

contract MetaCoin {
	mapping (address => uint) balances;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	constructor() public {
		balances[tx.origin] = 10000;
	}

	function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
		if (balances[msg.sender] < amount) return false;
		balances[msg.sender] -= amount;
		balances[receiver] += amount;
		emit Transfer(msg.sender, receiver, amount);
		return true;
	}

	function getBalanceInEth(address addr) public view returns(uint){
		return ConvertLib.convert(getBalance(addr),2);
	}

	function getBalance(address addr) public view returns(uint) {
		return balances[addr];
	}
}

The ABI of this contract is available at abi.json
To generate contract classes, add a dependency on web3dart and build_runner.
Running `dart pub run build_runner build` (or `flutter pub ...` if you're using
Flutter) will generate classes for an .abi.json file.
 */

Future<void> main() async {
  // establish a connection to the ethereum rpc node. The socketConnector
  // property allows more efficient event streams over websocket instead of
  // http-polls. However, the socketConnector property is experimental.
  final client = Web3Client(
    rpcUrl,
    Client(),
    socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    },
  );
  final credentials = EthPrivateKey.fromHex(privateKey);
  final ownAddress = await credentials.extractAddress();

  // read the contract abi and tell web3dart where it's deployed (contractAddr)
  final token = MetaCoin(address: contractAddr, client: client);

  // listen for the Transfer event when it's emitted by the contract above
  final subscription = token.transferEvents().take(1).listen((event) {
    print('${event.from} sent ${event.value} MetaCoins to ${event.to}!');
  });

  // check our balance in MetaCoins by calling the appropriate function
  final balance = await token.getBalance(ownAddress);
  print('We have $balance MetaCoins');

  var num = BigInt.from(balance/BigInt.from(2));
  // send all our MetaCoins to the other address by calling the sendCoin
  // function
  await token.sendCoin(receiver, num, credentials: credentials);

  await subscription.asFuture();
  await subscription.cancel();

  await client.dispose();
}

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import 'Test721.g.dart';

const String rpcUrl = 'https://goerli.infura.io/v3/ae34a04dea934286a1e6aaf22fac4999';
const String wsUrl = 'wss://goerli.infura.io/ws/v3/ae34a04dea934286a1e6aaf22fac4999';

const String privateKey =
    'a0a4aa9b726b2d189ddb1b97836ddc7e88ff1641182f1d504122bb5aa3eb458f';

final EthereumAddress contractAddr =
    EthereumAddress.fromHex('0x57762cA9F3F4B2ac228c3AaA8460556C4613c1dB');
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

  // read the contract abi and tell web3dart where it's deployed (contractAddr)
  final contractObj = Test721(address: contractAddr, client: client);

  // listen for the Transfer event when it's emitted by the contract above
  final subscription = contractObj.transferEvents().take(1).listen((event) {
  });

  // check our balance in MetaCoins by calling the appropriate function
  final balance = await contractObj.autoMint(receiver, credentials: credentials);
  print('We have $balance MetaCoins');


  await subscription.asFuture();
  await subscription.cancel();

  await client.dispose();
}

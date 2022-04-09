import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class MyBlockchainHome extends StatefulWidget {
  const MyBlockchainHome({Key? key}) : super(key: key);

  @override
  State<MyBlockchainHome> createState() => _MyBlockchainHomeState();
}

class _MyBlockchainHomeState extends State<MyBlockchainHome> {
  late Client httpClient;
  late Web3Client ethClient;

//Ethereum address
  final String myAddress = "0x232adFFc0b8471fE064e7Eecb372dD5361CFb3e3";

//url from Infura
  final String blockchainUrl =
      "https://rinkeby.infura.io/v3/5cafc22776294a9faaa664875580dc92";

//store the value of alpha and beta
  var totalVotesA;
  var totalVotesB;

  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(
      blockchainUrl,
      httpClient,
    );
    getTotalVotes();
    super.initState();
  }

  Future<DeployedContract> getContract() async {
//obtain our smart contract using rootbundle to access our json file
    String abiFile = await rootBundle.loadString("assets/contract.json");

    String contractAddress = "0xcCAc5DFb31B4AB70A7FA1721063c9D3f4a6009D0";

    final contract = DeployedContract(ContractAbi.fromJson(abiFile, "Voting"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> callFunction(String name) async {
    final contract = await getContract();
    final function = contract.function(name);
    final result = await ethClient
        .call(contract: contract, function: function, params: []);

    return result;
  }

  snackBar({String? label}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label!),
            CircularProgressIndicator(
              color: Colors.white,
            )
          ],
        ),
        duration: Duration(days: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> vote(bool voteAlpha) async {
    snackBar(label: "Recording vote");
    //obtain private key for write operation
    Credentials key = EthPrivateKey.fromHex(
        "cb4afe22a31bad91ac085d10d30f48c2ad1479af54ec1b7d3311477e5abba61c");

    //obtain our contract from abi in json file
    final contract = await getContract();

    // extract function from json file
    final function = contract.function(
      voteAlpha ? "voteAlpha" : "voteBeta",
    );

    //send transaction using the our private key, function and contract
    await ethClient.sendTransaction(
      key,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [],
        // maxGas: 1,
        gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 36),
      ),
      chainId: 4,
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    snackBar(label: "verifying vote");
    //set a 20 seconds delay to allow the transaction to be verified before trying to retrieve the balance
    Future.delayed(const Duration(seconds: 20), () {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      snackBar(label: "retrieving votes");
      getTotalVotes();

      ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

  Future<void> getTotalVotes() async {
    List<dynamic> resultsA = await callFunction("getTotalVotesAlpha");
    List<dynamic> resultsB = await callFunction("getTotalVotesBeta");
    totalVotesA = resultsA[0];
    totalVotesB = resultsB[0];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: Text("$totalVotesA"),
            subtitle: Text("totalVotesA"),
          ),
          ListTile(
            title: Text("$totalVotesB"),
            subtitle: Text("totalVotesB"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  vote(true);
                },
                child: Text('Vote Alpha'),
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  vote(false);
                },
                child: Text('Vote Beta'),
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              )
            ],
          )
        ],
      ),
    );
  }
}

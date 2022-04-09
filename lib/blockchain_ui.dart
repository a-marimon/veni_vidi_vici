import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import 'Somewidget.dart';

class MyBlockchainHome extends StatefulWidget {
  final String id;

  const MyBlockchainHome({Key? key, required this.id}) : super(key: key);

  @override
  State<MyBlockchainHome> createState() => _MyBlockchainHomeState();
}

class _MyBlockchainHomeState extends State<MyBlockchainHome> {
  late Client httpClient;
  late Web3Client ethClient;
  TextEditingController _controller = TextEditingController();

//Ethereum address
//   final String myAddress = "0x232adFFc0b8471fE064e7Eecb372dD5361CFb3e3";
  late String myAddress;

//url from Infura
  static const String BLOCKCHAIN_URL =
      "https://ropsten.etherscan.io/tx/0x383f0861de5a6fd741e99877af5fa3c39c82f02c50d9933b7438e2985f791a63";
  static const String CONTRACT_ADDRESS =
      "0x8f1ddc99dc16e91822251de4ca6ac0f4e37c14ba";
  static const String PRIV_KEY =
      "cb4afe22a31bad91ac085d10d30f48c2ad1479af54ec1b7d3311477e5abba61c";

//store the value of alpha and beta
  var totalVotesA;
  var totalVotesB;
  bool showProgress = false;
  String filename = '';

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
      BLOCKCHAIN_URL,
      httpClient,
    );
    // getTotalVotes();
    myAddress = widget.id;
  }

  Future<DeployedContract> getContract() async {
//obtain our smart contract using rootbundle to access our json file
    String abiFile = await rootBundle.loadString("assets/contract.json");

    final contract = DeployedContract(ContractAbi.fromJson(abiFile, "MyNFT"),
        EthereumAddress.fromHex(CONTRACT_ADDRESS));

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

  Future<void> mintNft(String id) async {
    Credentials key = EthPrivateKey.fromHex(PRIV_KEY);
    final contract = await getContract();
    final function = contract.function('mintNFT');

    // var addr = EthereumAddress.fromHex(myAddress);
    var addr =
        EthereumAddress.fromHex("0x232adFFc0b8471fE064e7Eecb372dD5361CFb3e3");
    var trr = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [
        addr,
        "ipfs://QmfN4fifqCMmQUCpeJDHyjKuVRjUM5PsFobtnrqKSg3h6r"
      ],
      gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 36),
    );
    // await ethClient.sendTransaction(
    //   key,
    //   trr,
    //   chainId: 4,
    // );
    // print(res);
  }

  Future<void> vote(bool voteAlpha) async {
    snackBar(label: "Recording vote");
    //obtain private key for write operation
    Credentials key = EthPrivateKey.fromHex(PRIV_KEY);

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
      // getTotalVotes();

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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/login-bg.jpg"), fit: BoxFit.cover),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                      // decoration: InputDecoration(
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(10.0),
                      // ),
                      // filled: true,
                      // hintStyle: TextStyle(color: Colors.grey[800]),
                      // hintText: "Type in your text",
                      // fillColor: Colors.white70),
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        labelText: 'Recipient Address',
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                    child: ElevatedButton(
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        setState(() {
                          showProgress = true;
                          filename = result?.names.first ?? 'test.png';
                        });
                        Future.delayed(const Duration(seconds: 5), () {
                          setState(() {
                            showProgress = false;
                          });
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Somewidget(),
                            ),
                          );
                        });
                      },
                      child: Container(
                        width: 250,
                        height: 50,
                        alignment: Alignment.center,
                        child: Text('Upload File'),
                      ),
                      // style: ElevatedButton.styleFrom(
                      //   primary: Color(0xFFF3901A),
                      // ),
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                    side: BorderSide(color: Colors.red))),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            return Color(0xFFF3901A);
                          },
                        ),
                      ),
                      // style: ButtonStyle(backgroundColor:  Color(0xFFF3901A)!),
                    ),
                  ),
                  Visibility(visible: showProgress, child: Text(filename)),
                  Visibility(
                    visible: showProgress,
                    child: LinearProgressIndicator(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

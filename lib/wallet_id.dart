import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veni_vidi_vici/blockchain_ui.dart';

class WalletIdCollector extends StatelessWidget {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Metamask Public Id'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Public Id',
            ),
          ),
          TextButton(onPressed: (){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>  MyBlockchainHome(id: _controller.text),
              ),
            );
          }, child: Text('Submit'))
        ],
      ),
    );
  }
}

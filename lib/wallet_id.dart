import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veni_vidi_vici/blockchain_ui.dart';

class WalletIdCollector extends StatelessWidget {
  TextEditingController _controller = TextEditingController();

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
                  labelText: 'Public Address',
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            //   child: TextField(
            //     controller: _controller,
            //     decoration: InputDecoration(
            //       border: OutlineInputBorder(),
            //       labelText: 'Public Id',
            //     ),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          MyBlockchainHome(id: _controller.text),
                    ),
                  );
                },
                child: Container(
                  width: 250,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text('Submit'),
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
          ],
        ),
      ),
    );
  }
}

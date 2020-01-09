import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ap/Constants.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String token;
  var data;

  Widget rowItem({count, name}) => Column(
        children: <Widget>[Text("$count"), Text(name)],
      );

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (data != null) {
      body = SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: 50,),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Card(
                //margin: EdgeInsets.only(top:20),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 40,
                                backgroundImage:
                                    NetworkImage(data["data"]["profile_picture"]),
                              ),
                            ),
                          ),
                          Expanded(child: rowItem(count: data["data"]["counts"]["media"],name: "Posts")),
                          Expanded(child: rowItem(count: data["data"]["counts"]["followed_by"],name: "Followers")),
                          Expanded(child: rowItem(count: data["data"]["counts"]["follows"],name: "Followings")),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                        child: Text(
                          data["data"]["full_name"],
                          style: TextStyle(
                              fontWeight: FontWeight.w600, letterSpacing: 1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 55, 0),
                        child: Text(
                          data["data"]["bio"],
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                        child: Text(
                          data["data"]["website"],
                          style: TextStyle(color: Colors.blue.shade900),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      body = Container(
        child: Center(
            child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          onPressed: () {
            loginWithInstagram();
          },
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "Login With Instagram",
              style: TextStyle(color: Colors.white),
            ),
          ),
        )),
      );
    }

    return Scaffold(
        appBar: data == null
            ? AppBar(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(50))),
                title: Text("Instagram Login"),
                centerTitle: true,
              )
            : null,
        body: body);
  }

  loginWithInstagram() {
    String url =
        "https://api.instagram.com/oauth/authorize?client_id=${Constant.ID}&redirect_uri=http://sachtechsolution.com/&response_type=token&display=touch&scope=basic";
    getUserDetails() {
      Future<http.Response> getUserInfo() {
        return http.get(
            "https://api.instagram.com/v1/users/self/?access_token=$token");
      }

      getUserInfo().then((response) {
        setState(() {
          data = jsonDecode(response.body);
          print(data);
          print(data["data"]["profile_picture"]);
        });
      });
    }

    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.launch(url);

    flutterWebviewPlugin.onUrlChanged.listen((url) {
      if (url.contains("access_token=")) {
        setState(() {
          token = url.substring(url.lastIndexOf("=") + 1);
        });
        if (token != null && token.toString().isNotEmpty) {
          flutterWebviewPlugin.close();
          print(token);
          getUserDetails();
        } else {
          print("Not Able to fetch token");
        }
      }
    });
  }
}

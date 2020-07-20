import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Sign In Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Social Sign In Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoginFB = false;
  bool isLoginGoogle = false;
  Map userProfile;
  final FacebookLogin _facebookLogin = FacebookLogin();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ["email"]);

  loginWithFb() async {
    final result = await _facebookLogin.logInWithReadPermissions(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final response = await http.get(
            "https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=$token");
        final profile = json.decode(response.body);
        setState(() {
          userProfile = profile;
          isLoginFB = true;
        });
        break;
      case FacebookLoginStatus.cancelledByUser:
        setState(() {
          isLoginFB = false;
        });
        break;

      case FacebookLoginStatus.error:
        setState(() {
          isLoginFB = false;
        });
        break;
    }
  }

  logoutWithFb() async {
    try {
      _facebookLogin.logOut();
      setState(() {
        isLoginFB = false;
      });
    } catch (e) {
      print(e);
    }
  }

  loginWithFoogle() async {
    try {
      await _googleSignIn.signIn();
      setState(() {
        isLoginGoogle = true;
      });
    } catch (e) {
      print(e);
    }
  }

  logoutWithGoogle() async {
    try {
      _googleSignIn.signOut();
      setState(() {
        isLoginGoogle = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.indigo,
                height: 50,
                child: OutlineButton(
                  onPressed: () {
                    loginWithFb();
                  },
                  child: Text("Login with Facebook",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.red,
                height: 50,
                child: OutlineButton(
                  onPressed: () {
                    loginWithFoogle();
                  },
                  child: Text("Login with Google",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            isLoginFB
                ? IconButton(
                    icon: Icon(Icons.settings_power),
                    onPressed: () {
                      logoutWithFb();
                    })
                : isLoginGoogle
                    ? IconButton(
                        icon: Icon(Icons.settings_power),
                        onPressed: () {
                          logoutWithGoogle();
                        })
                    : Container()
          ],
        ), // This trailing comma
        body: isLoginFB
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network(
                      userProfile["picture"]["data"]["url"],
                      height: 50.0,
                      width: 50.0,
                    ),
                    Text(userProfile["name"]),
                    Text(userProfile["email"] ?? ""),
                  ],
                ),
              )
            : isLoginGoogle
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.network(
                          _googleSignIn.currentUser.photoUrl,
                          height: 50.0,
                          width: 50.0,
                        ),
                        Text(_googleSignIn.currentUser.displayName),
                        Text(_googleSignIn.currentUser.email),
                      ],
                    ),
                  )
                : Center(
                    child: Text("Please Login Again!"),
                  ) // makes auto-formatting nicer for build methods.
        );
  }
}

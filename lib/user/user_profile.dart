import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertask_fininfocom/user/user_home.dart';
import 'package:fluttertask_fininfocom/user/userpage.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _formkey = GlobalKey<FormState>();
  final _textFieldController = TextEditingController();
  String? label = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .3,
          ),
          ElevatedButton(
              onPressed: () async {
                var resultLabel = await _showTextInputDialog(context);
                if (resultLabel != null) {
                  setState(() {
                    label = resultLabel;
                  });
                }
              },
              child: Text("Change password")),
          ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                  content: Text('Not Authorized!!'),
                ));
              },
              child: const Text("Add User")),
        ]),
      ),
    );
  }

  void _changePassword(String password) async {
    //Create an instance of the current user.
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? currentUser = firebaseAuth.currentUser;

    //Pass in the password to updatePassword.
    currentUser?.updatePassword(password).then((_) {
      print("Successfully changed password");
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }

  Future<String?> _showTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Change password'),
            content: Form(
              key: _formkey,
              child: TextFormField(
                controller: _textFieldController,
                validator: (value) {
                  RegExp regex = RegExp(r'^.{6,}$');
                  if (value!.isEmpty) {
                    return "Password cannot be empty";
                  }
                  if (!regex.hasMatch(value)) {
                    return ("please enter valid password min. 6 character");
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  _textFieldController.text = value!;
                },
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(hintText: "enter new password"),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      _changePassword(_textFieldController.text);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                        content: Text('Password updated successfully!!'),
                      ));
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserPage(),
                        ),
                      );
                    }
                  }),
            ],
          );
        });
  }
}

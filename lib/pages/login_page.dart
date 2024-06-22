import "package:flutter/material.dart";

import "package:font_awesome_flutter/font_awesome_flutter.dart";

import "package:meepmrp_client/app_colors.dart";
import "package:meepmrp_client/user_profile.dart";
//import "package:meepmrp_client/l10.dart";
import "package:meepmrp_client/api.dart";
import "package:meepmrp_client/widget/dialogs.dart";
import "package:meepmrp_client/widget/progress.dart";


class MeepMrpLoginWidget extends StatefulWidget {

  const MeepMrpLoginWidget(this.profile) : super();

  final UserProfile profile;

  @override
  MeepMrpLoginState createState() => MeepMrpLoginState();

}


class MeepMrpLoginState extends State<MeepMrpLoginWidget> {

  final formKey = GlobalKey<FormState>();

  String username = "";
  String password = "";

  bool _obscured = true;

  String error = "";

  // Attempt login
  Future<void> _doLogin(BuildContext context) async {

    // Save form
    formKey.currentState?.save();

    bool valid = formKey.currentState?.validate() ?? false;

    if (valid) {

      // Dismiss the keyboard
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }

      showLoadingOverlay(context);

      // Attempt login
      final successs = await MeepMrpApi().fetchToken(widget.profile, username, password);

      hideLoadingOverlay();

      if (successs) {
        // Return to the server selector screen
        Navigator.of(context).pop();
      } else {
        setState(() {
          error = "Failed to login";
        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {

    List<Widget> before = [
      const ListTile(
        //title: Text(L10().loginEnter),
        //subtitle: Text(L10().loginEnterDetails),
        title: Text("Enter login details"),
        subtitle: Text("Username and password are not stored locally"),
        leading: FaIcon(FontAwesomeIcons.userCheck),
      ),
      ListTile(
        //title: Text(L10().server),
        title: const Text("Server"),
        subtitle: Text(widget.profile.server),
        leading: const FaIcon(FontAwesomeIcons.server),
      ),
      const Divider(),
    ];

    List<Widget> after = [];

    if (error.isNotEmpty) {
      after.add(const Divider());
      after.add(ListTile(
        leading: const FaIcon(FontAwesomeIcons.circleExclamation, color: COLOR_DANGER),
        //title: Text(L10().error, style: TextStyle(color: COLOR_DANGER)),
        title: const Text("Error", style: TextStyle(color: COLOR_DANGER)),
        subtitle: Text(error, style: const TextStyle(color: COLOR_DANGER)),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        //title: Text(L10().login),
        title: const Text("Login"),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowRightToBracket, color: COLOR_SUCCESS),
            onPressed: () async {
              _doLogin(context);
            },
          )
        ]
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...before,
              TextFormField(
                decoration: const InputDecoration(
                    //labelText: L10().username,
                    labelText: "Username",
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    //hintText: L10().enterUsername
                    hintText: "Enter username"
                ),
                initialValue: "",
                keyboardType: TextInputType.text,
                onSaved: (value) {
                  username = value?.trim() ?? "";
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    //return L10().usernameEmpty;
                    return "Username cannot be empty";
                  }

                  return null;
                },
              ),
              TextFormField(
                  decoration: InputDecoration(
                    //labelText: L10().password,
                    labelText: "Password",
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    //hintText: L10().enterPassword,
                    hintText: "Enter password",
                    suffixIcon: IconButton(
                      icon: _obscured ? const FaIcon(FontAwesomeIcons.eye) : const FaIcon(FontAwesomeIcons.solidEyeSlash),
                      onPressed: () {
                        setState(() {
                          _obscured = !_obscured;
                        });
                      },
                    ),
                  ),
                  initialValue: "",
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _obscured,
                  onSaved: (value) {
                    password = value?.trim() ?? "";
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      //return L10().passwordEmpty;
                      return "Password cannot be empty";
                    }

                    return null;
                  }
              ),
              ...after,
            ],
          ),
        )
      )
    );

  }

}
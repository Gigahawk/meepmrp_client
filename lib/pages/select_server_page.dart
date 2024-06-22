import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:meepmrp_client/pages/login_page.dart";
import "package:one_context/one_context.dart";

//import "package:inventree/settings/login.dart";
import "package:meepmrp_client/app_colors.dart";
import "package:meepmrp_client/widget/dialogs.dart";
import "package:meepmrp_client/widget/spinner.dart";
//import "package:meepmrp_client/l10.dart";
import "package:meepmrp_client/api.dart";
import "package:meepmrp_client/user_profile.dart";

class MeepMrpSelectServerWidget extends StatefulWidget {

  @override
  MeepMrpSelectServerState createState() => MeepMrpSelectServerState();
}


class MeepMrpSelectServerState extends State<MeepMrpSelectServerWidget> {

  MeepMrpSelectServerState() {
    _reload();
  }

  final GlobalKey<MeepMrpSelectServerState> _loginKey = GlobalKey<MeepMrpSelectServerState>();

  List<UserProfile> profiles = [];

  Future <void> _reload() async {

    profiles = await UserProfileDBManager().getAllProfiles();

    if (!mounted) {
      return;
    }

    setState(() {
    });
  }

  /*
   * Logout the selected profile (delete the stored token)
   */
  Future<void> _logoutProfile(BuildContext context, {UserProfile? userProfile}) async {

    if (userProfile != null) {
      userProfile.token = "";
      await UserProfileDBManager().updateProfile(userProfile);

      _reload();
    }

    MeepMrpApi().disconnectFromServer();
    _reload();

  }

  /*
   * Edit the selected profile
   */
  void _editProfile(BuildContext context, {UserProfile? userProfile, bool createNew = false}) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditWidget(userProfile)
      )
    ).then((context) {
      _reload();
    });
  }

  Future <void> _selectProfile(BuildContext context, UserProfile profile) async {

    // Disconnect InvenTree
    MeepMrpApi().disconnectFromServer();

    var key = profile.key;

    if (key == null) {
      return;
    }

    await UserProfileDBManager().selectProfile(key);

    UserProfile? prf = await UserProfileDBManager().getProfileByKey(key);

    if (prf == null) {
      return;
    }

    // First check if the profile has an associate token
    if (!prf.hasToken) {
      // Redirect user to login screen
      Navigator.push(context,
        MaterialPageRoute(builder: (context) => MeepMrpLoginWidget(profile))
      ).then((value) async {
        _reload();
        // Reload profile
        prf = await UserProfileDBManager().getProfileByKey(key);
        if (prf?.hasToken ?? false) {
          MeepMrpApi().connectToServer(prf!).then((result) {
            _reload();
          });
        }
      });

      // Exit now, login handled by next widget
      return;
    }

    if (!mounted) {
      return;
    }

    _reload();

    // Attempt server login (this will load the newly selected profile
    MeepMrpApi().connectToServer(prf).then((result) {
      _reload();
    });

    _reload();
  }

  Future <void> _deleteProfile(UserProfile profile) async {

    await UserProfileDBManager().deleteProfile(profile);

    if (!mounted) {
      return;
    }

    _reload();

    if (MeepMrpApi().isConnected() && profile.key == (MeepMrpApi().profile?.key ?? "")) {
      MeepMrpApi().disconnectFromServer();
    }
  }

  Widget? _getProfileIcon(UserProfile profile) {

    // Not selected? No icon for you!
    if (!profile.selected) return null;

    // Selected, but (for some reason) not the same as the API...
    if ((MeepMrpApi().profile?.key ?? "") != profile.key) {
      return null;
    }

    // Reflect the connection status of the server
    if (MeepMrpApi().isConnected()) {
      return const FaIcon(
        FontAwesomeIcons.circleCheck,
        color: COLOR_SUCCESS
      );
    } else if (MeepMrpApi().isConnecting()) {
      return const Spinner(
        icon: FontAwesomeIcons.spinner,
        color: COLOR_PROGRESS,
      );
    } else {
      return const FaIcon(
        FontAwesomeIcons.circleXmark,
        color: COLOR_DANGER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> children = [];

    if (profiles.isNotEmpty) {
      for (int idx = 0; idx < profiles.length; idx++) {
        UserProfile profile = profiles[idx];

        children.add(ListTile(
          title: Text(
            profile.name,
          ),
          tileColor: profile.selected ? Theme.of(context).secondaryHeaderColor : null,
          subtitle: Text("${profile.server}"),
          leading: profile.hasToken ? const FaIcon(FontAwesomeIcons.userCheck, color: COLOR_SUCCESS) : FaIcon(FontAwesomeIcons.userSlash, color: COLOR_WARNING),
          trailing: _getProfileIcon(profile),
          onTap: () {
            _selectProfile(context, profile);
          },
          onLongPress: () {
            OneContext().showDialog(
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text(profile.name),
                    children: <Widget>[
                      const Divider(),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _selectProfile(context, profile);
                        },
                        child: const ListTile(
                          //title: Text(L10().profileConnect),
                          title: Text("Connect to Server"),
                          leading: FaIcon(FontAwesomeIcons.server),
                        )
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _editProfile(context, userProfile: profile);
                        },
                        child: const ListTile(
                          //title: Text(L10().profileEdit),
                          title: Text("Edit Server Profile"),
                          leading: FaIcon(FontAwesomeIcons.penToSquare)
                        )
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _logoutProfile(context, userProfile: profile);
                        },
                        child: const ListTile(
                          //title: Text(L10().profileLogout),
                          title: Text("Logout Profile"),
                          leading: FaIcon(FontAwesomeIcons.userSlash),
                        )
                      ),
                      const Divider(),
                      SimpleDialogOption(
                        onPressed: () {
                          //Navigator.of(context).pop();
                          //// Navigator.of(context, rootNavigator: true).pop();
                          //confirmationDialog(
                          //  L10().delete,
                          //  L10().profileDelete + "?",
                          //  color: Colors.red,
                          //  icon: FontAwesomeIcons.trashCan,
                          //  onAccept: () {
                          //    _deleteProfile(profile);
                          //  }
                          //);
                        },
                        child: const ListTile(
                          //title: Text(L10().profileDelete, style: TextStyle(color: Colors.red)),
                          title: Text(
                            "Delete Server Profile",
                            style: TextStyle(color: Colors.red)
                          ),
                          leading: FaIcon(FontAwesomeIcons.trashCan, color: Colors.red),
                        )
                      )
                    ],
                  );
                }
            );
          },
        ));
      }
    } else {
      // No profile available!
      children.add(
        const ListTile(
          //title: Text(L10().profileNone),
          title: Text("No profiles available"),
        )
      );
    }

    return Scaffold(
      key: _loginKey,
      appBar: AppBar(
        //title: Text(L10().profileSelect),
        title: const Text("Select MeepMRP Server"),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.circlePlus),
            onPressed: () {
              _editProfile(context, createNew: true);
            },
          )
        ],
      ),
      //body: Container(
      //  child: ListView(
      //    children: ListTile.divideTiles(
      //      context: context,
      //      tiles: children
      //    ).toList(),
      //  )
      //),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: children
        ).toList(),
      ),
    );
  }
}


/*
 * Widget for editing server details
 */
class ProfileEditWidget extends StatefulWidget {

  const ProfileEditWidget(this.profile) : super();

  final UserProfile? profile;

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEditWidget> {

  _ProfileEditState() : super();

  final formKey = GlobalKey<FormState>();

  String name = "";
  String server = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text(widget.profile == null ? L10().profileAdd : L10().profileEdit),
        title: Text(
          widget.profile == null ? "Add Server Profile" : "Edit Server Profile"),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.floppyDisk),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                UserProfile? prf = widget.profile;

                if (prf == null) {
                  UserProfile profile = UserProfile(
                    name: name,
                    server: server,
                  );

                  await UserProfileDBManager().addProfile(profile);
                } else {

                  prf.name = name;
                  prf.server = server;

                  await UserProfileDBManager().updateProfile(prf);
                }

                // Close the window
                Navigator.of(context).pop();
              }
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
              TextFormField(
                decoration: const InputDecoration(
                  //labelText: L10().profileName,
                  labelText: "Profile Name",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                initialValue: widget.profile?.name ?? "",
                maxLines: 1,
                keyboardType: TextInputType.text,
                onSaved: (value) {
                  name = value?.trim() ?? "";
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    //return L10().valueCannotBeEmpty;
                    return "Value cannot be empty";
                  }

                  return null;
                }
              ),
              TextFormField(
                decoration: const InputDecoration(
                  //labelText: L10().server,
                  labelText: "Server",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  hintText: "http[s]://<server>:<port>",
                ),
                initialValue: widget.profile?.server ?? "",
                keyboardType: TextInputType.url,
                onSaved: (value) {
                  server = value?.trim() ?? "";
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    //return L10().serverEmpty;
                    return "Server cannot be empty";
                  }

                  value = value.trim();

                  // Spaces are bad
                  if (value.contains(" ")) {
                    //return L10().invalidHost;
                    return "Invalid hostname";
                  }

                  if (!value.startsWith("http:") && !value.startsWith("https:")) {
                    // return L10().serverStart;
                    return "Server must start with http[s]";
                  }

                  Uri? _uri = Uri.tryParse(value);

                  if (_uri == null || _uri.host.isEmpty) {
                    //return L10().invalidHost;
                    return "Invalid hostname";
                  } else {
                    Uri uri = Uri.parse(value);

                    if (uri.hasScheme) {
                      if (!["http", "https"].contains(uri.scheme.toLowerCase())) {
                        //return L10().serverStart;
                        return "Server must start with http[s]";
                      }
                    } else {
                      //return L10().invalidHost;
                      return "Invalid hostname";
                    }
                  }

                  // Everything is OK
                  return null;
                },
              ),
            ]
          ),
        ),
      )
    );
  }

}
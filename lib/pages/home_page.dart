import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meepmrp_client/pages/select_server_page.dart';
import 'package:meepmrp_client/widget/drawer.dart';

import 'package:meepmrp_client/widget/refreshable_state.dart';
import 'package:meepmrp_client/user_profile.dart';
import 'package:meepmrp_client/api.dart';
import 'package:meepmrp_client/app_colors.dart';
import 'package:meepmrp_client/widget/spinner.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with BaseWidgetProperties {

  HomePageState() : super() {
    _loadSettings();

    _loadProfile();
  }

  UserProfile? _profile;

  final homeKey = GlobalKey<ScaffoldState>();

  Future<void> _loadSettings() async {
    setState(() {});
  }

  Future<void> _loadProfile() async {
    _profile = await UserProfileDBManager().getSelectedProfile();
    if (_profile != null) {
      if (!MeepMrpApi().isConnected() && !MeepMrpApi().isConnecting()) {
        MeepMrpApi().connectToServer(_profile!).then((result) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
    setState(() {});
  }

  void _selectProfile() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MeepMrpSelectServerWidget())
    ).then((context) {
      // Once we return
      _loadProfile();
    });
  }

    /*
   * If the app is not connected to an InvenTree server,
   * display a connection status widget
   */
  Widget _connectionStatusWidget(BuildContext context) {

    String? serverAddress = MeepMrpApi().serverAddress;
    bool validAddress = serverAddress != null;
    bool connecting = !MeepMrpApi().isConnected() && MeepMrpApi().isConnecting();

    Widget leading = FaIcon(FontAwesomeIcons.circleExclamation, color: COLOR_DANGER);
    Widget trailing = FaIcon(FontAwesomeIcons.server, color: COLOR_ACTION);
    //String title = L10().serverNotConnected;
    //String subtitle = L10().profileSelectOrCreate;
    String title = "Server not connected";
    String subtitle = "Select server or create a new profile";

    if (!validAddress) {
      //title = L10().serverNotSelected;
      title = "Server not selected";
    } else if (connecting) {
      //title = L10().serverConnecting;
      title = "Connecting to server";
      subtitle = serverAddress;
      leading = Spinner(icon: FontAwesomeIcons.spinner, color: COLOR_PROGRESS);
    }

    return Center(
      child: Column(
        children: [
          const Spacer(),
          //Image.asset(
          //  "assets/image/logo_transparent.png",
          //  color: Colors.white.withOpacity(0.05),
          //  colorBlendMode: BlendMode.modulate,
          //  scale: 0.5,
          //),
          const Spacer(),
          ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: trailing,
            leading: leading,
            onTap: _selectProfile,
          )
        ]
      ),
    );
  }

  /*
   * Return the main body widget for display
   */
  @override
  Widget getBody(BuildContext context) {

    if (!MeepMrpApi().isConnected()) {
      return _connectionStatusWidget(context);
    }

    return ListView(
        scrollDirection: Axis.vertical,
        //children: getListTiles(context),
    );
  }

  @override
  Widget build(BuildContext context) {

    var connected = MeepMrpApi().isConnected();
    var connecting = !connected && MeepMrpApi().isConnecting();

    return Scaffold(
      key: homeKey,
      appBar: AppBar(
        //title: Text(L10().appTitle),
        title: const Text("MeepMRP"),
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.server,
              color: (
                connected ? 
                  COLOR_SUCCESS :
                  (connecting ? COLOR_PROGRESS: COLOR_DANGER)
              ),
            ),
            onPressed: _selectProfile,
          )
        ],
      ),
      drawer: MeepMrpDrawer(context),
      body: getBody(context),
      bottomNavigationBar: (
        MeepMrpApi().isConnected() ? 
          buildBottomAppBar(context, homeKey) : null
      ),
    );
  }
}
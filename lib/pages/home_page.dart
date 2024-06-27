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

  Widget _listTile(BuildContext context, String label, IconData icon, {Function()? callback, String role = "", String permission = "", Widget? trailing}) {

    //bool connected = MeepMrpApi().isConnected();

    //bool allowed = true;

    //if (role.isNotEmpty || permission.isNotEmpty) {
    //  allowed = InvenTreeAPI().checkPermission(role, permission);
    //}

    return GestureDetector(
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 12
        ),
        child: ListTile(
          //leading: FaIcon(icon, color: connected && allowed ? COLOR_ACTION : Colors.grey),
          leading: FaIcon(icon, color: COLOR_ACTION),
          title: Text(label),
          trailing: trailing,
        ),
      ),
      onTap: () {
        //if (!allowed) {
        //  showSnackIcon(
        //    L10().permissionRequired,
        //    icon: FontAwesomeIcons.circleExclamation,
        //    success: false,
        //  );
        //  return;
        //}

        if (callback != null) {
          callback();
        }
      },
    );
  }

  /*
   * Constructs a list of tiles for the main screen
   */
  List<Widget> getListTiles(BuildContext context) {


    List<Widget> tiles = [
      const Divider(height: 5)
    ];

    List<String> permissions = MeepMrpApi().permissions;

    // Parts
    if (permissions.contains("part_read")) {
      tiles.add(_listTile(
        context,
        //L10().parts,
        "Parts",
        FontAwesomeIcons.shapes,
        callback: () {
          //_showParts(context);
        },
      ));
    }

    //// Starred parts
    //if (homeShowSubscribed && InvenTreePart().canView) {
    //  tiles.add(_listTile(
    //    context,
    //    L10().partsStarred,
    //    FontAwesomeIcons.bell,
    //    callback: () {
    //      _showStarredParts(context);
    //    }
    //  ));
    //}

    //// Stock button
    //if (InvenTreeStockItem().canView) {
    //  tiles.add(_listTile(
    //      context,
    //      L10().stock,
    //      FontAwesomeIcons.boxesStacked,
    //      callback: () {
    //        _showStock(context);
    //      }
    //  ));
    //}

    //// Purchase orders
    //if (homeShowPo && InvenTreePurchaseOrder().canView) {
    //  tiles.add(_listTile(
    //      context,
    //      L10().purchaseOrders,
    //      FontAwesomeIcons.cartShopping,
    //      callback: () {
    //        _showPurchaseOrders(context);
    //      }
    //  ));
    //}

    //if (homeShowSo && InvenTreeSalesOrder().canView) {
    //  tiles.add(_listTile(
    //    context,
    //    L10().salesOrders,
    //    FontAwesomeIcons.truck,
    //    callback: () {
    //      _showSalesOrders(context);
    //    }
    //  ));
    //}

    //// Suppliers
    //if (homeShowSuppliers && InvenTreePurchaseOrder().canView) {
    //  tiles.add(_listTile(
    //      context,
    //      L10().suppliers,
    //      FontAwesomeIcons.building,
    //      callback: () {
    //        _showSuppliers(context);
    //      }
    //  ));
    //}

    // TODO: Add these tiles back in once the features are fleshed out
    /*


    // Manufacturers
    if (homeShowManufacturers) {
      tiles.add(_listTile(
          context,
          L10().manufacturers,
          FontAwesomeIcons.industry,
          callback: () {
            _showManufacturers(context);
          }
      ));
    }
    */
    //// Customers
    //if (homeShowCustomers) {
    //  tiles.add(_listTile(
    //      context,
    //      L10().customers,
    //      FontAwesomeIcons.userTie,
    //      callback: () {
    //        _showCustomers(context);
    //      }
    //  ));
    //}

    return tiles;
  }

    /*
   * If the app is not connected to an InvenTree server,
   * display a connection status widget
   */
  Widget _connectionStatusWidget(BuildContext context) {

    String? serverAddress = MeepMrpApi().serverAddress;
    bool validAddress = serverAddress != null;
    bool connecting = !MeepMrpApi().isConnected() && MeepMrpApi().isConnecting();

    Widget leading = const FaIcon(FontAwesomeIcons.circleExclamation, color: COLOR_DANGER);
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
        children: getListTiles(context),
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
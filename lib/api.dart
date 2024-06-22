import 'dart:io';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:meepmrp_client/helpers.dart';
import 'package:meepmrp_client/user_profile.dart';
import 'package:meepmrp_client/widget/dialogs.dart';
import 'package:meepmrp_client/widget/snacks.dart';
import 'package:openapi/api.dart';

class APIResponse {

  APIResponse({this.url = "", this.method = "", this.statusCode = -1, this.error = "", this.data = const {}});

  int statusCode = -1;

  String url = "";

  String method = "";

  String error = "";

  String errorDetail = "";

  dynamic data = {};

  // Request is "valid" if a statusCode was returned
  bool isValid() => (statusCode >= 0) && (statusCode < 500);

  bool successful() => (statusCode >= 200) && (statusCode < 300);

  bool redirected() => (statusCode >= 300) && (statusCode < 400);

  bool clientError() => (statusCode >= 400) && (statusCode < 500);

  bool serverError() => statusCode >= 500;

  bool isMap() {
    return data != null && data is Map<String, dynamic>;
  }

  Map<String, dynamic> asMap() {
    if (isMap()) {
      return data as Map<String, dynamic>;
    } else {
      // Empty map
      return {};
    }
  }

  bool isList() {
    return data != null && data is List<dynamic>;
  }

  List<dynamic> asList() {
    if (isList()) {
      return data as List<dynamic>;
    } else {
      return [];
    }
  }

  /*
   * Helper function to interpret response, and return a list.
   * Handles case where the response is paginated, or a complete set of results
   */
  List<dynamic> resultsList() {

    if (isList()) {
      return asList();
    } else if (isMap()) {
      var response = asMap();
      if (response.containsKey("results")) {
        return response["results"] as List<dynamic>;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }
}

class MeepMrpApi {
  factory MeepMrpApi() {
    return _api;
  }
  MeepMrpApi._internal();
  static final MeepMrpApi _api = MeepMrpApi._internal();

  UserProfile? profile;
  bool _connected = false;
  bool _connecting = false;
  Map<String, dynamic> userInfo = {};

  // Endpoint for requesting an API token
  static const _URL_TOKEN = "user/token/";
  static const _URL_ROLES = "user/roles/";
  static const _URL_ME = "user/me/";
  String get baseUrl {
    String url = profile?.server ?? "";
    return url;
  }
  String? get serverAddress {
    return profile?.server;
  }
  String get token => profile?.token ?? "";
  bool get hasToken => token.isNotEmpty;

  bool isConnected() {
    return profile != null && _connected && baseUrl.isNotEmpty && hasToken;
  }

  bool isConnecting() {
    return !isConnected() && _connecting;
  }

    void disconnectFromServer() {
    debug("API : disconnectFromServer()");

    _connected = false;
    _connecting = false;
    profile = null;

    // Clear received settings
    //_globalSettings.clear();
    //_userSettings.clear();

    //roles.clear();
    //_plugins.clear();
    //serverInfo.clear();
    //_connectionStatusChanged();
  }

  Future<bool> _checkServer() async {
    String address = profile?.server ?? "";
    if (address.isEmpty) {
      showSnackIcon(
        "Incomplete profile details",
        icon: FontAwesomeIcons.circleExclamation,
        success: false,
      );
      return false;
    }

    debug("Connecting to apiUrl");
    showStatusCodeError("apiUrl", 500, details: "NotImplemented");
    return false;
  }

   /*
   * Check that the user is authenticated
   * Fetch the user information
   */
  Future<bool> _checkAuth() async {
    debug("Checking user auth @ ${_URL_ME}");

    userInfo.clear();

    //final response = await get(_URL_ME);

    //if (response.successful() && response.statusCode == 200) {
    //  userInfo = response.asMap();
    //  return true;
    //} else {
    //  debug("Auth request failed: Server returned status ${response.statusCode}");
    //  if (response.data != null) {
    //    debug("Server response: ${response.data.toString()}");
    //  }

    //  return false;
    //}
    debug("Auth request failed: not implemented");
    return false;
  }


  Future<bool> _connectToServer() async {
    if (!await _checkServer()) {
      return false;
    }

    if (!hasToken) {
      return false;
    }

    if (!await _checkAuth()) {
      showServerError(
        _URL_ME,
        "Server not connected",
        "Authentication Error"
      );
      if (profile != null) {
        profile!.token = "";
        await UserProfileDBManager().updateProfile(profile!);
      }
      return false;
    }

    // TODO: fetch roles
    // TODO: fetch plugins
    return true;
  }

  Future<bool> connectToServer(UserProfile prf) async {
    disconnectFromServer();
    profile = prf;
    if (profile == null) {
      showSnackIcon(
        "No server selected!",
        success: false,
        icon: FontAwesomeIcons.circleExclamation,
      );
      return false;
    }

    _connecting = true;
    _connected = await _connectToServer();
    _connecting = false;

    return _connected;
  }
}
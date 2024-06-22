import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  UserProfile? _profile;
  UserProfile? get profile => _profile;
  DefaultApi? _client;
  set profile(UserProfile? prf) {
    _profile = prf;
    updateClient();
  }
  bool _connected = false;
  bool _connecting = false;
  Map<String, dynamic> userInfo = {};

  // Endpoint for requesting an API token
  static const _URL_TOKEN = "user/token/";
  static const _URL_ROLES = "user/roles/";
  static const _URL_ME = "user/me/";
  String get baseUrl {
    String url = _client?.apiClient.basePath ?? "";
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

  Future<bool> fetchToken(UserProfile userProfile, String username, String password) async {
    debug("Fetching user token from ${userProfile.server}");
    profile = userProfile;
    if (_client == null) {
      showSnackIcon(
        "Failed to instantiate client for login",
        icon: FontAwesomeIcons.circleExclamation,
        success: false,
      );
      return false;
    }
    Token? token = await _client!.loginLoginPost(username, password);
    if (token == null) {
      showSnackIcon(
        "Failed to login",
        icon: FontAwesomeIcons.circleExclamation,
        success: false,
      );
      return false;
    }
    final tokenStr = token.accessToken;
    profile!.token = tokenStr;
    debug("Received token from server: $tokenStr");
    await UserProfileDBManager().updateProfile(userProfile);
    updateClient();
    return true;
  }

  void updateClient() {
    if (_profile != null) {
      final OAuth? auth = (
        _profile!.token.isNotEmpty ?
          OAuth(accessToken: _profile!.token) :
            null
      );
      _client = DefaultApi(
        ApiClient(
          basePath: _profile!.server,
          authentication: auth
        )
      );
    } else {
      _client = null;
    }
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
    if (_client == null) {
      showSnackIcon(
        "Failed to instantiate client",
        icon: FontAwesomeIcons.circleExclamation,
        success: false,
      );
      return false;
    }

    debug("Connecting to ${baseUrl}");
    try {
      // TODO: API version matching
      final info = await _client!.getServerInfoInfoGet();
      await Future.delayed(const Duration(seconds: 2));
      debug(info.toString());
    } on ApiException catch (e) {
      showServerError(baseUrl, "Server connection error", e.message ?? "Unknown error");
      return false;
    } catch (e) {
      showServerError(baseUrl, "Unknown error", e.toString());
      return false;
    }
    return true;
  }

   /*
   * Check that the user is authenticated
   * Fetch the user information
   */
  Future<bool> _checkAuth() async {
    debug("Checking user auth");

    userInfo.clear();

    User? user = await _client!.getCurrentUserUsersMeGet();

    if (user == null) {
      debug("Login failed");
      return false;
    }
    debug("Logged in as ${user.username}");
    return true;
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
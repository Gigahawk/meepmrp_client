import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meepmrp_client/api.dart';
import 'package:one_context/one_context.dart';

import 'package:meepmrp_client/widget/snacks.dart';

/*
 * Construct an error dialog showing information to the user
 *
 * @title = Title to be displayed at the top of the dialog
 * @description = Simple string description of error
 * @data = Error response (e.g from server)
 */
Future<void> showErrorDialog(String title, {String description = "", APIResponse? response, IconData icon = FontAwesomeIcons.circleExclamation, Function? onDismissed}) async {

  List<Widget> children = [];

  if (description.isNotEmpty) {
    children.add(
      ListTile(
        title: Text(description),
      )
    );
  } else if (response != null) {
    // Look for extra error information in the provided APIResponse object
    switch (response.statusCode) {
      case 400:  // Bad request (typically bad input)
        if (response.data is Map<String, dynamic>) {

          for (String field in response.asMap().keys) {

            dynamic error = response.data[field];

            if (error is List) {
              for (int ii = 0; ii < error.length; ii++) {
                children.add(
                  ListTile(
                    title: Text(field),
                    subtitle: Text(error[ii].toString()),
                  )
                );
              }
            } else {
              children.add(
                  ListTile(
                    title: Text(field),
                    subtitle: Text(response.data[field].toString()),
                  )
              );
            }
          }
        } else {
          children.add(
            ListTile(
              //title: Text(L10().responseInvalid),
              title: const Text("Invalid Response Code"),
              subtitle: Text(response.data.toString())
            )
          );
        }
        break;
      default:
        // Unhandled server response
        children.add(
          ListTile(
            //title: Text(L10().statusCode),
            title: const Text("Status Code"),
            subtitle: Text(response.statusCode.toString()),
          )
        );

        children.add(
          ListTile(
            //title: Text(L10().responseData),
            title: const Text("Response data"),
            subtitle: Text(response.data.toString()),
          )
        );

        break;
    }
  }

  OneContext().showDialog(
    builder: (context) => SimpleDialog(
      title: ListTile(
        title: Text(title),
        leading: FaIcon(icon),
      ),
      children: children
    )
  ).then((value) {
    if (onDismissed != null) {
      onDismissed();
    }
  });
}

Future<void> showServerError(String url, String title, String description) async {

  if (!OneContext.hasContext) {
    return;
  }

  // We ignore error messages for certain URLs
  if (url.contains("notifications")) {
    return;
  }

  if (title.isEmpty) {
    //title = L10().serverError;
    title = "Server Error";
  }

  // Play a sound
  //final bool tones = await InvenTreeSettingsManager().getValue(INV_SOUNDS_SERVER, true) as bool;

  //if (tones) {
  //  playAudioFile("sounds/server_error.mp3");
  //}

  showSnackIcon(
    title,
    success: false,
    //actionText: L10().details,
    actionText: "details",
    onAction: () {
      showErrorDialog(
          //L10().serverError,
          "Server Error",
          description: description,
          icon: FontAwesomeIcons.server
      );
    }
  );
}

Future<void> showStatusCodeError(String url, int status, {String details=""}) async {

  //String msg = statusCodeToString(status);
  //String extra = url + "\n" + "${L10().statusCode}: ${status}";
  String msg = status.toString();
  String extra = url + "\n" + "Status Code: ${status}";

  if (details.isNotEmpty) {
    extra += "\n";
    extra += details;
  }

  showServerError(
    url,
    msg,
    extra,
  );
}
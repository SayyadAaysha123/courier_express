import 'package:courier_customer_app/src/repositories/setting_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:flutter_html/flutter_html.dart';
import '../repositories/user_repository.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class Helper {
  static Uri getUri(String path,
      {bool addApiToken = true, Map<String, dynamic> queryParam = const {}}) {
    Map<String, dynamic> _queryParameters = {};
    if (addApiToken) {
      _queryParameters.addAll({"api_token": currentUser.value.token});
    }
    _queryParameters.addAll(queryParam);

    if (kDebugMode) {
      print(Uri.parse('${GlobalConfiguration().getValue('api_base_url')}$path')
          .replace(queryParameters: _queryParameters));
    }
    return Uri.parse('${GlobalConfiguration().getValue('api_base_url')}$path')
        .replace(queryParameters: _queryParameters);
  }

  static double StringTodouble(String value) {
    return double.parse(value.replaceAll(',', '.'));
  }

  static Html applyHtml(context, String html, {TextStyle? style}) {
    return Html(
      data: html,
      style: {
        "*": Style(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.all(0),
          fontSize: FontSize(12.0),
          display: Display.INLINE_BLOCK,
          width: MediaQuery.of(context).size.width,
        ),
        "h4,h5,h6": Style(
          fontSize: FontSize(18.0),
        ),
        "h1,h2,h3": Style(
          fontSize: FontSize.xLarge,
        ),
        "br": Style(
          height: 0,
        ),
        "p": Style(
          fontSize: FontSize(16.0),
        )
      },
    );
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat.yMd(setting.value.locale.toString())
        .add_jm()
        .format(dateTime);
  }

  static bool isRtl(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }
}

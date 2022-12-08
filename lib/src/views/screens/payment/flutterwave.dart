import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:courier_customer_app/src/repositories/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:courier_customer_app/src/models/order.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../controllers/order_controller.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/helper.dart';
import '../../../helper/images.dart';
import '../../../helper/styles.dart';
import '../../../models/payment_gateway_enum.dart';
import '../../../models/screen_argument.dart';
import '../webview.dart';

class FlutterwavePaymentWidget extends StatefulWidget {
  final Order order;
  const FlutterwavePaymentWidget(this.order, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FlutterwavePaymentWidgetState();
  }
}

class _FlutterwavePaymentWidgetState
    extends StateMVC<FlutterwavePaymentWidget> {
  late OrderController _con;
  Timer? timer;

  _FlutterwavePaymentWidgetState() : super(OrderController()) {
    _con = controller as OrderController;
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  void checkPayment() {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _con.doCheckPaymentStatus(widget.order).then((hasChanged) {
        if (hasChanged) {
          timer.cancel();
          Navigator.pushReplacementNamed(
            context,
            '/Order',
            arguments: ScreenArgument(
              {
                'orderId': widget.order.id,
              },
            ),
          );
        }
      }).catchError((onError) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _con.loadingPreference
          ? () {}
          : () async {
              checkPayment();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewPage(
                    Helper.getUri(
                            'orders/${widget.order.id}/payWithFlutterwave')
                        .toString(),
                    widget.order.id,
                  ),
                ),
              );
            },
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        minimumSize: Size(MediaQuery.of(context).size.width, 50),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: _con.loadingPreference
          ? CircularProgressIndicator(
              color: Theme.of(context).highlightColor,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Images.flutterwave,
                  height: 50,
                ),
                SizedBox(
                  width: 15,
                ),
                AutoSizeText(
                  AppLocalizations.of(context)!.payWith(
                    PaymentGatewayEnumHelper.description(
                      PaymentGatewayEnum.flutterwave,
                      context,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: khulaBold.merge(
                    TextStyle(
                      color: Theme.of(context).highlightColor,
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

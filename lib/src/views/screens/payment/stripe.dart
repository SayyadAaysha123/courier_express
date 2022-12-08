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
import '../../../helper/styles.dart';
import '../../../models/payment_gateway_enum.dart';
import '../../../models/screen_argument.dart';

class StripePaymentWidget extends StatefulWidget {
  final Order order;
  const StripePaymentWidget(this.order, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StripePaymentWidgetState();
  }
}

class _StripePaymentWidgetState extends StateMVC<StripePaymentWidget> {
  late OrderController _con;
  Timer? timer;

  _StripePaymentWidgetState() : super(OrderController()) {
    _con = controller as OrderController;
  }

  @override
  void initState() {
    Stripe.publishableKey = setting.value.stripeKey ?? '';
    _con.doInitializePayment(widget.order);
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  void checkPayment() {
    setState(() => _con.loadingPreference = true);
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _con.doCheckPaymentStatus(widget.order).then((hasChanged) {
        if (hasChanged) {
          setState(() => _con.loadingPreference = false);
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

  Future<void> initPaymentSheet() async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Main params
          paymentIntentClientSecret: _con.preferenceId!['clientSecret'],
          merchantDisplayName: setting.value.appName,

          customerEphemeralKeySecret: null,
          // Extra params
          applePay: PaymentSheetApplePay(
            merchantCountryCode: 'US',
          ),
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'US',
          ),
          style: ThemeMode.dark,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: Theme.of(context).scaffoldBackgroundColor,
              primary: Theme.of(context).primaryColor,
            ),
            shapes: PaymentSheetShape(
              borderWidth: 4,
              shadow: PaymentSheetShadowParams(color: Colors.red),
            ),
          ),
        ),
      );
      await confirmPayment();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  Future<void> confirmPayment() async {
    try {
      // 3. display the payment sheet.
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.paymentCompleted),
        ),
      );
      checkPayment();
    } on Exception catch (e) {
      if (e is StripeException) {
        if (e.error.code == FailureCode.Canceled) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.errorOnPayment}: ${e.error.localizedMessage}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: ${e}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _con.loadingPreference
          ? () {}
          : () async {
              if (_con.preferenceId?['clientSecret'] != null) {
                await initPaymentSheet();
              } else {
                _con.doInitializePayment(widget.order).then((value) async {
                  await initPaymentSheet();
                });
              }
            },
      style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          minimumSize: Size(MediaQuery.of(context).size.width, 50),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )),
      child: _con.loadingPreference
          ? CircularProgressIndicator(
              color: Theme.of(context).highlightColor,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.ccStripe,
                  size: 30,
                  color: Theme.of(context).highlightColor,
                ),
                SizedBox(
                  width: 25,
                ),
                AutoSizeText(
                  AppLocalizations.of(context)!.payWith(
                    PaymentGatewayEnumHelper.description(
                      PaymentGatewayEnum.stripe,
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

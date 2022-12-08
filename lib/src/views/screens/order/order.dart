import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:courier_customer_app/src/models/payment_gateway_enum.dart';
import 'package:courier_customer_app/src/models/screen_argument.dart';
import 'package:courier_customer_app/src/views/screens/payment/flutterwave.dart';
import 'package:courier_customer_app/src/views/screens/payment/mercado_pago.dart';
import 'package:courier_customer_app/src/views/screens/payment/razorpay.dart';
import 'package:courier_customer_app/src/views/screens/payment/stripe.dart';
import 'package:courier_customer_app/src/views/widgets/order_tracking.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../controllers/order_controller.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/styles.dart';
import '../../../models/order.dart';
import '../../../models/status_enum.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/order_address.dart';
import '../../widgets/order_details.dart';
import '../../widgets/order_timeline_status.dart';
import '../payment/paypal.dart';

class OrderScreen extends StatefulWidget {
  final String orderId;
  final bool showButtons;
  const OrderScreen({Key? key, required this.orderId, this.showButtons = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OrderScreenState();
  }
}

class OrderScreenState extends StateMVC<OrderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<OrderTrackingWidgetState> trackingKey =
      GlobalKey<OrderTrackingWidgetState>();
  late OrderController _con;
  int currentTab = 0;
  late FToast fToast;
  Timer? timer;

  OrderScreenState() : super(OrderController()) {
    _con = controller as OrderController;
  }

  @override
  void initState() {
    getOrder();
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  Future<void> getOrder() async {
    if (timer != null) {
      timer!.cancel();
    }
    await _con.doGetOrder(widget.orderId).then((Order _order) {
      if (_order.orderStatus == StatusEnum.accepted ||
          _order.orderStatus == StatusEnum.collected ||
          _order.orderStatus == StatusEnum.delivered) {
        updateCourierLocation();
      }
    }).catchError((_error) {
      fToast.removeCustomToast();
      fToast.showToast(
        child: CustomToast(
          backgroundColor: Colors.red,
          icon: Icon(Icons.close, color: Colors.white),
          text: _error.toString(),
          textColor: Colors.white,
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    });
  }

  void updateCourierLocation() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _con.doUpdateCourierLocation(_con.order!).then((changed) {
        if (changed && trackingKey.currentState != null) {
          trackingKey.currentState!.animateToMarker(manual: false);
        }
      }).catchError((onError) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: RichText(
          text: _con.order != null
              ? TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${AppLocalizations.of(context)!.order} #${_con.order!.id} - ',
                      style: khulaSemiBold.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    TextSpan(
                      text: StatusEnumHelper.description(
                          _con.order!.orderStatus, context),
                      style: khulaBold.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          color: Theme.of(context).colorScheme.primary),
                    )
                  ],
                )
              : const TextSpan(),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/RecentOrders');
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      bottomNavigationBar: _con.order != null &&
              _con.order!.orderStatus == StatusEnum.waiting
          ? Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(color: Colors.black54, blurRadius: 10)
              ]),
              child: BottomAppBar(
                child: Container(
                  height: 65,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          children: [
                            if (_con.order!.paymentGateway ==
                                PaymentGatewayEnum.stripe)
                              StripePaymentWidget(_con.order!)
                            else if (_con.order!.paymentGateway ==
                                PaymentGatewayEnum.mercado_pago)
                              MercadoPagoPaymentWidget(_con.order!)
                            else if (_con.order!.paymentGateway ==
                                PaymentGatewayEnum.paypal)
                              PaypalPaymentWidget(_con.order!)
                            else if (_con.order!.paymentGateway ==
                                PaymentGatewayEnum.flutterwave)
                              FlutterwavePaymentWidget(_con.order!)
                            else if (_con.order!.paymentGateway ==
                                PaymentGatewayEnum.razorpay)
                              RazorpayPaymentWidget(_con.order!)
                          ],
                        )),
                  ),
                ),
              ),
            )
          : _con.order != null &&
                      _con.order?.orderStatus == StatusEnum.accepted ||
                  _con.order?.orderStatus == StatusEnum.collected ||
                  _con.order?.orderStatus == StatusEnum.delivered
              ? Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(color: Colors.black54, blurRadius: 10)
                  ]),
                  child: BottomAppBar(
                    child: Container(
                      height: 65,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                    '/Chat',
                                    arguments: ScreenArgument(
                                        {'orderId': widget.orderId}),
                                  );
                                },
                                style: TextButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width, 50),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.solidMessage,
                                      size: 30,
                                      color: Theme.of(context).highlightColor,
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    AutoSizeText(
                                      AppLocalizations.of(context)!
                                          .chatWithCourier,
                                      textAlign: TextAlign.center,
                                      style: khulaBold.merge(
                                        TextStyle(
                                          color:
                                              Theme.of(context).highlightColor,
                                          fontSize: Dimensions.FONT_SIZE_LARGE,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
      body: _con.loading
          ? const Center(child: CircularProgressIndicator())
          : _con.order == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.orderNotFound,
                      style: khulaBold.copyWith(
                          fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: Dimensions.PADDING_SIZE_LARGE,
                        left: Dimensions.PADDING_SIZE_LARGE,
                        right: Dimensions.PADDING_SIZE_LARGE,
                      ),
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        onPressed: () async {
                          getOrder();
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: Theme.of(context).highlightColor,
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.tryAgain,
                          style: poppinsSemiBold.copyWith(
                              color: Theme.of(context).highlightColor,
                              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: <Widget>[
                    DefaultTabController(
                      initialIndex: currentTab,
                      length: 3,
                      child: Expanded(
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.4),
                                    blurRadius: 5,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                              child: TabBar(
                                onTap: (int tabIndex) {
                                  currentTab = tabIndex;
                                },
                                indicatorColor: Theme.of(context).primaryColor,
                                labelColor: Theme.of(context).primaryColor,
                                tabs: [
                                  SizedBox(
                                    height: 60,
                                    child: Tab(
                                      icon: const Icon(
                                          FontAwesomeIcons.circleInfo,
                                          size: 20),
                                      iconMargin:
                                          const EdgeInsets.only(bottom: 5),
                                      text:
                                          AppLocalizations.of(context)!.details,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 60,
                                    child: Tab(
                                      icon: const Icon(
                                          FontAwesomeIcons.addressCard,
                                          size: 20),
                                      iconMargin:
                                          const EdgeInsets.only(bottom: 5),
                                      text: AppLocalizations.of(context)!
                                          .addresses,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 60,
                                    child: Tab(
                                      icon: const Icon(
                                          FontAwesomeIcons.listCheck,
                                          size: 20),
                                      iconMargin:
                                          const EdgeInsets.only(bottom: 5),
                                      text: AppLocalizations.of(context)!
                                          .orderStatus,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  OrderDetailsWidget(order: _con.order!),
                                  Column(
                                    children: [
                                      (_con.order!.orderStatus ==
                                                  StatusEnum.accepted ||
                                              _con.order!.orderStatus ==
                                                  StatusEnum.collected ||
                                              _con.order!.orderStatus ==
                                                  StatusEnum.delivered)
                                          ? Container(
                                              height: 300,
                                              child: OrderTrackingWidget(
                                                  key: trackingKey,
                                                  order: _con.order!),
                                            )
                                          : SizedBox(
                                              height: 0,
                                            ),
                                      Expanded(
                                        child: OrderAddressWidget(
                                            order: _con.order!),
                                      ),
                                    ],
                                  ),
                                  OrderTimelineStatusWidget(order: _con.order!),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

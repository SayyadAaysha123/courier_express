import 'dart:collection';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:courier_customer_app/src/repositories/user_repository.dart';
import 'package:courier_customer_app/src/views/widgets/courier_list.dart';
import 'package:courier_customer_app/src/views/widgets/payment_method_list.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../helper/dimensions.dart';
import '../../../helper/styles.dart';
import '../../../models/screen_argument.dart';
import '../../../models/create_order_address.dart';
import '../../../models/nearby_courier.dart';
import '../../../controllers/order_controller.dart';
import '../../../models/selected_payment_method.dart';
import '../../../repositories/setting_repository.dart';
import '../../widgets/categories_list.dart';
import '../../widgets/custom_location_picker.dart';
import '../../widgets/menu.dart';
import '../../../views/widgets/custom_text_form_field.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddOrderState();
  }
}

class _AddOrderState extends StateMVC<AddOrderScreen> {
  late OrderController _con;
  final _formKey = GlobalKey<FormState>();
  CreateOrderAddress? pickup;
  final delivery = SplayTreeMap<int, CreateOrderAddress>();
  List<Widget> widgets = [];
  int key = 0;
  String? observation;
  SelectedPaymentMethod? selectedPaymentMethod;
  bool returnRequired = false;

  _AddOrderState() : super(OrderController()) {
    _con = controller as OrderController;
  }

  List<Widget> buildLocationPickerFields() {
    widgets = [];
    for (var i = 0; i <= key; i++) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: Dimensions.PADDING_SIZE_DEFAULT),
          child: Row(
            children: [
              Expanded(
                child: CustomLocationPickerWidget(
                  onTap: () {
                    if (!currentUser.value.auth) {
                      Navigator.of(context).pushNamed(
                        '/Login',
                      );
                    }
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return null;
                    }
                    return AppLocalizations.of(context)!.selectAnAddress;
                  },
                  labelText: AppLocalizations.of(context)!.deliveryLocation,
                  onSuggestionSelected: (selected) async {
                    setState(() {
                      delivery[i] = CreateOrderAddress(selected);
                    });
                    if (pickup != null && _con.selectedCourier != null) {
                      await _con.doSimulate(pickup!, delivery.values.toList(),
                          _con.selectedCourier!, returnRequired);
                    }
                  },
                ),
              ),
              if (i > 0)
                IconButton(
                  onPressed: () async {
                    if (pickup != null &&
                        delivery[i] != null &&
                        _con.selectedCourier != null) {
                      setState(() {
                        key--;
                        widgets.remove(i);
                        delivery.remove(i);
                      });
                      await _con.doSimulate(pickup!, delivery.values.toList(),
                          _con.selectedCourier!, returnRequired);
                    } else {
                      setState(() {
                        key--;
                        widgets.remove(i);
                        delivery.remove(i);
                      });
                    }
                  },
                  icon: Icon(
                    Icons.remove_circle,
                    size: 35,
                    color: Colors.red,
                  ),
                )
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  void initState() {
    _con.doLoadCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: LoaderOverlay(
        useDefaultLoading: false,
        overlayWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 50),
              Text(
                AppLocalizations.of(context)!.sendingOrder,
                style: kTitleStyle.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
          ),
        ),
        overlayOpacity: 0.85,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
              setting.value.appName,
              style: kTitleStyle.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
              maxLines: 2,
            ),
            elevation: 1,
            shadowColor: Theme.of(context).primaryColor,
          ),
          drawer: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Drawer(
              child: MenuWidget(),
            ),
          ),
          bottomNavigationBar: _con.selectedCourier == null ||
                  _con.simulation == null
              ? SizedBox()
              : ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                  ),
                  child: BottomAppBar(
                    child: Container(
                      height: ((_con.simulation != null || _con.simulating)
                              ? 80
                              : 0) +
                          (_con.selectedCourier != null &&
                                  delivery.isNotEmpty &&
                                  selectedPaymentMethod != null
                              ? 60
                              : 0),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_con.simulating)
                            CircularProgressIndicator()
                          else if (_con.simulation != null)
                            Column(
                              children: [
                                SizedBox(
                                  height: Dimensions.PADDING_SIZE_SMALL,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                              0.5 -
                                          10,
                                      child: Text(
                                        AppLocalizations.of(context)!.distance,
                                        style: kTitleStyle.copyWith(
                                            height: 1.2,
                                            fontSize: Dimensions
                                                .FONT_SIZE_EXTRA_LARGE_2),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                              0.5 -
                                          10,
                                      child: Text(
                                        _con.simulation!.distance,
                                        style: kSubtitleStyle.copyWith(
                                          fontSize:
                                              Dimensions.FONT_SIZE_EXTRA_LARGE,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Theme.of(context).hintColor,
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                              0.5 -
                                          10,
                                      child: Text(
                                        AppLocalizations.of(context)!.total,
                                        style: kTitleStyle.copyWith(
                                            height: 1.2,
                                            fontSize: Dimensions
                                                .FONT_SIZE_EXTRA_LARGE_2),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                              0.5 -
                                          10,
                                      child: Text(
                                          '${NumberFormat.simpleCurrency(name: setting.value.currency).currencySymbol} ${_con.simulation!.originalPrice.toStringAsFixed(2)}',
                                          style: kSubtitleStyle.copyWith(
                                              fontSize: Dimensions
                                                  .FONT_SIZE_EXTRA_LARGE)),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          if (_con.selectedCourier != null &&
                              delivery.isNotEmpty &&
                              selectedPaymentMethod != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    context.loaderOverlay.show();
                                    await _con
                                        .doSubmit(
                                            pickup!,
                                            delivery.values.toList(),
                                            _con.selectedCourier!,
                                            selectedPaymentMethod!,
                                            observation,
                                            returnRequired)
                                        .then((id) {
                                      Navigator.pushReplacementNamed(
                                          context, '/Order',
                                          arguments: ScreenArgument({
                                            'orderId': id,
                                          }));
                                    }).catchError((onError) {});
                                    context.loaderOverlay.hide();
                                  }
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
                                child: AutoSizeText(
                                  AppLocalizations.of(context)!.sendOrder,
                                  textAlign: TextAlign.center,
                                  style: khulaBold.merge(
                                    TextStyle(
                                      color: Theme.of(context).highlightColor,
                                      fontSize: Dimensions.FONT_SIZE_LARGE,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
          body: Stack(
            children: <Widget>[
              if (setting.value.backgroundImage != null)
                Positioned(
                  bottom: 0,
                  child: CachedNetworkImage(
                    imageUrl: setting.value.backgroundImage!,
                    width: MediaQuery.of(context).size.width,
                    errorWidget: (context, value, two) {
                      return Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      );
                    },
                  ),
                ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView(
                    children: [
                      SizedBox(height: 30),
                      if (setting.value.headerText != null ||
                          setting.value.subHeaderText != null)
                        Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            if (setting.value.headerText != null)
                              AutoSizeText(
                                setting.value.headerText!,
                                style: kTitleStyle.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
                                textAlign: TextAlign.center,
                              ),
                            if (setting.value.headerText != null &&
                                setting.value.subHeaderText != null)
                              SizedBox(height: 10),
                            if (setting.value.subHeaderText != null)
                              AutoSizeText(
                                setting.value.subHeaderText!,
                                style: kSubtitleStyle.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
                                textAlign: TextAlign.center,
                              ),
                            SizedBox(height: 10),
                          ],
                        ),
                      _con.loadingCategories
                          ? Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 30),
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).highlightColor,
                                ),
                              ),
                            )
                          : _con.categories.isEmpty
                              ? SizedBox()
                              : CategoriesListWidget(_con.categories),
                      SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                      CustomLocationPickerWidget(
                        onTap: () {
                          if (!currentUser.value.auth) {
                            Navigator.of(context).pushNamed(
                              '/Login',
                            );
                          }
                        },
                        labelText: AppLocalizations.of(context)!.pickupLocation,
                        onSuggestionSelected: (selected) async {
                          setState(() {
                            pickup = CreateOrderAddress(selected);
                          });
                          await _con.doFindNearBy(pickup!);
                          if (delivery.isNotEmpty) {
                            await _con.doSimulate(
                                pickup!,
                                delivery.values.toList(),
                                _con.selectedCourier!,
                                returnRequired);
                          }
                        },
                        controller: TextEditingController()
                          ..text = (pickup?.address.formattedAddress ?? ''),
                      ),
                      Column(
                        children: buildLocationPickerFields(),
                      ),
                      SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              key++;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.add_location,
                          color: Theme.of(context).highlightColor,
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                        label: Text(
                          AppLocalizations.of(context)!.addDeliveryLocation,
                          style: khulaBold.copyWith(
                            color: Theme.of(context).highlightColor,
                          ),
                        ),
                      ),
                      ListTile(
                        horizontalTitleGap: 0,
                        title: Row(
                          children: [
                            FlutterSwitch(
                              activeColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.75),
                              inactiveColor: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(.25),
                              showOnOff: true,
                              activeText: AppLocalizations.of(context)!.yes,
                              inactiveText: AppLocalizations.of(context)!.no,
                              valueFontSize: 18,
                              toggleColor:
                                  Theme.of(context).colorScheme.secondary,
                              value: returnRequired,
                              activeTextColor: Theme.of(context).highlightColor,
                              inactiveTextColor:
                                  Theme.of(context).colorScheme.secondary,
                              activeToggleColor:
                                  Theme.of(context).highlightColor,
                              width: 80,
                              height: 35,
                              borderRadius: 30,
                              switchBorder: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              toggleBorder: Border.all(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(.8),
                                width: 1,
                              ),
                              onToggle: (isActive) async {
                                setState(() {
                                  returnRequired = isActive;
                                });
                                if (_con.selectedCourier != null &&
                                    delivery.isNotEmpty) {
                                  await _con.doSimulate(
                                      pickup!,
                                      delivery.values.toList(),
                                      _con.selectedCourier!,
                                      returnRequired);
                                }
                              },
                            ),
                            SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .returnPickupLocationRequired,
                                style: rubikBold.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_LARGE,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_con.couriers.isNotEmpty)
                        CourierListWidget(
                          _con.selectedCourier,
                          _con.couriers,
                          (NearbyCourier selected) async {
                            setState(() {
                              _con.selectedCourier = selected;
                            });
                            if (delivery.isNotEmpty) {
                              await _con.doSimulate(
                                  pickup!,
                                  delivery.values.toList(),
                                  _con.selectedCourier!,
                                  returnRequired);
                            }
                          },
                        )
                      else if (pickup != null &&
                          delivery.isNotEmpty &&
                          !_con.simulating)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.PADDING_SIZE_DEFAULT),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .sorryNoCourierNearby,
                              style: kSubtitleStyle.copyWith(
                                  color: Colors.red[800]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      if (_con.selectedCourier != null && delivery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.PADDING_SIZE_DEFAULT),
                          child: CustomTextFormField(
                            labelText: AppLocalizations.of(context)!
                                .observationForCourier,
                            hintText: AppLocalizations.of(context)!
                                .ifNeededInputObservationCourier,
                            inputType: TextInputType.text,
                            inputAction: TextInputAction.done,
                            onSave: (String value) {
                              observation = value;
                            },
                            color: Theme.of(context).cardColor,
                            maxLines: 3,
                          ),
                        ),
                      if (_con.selectedCourier != null && delivery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.PADDING_SIZE_DEFAULT),
                          child: Card(
                            margin: EdgeInsets.zero,
                            elevation: 8,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Colors.grey[350]!,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: Dimensions.PADDING_SIZE_DEFAULT,
                                      bottom:
                                          Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .selectPaymentMethod,
                                      style: kSubtitleStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                if (_con.selectedCourier != null &&
                                    delivery.isNotEmpty)
                                  PaymentMethodListWidget(selectedPaymentMethod,
                                      (SelectedPaymentMethod? paymentMethod) {
                                    setState(() {
                                      if (paymentMethod != null &&
                                          selectedPaymentMethod != null &&
                                          selectedPaymentMethod!.id ==
                                              paymentMethod.id) {
                                        selectedPaymentMethod = null;
                                      } else {
                                        selectedPaymentMethod = paymentMethod;
                                      }
                                    });
                                  }),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(
                        height: Dimensions.PADDING_SIZE_SMALL,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

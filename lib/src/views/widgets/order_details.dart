import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../../models/measure_unit_enum.dart';
import '../../models/order.dart';
import '../../models/payment_gateway_enum.dart';
import '../../models/status_enum.dart';
import '../../repositories/setting_repository.dart';

class OrderDetailsWidget extends StatefulWidget {
  final Order order;

  OrderDetailsWidget({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderDetailsWidget> createState() => _OrderDetailsWidgetState();
}

class _OrderDetailsWidgetState extends State<OrderDetailsWidget> {
  bool transferindoLoading = false;

  Widget generateDecoration(Widget conteudo) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            blurRadius: 5,
          )
        ],
        borderRadius: BorderRadius.circular(5),
      ),
      child: conteudo,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        SizedBox(height: 20),
        generateDecoration(
          ListTile(
            title: Text(
              '${AppLocalizations.of(context)!.orderStatus}:',
              style: khulaBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  color: Theme.of(context).colorScheme.primary),
            ),
            trailing: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5,
              ),
              child: AutoSizeText(
                StatusEnumHelper.description(widget.order.orderStatus, context),
                minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                style: khulaRegular.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
        generateDecoration(
          Column(
            children: [
              ListTile(
                title: Text(
                  '${AppLocalizations.of(context)!.totalAmount}:',
                  style: khulaBold.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                      color: Color.fromARGB(255, 246, 61, 61)),
                ),
                trailing: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                  ),
                  child: AutoSizeText(
                    '${NumberFormat.simpleCurrency(name: setting.value.currency).currencySymbol} ${widget.order.amount.toStringAsFixed(2)}',
                    minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                    style: khulaRegular.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 246, 61, 61)),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.order.paymentStatus != null ||
            widget.order.paymentGateway != null ||
            widget.order.offlinePaymentMethod != null)
          generateDecoration(
            Column(
              children: [
                if (widget.order.paymentGateway != null ||
                    widget.order.offlinePaymentMethod != null)
                  ListTile(
                    title: Text(
                      '${AppLocalizations.of(context)!.paymentMethod}:',
                      style: khulaBold.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    trailing: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.5,
                      ),
                      child: AutoSizeText(
                        widget.order.paymentGateway != null
                            ? PaymentGatewayEnumHelper.description(
                                widget.order.paymentGateway!,
                                context,
                              )
                            : widget.order.offlinePaymentMethod!.name,
                        minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                        style: khulaRegular.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                if (widget.order.paymentStatus != null)
                  ListTile(
                    title: Text(
                      '${AppLocalizations.of(context)!.paymentStatus}:',
                      style: khulaBold.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    trailing: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.5,
                      ),
                      child: AutoSizeText(
                        StatusEnumHelper.description(
                            widget.order.paymentStatus!, context),
                        minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                        style: khulaRegular.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        generateDecoration(
          ListTile(
            title: Text(
              '${AppLocalizations.of(context)!.estimatedDistance}:',
              style: khulaBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  color: Theme.of(context).colorScheme.primary),
            ),
            trailing: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5,
              ),
              child: AutoSizeText(
                '${widget.order.distance.toStringAsFixed(1)} ${MeasureUnitEnumHelper.abbreviation(setting.value.measureUnit, context)}',
                minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                style: khulaRegular.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
        generateDecoration(
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.FONT_SIZE_DEFAULT + 1,
              vertical: Dimensions.FONT_SIZE_EXTRA_SMALL / 2,
            ),
            title: Text(
              '${AppLocalizations.of(context)!.courier}:',
              style: khulaBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  color: Theme.of(context).colorScheme.primary),
            ),
            trailing: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    '${widget.order.courier!.user!.name}',
                    minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: khulaRegular.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  AutoSizeText(
                    widget.order.courier!.user!.phone,
                    minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: khulaRegular.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.order.observation != null)
          generateDecoration(
            ListTile(
              title: Text(
                '${AppLocalizations.of(context)!.note}:',
                style: khulaBold.copyWith(
                    fontSize: Dimensions.FONT_SIZE_LARGE,
                    color: Theme.of(context).colorScheme.primary),
              ),
              trailing: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                child: AutoSizeText(
                  widget.order.observation!,
                  minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                  style: khulaRegular.copyWith(
                    fontSize: Dimensions.FONT_SIZE_LARGE,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        generateDecoration(
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.FONT_SIZE_DEFAULT + 1,
              vertical: Dimensions.FONT_SIZE_EXTRA_SMALL / 2,
            ),
            title: Text(
              '${AppLocalizations.of(context)!.returnCollectionLocation}:',
              style: khulaBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  color: Theme.of(context).colorScheme.primary),
            ),
            trailing: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5,
              ),
              child: AutoSizeText(
                widget.order.returnRequired
                    ? AppLocalizations.of(context)!.yes
                    : AppLocalizations.of(context)!.no,
                minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                style: khulaRegular.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

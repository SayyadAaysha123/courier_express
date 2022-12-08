import 'package:courier_customer_app/src/helper/styles.dart';
import 'package:courier_customer_app/src/models/status_enum.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../models/order.dart';

class OrderTimelineStatusWidget extends StatelessWidget {
  final Order order;

  const OrderTimelineStatusWidget({Key? key, required this.order})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 15, top: 25),
            child: Text(
              DateFormat.yMd(Localizations.localeOf(context).languageCode)
                  .format(order.createdAt!),
              style: khulaRegular.copyWith(
                fontSize: 18,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildTimelineTile(
            context,
            indicator: const _IconIndicator(
              iconData: Icons.library_add_check_outlined,
              size: 35,
            ),
            heigth: 50,
            width: 50,
            isFirst: true,
            time: DateFormat.Hm(Localizations.localeOf(context).languageCode)
                .format(order.createdAt!),
            title: AppLocalizations.of(context)!.orderCreated,
          ),
          if (order.orderStatus == StatusEnum.cancelled ||
              order.orderStatus == StatusEnum.rejected ||
              order.orderStatus == StatusEnum.pending)
            _buildTimelineTile(
              context,
              indicator: _IconIndicator(
                iconData: order.orderStatus == StatusEnum.cancelled ||
                        order.orderStatus == StatusEnum.rejected
                    ? Icons.cancel_rounded
                    : FontAwesomeIcons.userClock,
                size: 20,
                color: order.orderStatus == StatusEnum.cancelled ||
                        order.orderStatus == StatusEnum.rejected
                    ? Colors.red
                    : Colors.grey,
                iconColor: Colors.white,
              ),
              isLast: true,
              time: DateFormat.Hm(Localizations.localeOf(context).languageCode)
                  .format(order.orderStatusDate!),
              title: StatusEnumHelper.description(order.orderStatus!, context),
            )
          else if (order.orderStatus == StatusEnum.accepted)
            Column(
              children: [
                _buildTimelineTile(
                  context,
                  indicator: _IconIndicator(
                    iconData: Icons.check_circle,
                    size: 20,
                    color: Colors.green,
                    iconColor: Colors.white,
                  ),
                  time: DateFormat.Hm(
                          Localizations.localeOf(context).languageCode)
                      .format(order.orderStatusDate!),
                  title:
                      StatusEnumHelper.description(order.orderStatus!, context),
                ),
                _buildTimelineTile(
                  context,
                  indicator: const _IconIndicator(
                    iconData: FontAwesomeIcons.userClock,
                    color: Colors.grey,
                    iconColor: Colors.white,
                    size: 20,
                  ),
                  isLast: true,
                  title: AppLocalizations.of(context)!
                      .awaitingSomething(AppLocalizations.of(context)!.collect),
                  subtitle: order.pickupLocation?.name ?? '',
                ),
              ],
            )
          else
            Column(
              children: [
                if (order.orderStatus == StatusEnum.collected)
                  _buildTimelineTile(
                    context,
                    indicator: _IconIndicator(
                      iconData: Icons.check_circle,
                      size: 20,
                      color: Colors.green,
                      iconColor: Colors.white,
                    ),
                    time: DateFormat.Hm(
                            Localizations.localeOf(context).languageCode)
                        .format(order.orderStatusDate!),
                    title: StatusEnumHelper.description(
                        order.orderStatus!, context),
                    subtitle: order.pickupLocation?.name ?? '',
                  ),
                for (var address in order.deliveryLocation
                    .where((element) => element.delivered == true))
                  _buildTimelineTile(
                    context,
                    indicator: _IconIndicator(
                      iconData: Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      iconColor: Colors.white,
                      size: 20,
                    ),
                    time: address.deliveredDate == null
                        ? ''
                        : DateFormat.Hm(
                                Localizations.localeOf(context).languageCode)
                            .format(address.deliveredDate!),
                    title: AppLocalizations.of(context)!.delivered,
                    subtitle: address.name,
                  ),
                for (var x = 0;
                    x <
                        order.deliveryLocation
                            .where((element) => element.delivered == false)
                            .length;
                    x++)
                  _buildTimelineTile(
                    context,
                    indicator: const _IconIndicator(
                      iconData: FontAwesomeIcons.userClock,
                      color: Colors.grey,
                      iconColor: Colors.white,
                      size: 20,
                    ),
                    title: AppLocalizations.of(context)!.awaitingSomething(
                        AppLocalizations.of(context)!.delivery),
                    isLast: x + 1 ==
                        order.deliveryLocation
                            .where((element) => element.delivered == false)
                            .length,
                    subtitle: order.deliveryLocation
                        .where((element) => element.delivered == false)
                        .elementAt(x)
                        .name,
                  ),
                if (order.orderStatus == StatusEnum.delivered)
                  _buildTimelineTile(
                    context,
                    indicator: const _IconIndicator(
                      iconData: FontAwesomeIcons.userClock,
                      color: Colors.grey,
                      iconColor: Colors.white,
                      size: 20,
                    ),
                    isLast: true,
                    title: AppLocalizations.of(context)!.returnn,
                    subtitle: order.pickupLocation?.name ?? '',
                  )
                else if (order.orderStatus == StatusEnum.completed)
                  _buildTimelineTile(
                    context,
                    indicator: _IconIndicator(
                      iconData: Icons.check_circle,
                      color: Colors.green,
                      iconColor: Colors.white,
                      size: 30,
                    ),
                    heigth: 50,
                    width: 50,
                    isLast: true,
                    time: DateFormat.Hm(
                            Localizations.localeOf(context).languageCode)
                        .format(order.orderStatusDate!),
                    title: StatusEnumHelper.description(
                        order.orderStatus!, context),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  TimelineTile _buildTimelineTile(
    context, {
    _IconIndicator? indicator,
    String time = '',
    String title = '',
    String subtitle = '',
    String phrase = '',
    bool isFirst = false,
    bool isLast = false,
    double heigth = 40,
    double width = 40,
  }) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.3,
      beforeLineStyle:
          LineStyle(color: Theme.of(context).primaryColor.withOpacity(0.7)),
      indicatorStyle: IndicatorStyle(
        indicatorXY: 0.3,
        drawGap: true,
        width: width,
        height: heigth,
        indicator: indicator,
      ),
      isLast: isLast,
      isFirst: isFirst,
      startChild: Center(
        child: Container(
          alignment: const Alignment(0.0, -0.50),
          child: Text(
            time,
            style: khulaRegular.copyWith(
              fontSize: 18,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      endChild: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 10, top: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: khulaBold.copyWith(
                fontSize: 18,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: khulaSemiBold.copyWith(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              phrase,
              style: khulaRegular.copyWith(
                fontSize: 14,
                color: Theme.of(context).primaryColor.withOpacity(0.9),
                fontWeight: FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _IconIndicator extends StatelessWidget {
  const _IconIndicator(
      {Key? key,
      required this.iconData,
      required this.size,
      this.color,
      this.iconColor})
      : super(key: key);

  final IconData iconData;
  final double size;
  final Color? color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color ?? Theme.of(context).primaryColor.withOpacity(0.7),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: size,
              width: size,
              child: Icon(
                iconData,
                size: size,
                color: iconColor ?? Theme.of(context).backgroundColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

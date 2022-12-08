import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../controllers/order_controller.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/styles.dart';
import '../../widgets/empty_orders.dart';
import '../../widgets/menu.dart';
import '../../widgets/order_item.dart';

class RecentOrdersScreen extends StatefulWidget {
  const RecentOrdersScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RecentOrdersScreenState();
  }
}

class RecentOrdersScreenState extends StateMVC<RecentOrdersScreen> {
  bool loading = false;
  bool loadingSummarizedBalance = false;
  late OrderController _con;
  final ScrollController _controller = ScrollController();
  static const int pageSize = 25;
  late FToast fToast;

  RecentOrdersScreenState() : super(OrderController()) {
    _con = controller as OrderController;
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    refresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> refresh() async {
    setState(() {
      _con.orders.clear();
      loading = true;
    });
    await _con.doGetOrders(pageSize: pageSize);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Courier",
          style: khulaSemiBold.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/NewOrder',
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          FontAwesomeIcons.plus,
          color: Theme.of(context).highlightColor,
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              controller: _controller,
              children: [
                if (!loading && _con.orders.isEmpty)
                  EmptyOrdersWidget()
                else
                  ListView.builder(
                      padding: EdgeInsets.only(top: 20),
                      itemCount: _con.orders.length,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: Dimensions.PADDING_SIZE_DEFAULT),
                          child: OrderItemWidget(
                              order: _con.orders.elementAt(index),
                              expanded: index == 0,
                              loadPedidos: () {
                                refresh();
                              }),
                        );
                      }),
                if (loading)
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    height: _con.orders.isNotEmpty ? 50 : 500,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: _con.orders.isNotEmpty ? 40 : 50,
                          height: _con.orders.isNotEmpty ? 40 : 50,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (_con.orders.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Text(
                              AppLocalizations.of(context)!.searchingOrders,
                              style: khulaBold.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (!loading && _con.hasMoreOrders)
                  Container(
                    margin: const EdgeInsets.only(
                      left: 0,
                      right: 0,
                      bottom: Dimensions.PADDING_SIZE_LARGE,
                      top: Dimensions.PADDING_SIZE_LARGE,
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
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                      ),
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_controller.hasClients) {
                            _controller.animateTo(
                              _controller.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeInOut,
                            );
                          }
                        });
                        await _con.doGetOrders(pageSize: pageSize);
                        setState(() {
                          loading = false;
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.loadMore,
                        style: poppinsSemiBold.copyWith(
                            color: Theme.of(context).highlightColor,
                            fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
                      ),
                    ),
                  ),
              ]),
        ),
      ),
    );
  }
}

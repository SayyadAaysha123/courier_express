import 'package:courier_customer_app/src/models/category.dart';
import 'package:courier_customer_app/src/models/nearby_courier.dart';
import 'package:courier_customer_app/src/models/order_simulation.dart';
import 'package:courier_customer_app/src/models/status_enum.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helper/custom_trace.dart';
import '../models/create_order_address.dart';
import '../models/order.dart';
import '../models/selected_payment_method.dart';
import '../services/order_service.dart';

class OrderController extends ControllerMVC {
  List<NearbyCourier> couriers = [];
  NearbyCourier? selectedCourier;
  OrderSimulation? simulation;
  bool loadingCategories = false;
  bool simulating = false;
  bool submiting = false;
  bool loading = false;
  bool hasMoreOrders = false;
  List<Order> orders = [];
  List<Category> categories = [];
  Order? order;
  bool loadingPreference = false;
  Map<String, dynamic>? preferenceId;

  Future<void> doFindNearBy(CreateOrderAddress location) async {
    await findNearBy(location).then((List<NearbyCourier> _couriers) async {
      setState(() {
        simulation = null;
        if (_couriers.isNotEmpty) {
          selectedCourier = _couriers.first;
        } else {
          selectedCourier = null;
        }
        couriers = _couriers;
      });
    }).catchError((error) async {
      throw error;
    });
  }

  Future<void> doSimulate(
      CreateOrderAddress pickup,
      List<CreateOrderAddress> delivery,
      NearbyCourier courier,
      bool returnRequired) async {
    setState(() => simulating = true);
    await simulate(pickup, delivery, courier, returnRequired)
        .then((OrderSimulation _simulation) async {
      setState(() {
        simulation = _simulation;
        simulating = false;
      });
    }).catchError((error) async {
      setState(() => simulating = false);
      throw error;
    });
  }

  Future<String> doSubmit(
      CreateOrderAddress pickup,
      List<CreateOrderAddress> delivery,
      NearbyCourier courier,
      SelectedPaymentMethod paymentMethod,
      String? observation,
      bool returnRequired) async {
    setState(() => submiting = true);
    String _orderId = await submit(pickup, delivery, courier, paymentMethod,
            observation, returnRequired)
        .catchError((error) async {
      setState(() => submiting = false);
      throw error;
    });
    setState(() {
      submiting = false;
    });
    return _orderId;
  }

  Future<List<Order>> doGetOrders(
      {int? pageSize, DateTime? dateTimeStart, DateTime? dateTimeEnd}) async {
    setState(() => loading = true);
    Map<String, dynamic> response = await getOrders(
      pageSize: pageSize,
      currentItem: orders.length,
      dateTimeStart: dateTimeStart,
      dateTimeEnd: dateTimeEnd,
    ).catchError((error) {
      print(CustomTrace(StackTrace.current, message: error.toString()));
      throw error;
    }).whenComplete(() => setState(() => loading = false));
    List<Order> _orders = response['orders'];
    setState(() {
      hasMoreOrders = response['hasMoreOrders'];
      if (pageSize == null) {
        orders = _orders;
      } else {
        orders.addAll(_orders);
      }
      loading = false;
    });
    return _orders;
  }

  Future<Order> doGetOrder(String orderId) async {
    setState(() {
      loading = true;
      order = null;
    });
    Order _order = await getOrder(orderId).catchError((error) {
      print(CustomTrace(StackTrace.current, message: error.toString()));
      throw error;
    }).whenComplete(() => setState(() => loading = false));
    setState(() {
      order = _order;
      loading = false;
    });
    return _order;
  }

  Future<void> doLoadCategories() async {
    setState(() {
      loadingCategories = true;
    });
    await loadCategories().then((_categories) {
      setState(() {
        categories = _categories;
        loadingCategories = false;
      });
    }).catchError((error) {
      setState(() => loadingCategories = false);
      print(CustomTrace(StackTrace.current, message: error.toString()));
      throw error;
    });
  }

  Future<void> doInitializePayment(Order order) async {
    setState(() {
      loadingPreference = true;
      preferenceId = null;
    });
    await initializePayment(order)
        .then((Map<String, dynamic> _preferenceId) async {
      setState(() {
        loadingPreference = false;
        preferenceId = _preferenceId;
      });
    }).catchError((error) async {
      setState(() => loadingPreference = false);
      throw error;
    });
  }

  Future<bool> doCheckPaymentStatus(Order order) async {
    StatusEnum? status = await checkPaymentStatus(order).catchError((error) {
      print(CustomTrace(StackTrace.current, message: error.toString()));
      throw error;
    });
    if (status != null && status != order.paymentStatus) {
      return true;
    }
    return false;
  }

  Future<bool> doUpdateCourierLocation(Order _order) async {
    LatLng loc = await updateCourierLocation(_order).catchError((error) {
      print(CustomTrace(StackTrace.current, message: error.toString()));
      throw error;
    });
    if (order?.courier != null) {
      if (order!.courier!.lat != loc.latitude ||
          order!.courier!.lng != loc.longitude) {
        setState(() {
          order!.courier!.lat = loc.latitude;
          order!.courier!.lng = loc.longitude;
        });
        return true;
      }
    }
    return false;
  }
}

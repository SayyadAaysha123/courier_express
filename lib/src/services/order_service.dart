import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:courier_customer_app/src/models/category.dart';
import 'package:courier_customer_app/src/models/status_enum.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../helper/custom_trace.dart';
import '../helper/helper.dart';
import '../models/create_order_address.dart';
import '../models/nearby_courier.dart';
import '../models/order.dart';
import '../models/order_simulation.dart';
import '../models/selected_payment_method.dart';

Future<List<NearbyCourier>> findNearBy(CreateOrderAddress location) async {
  final collectJson;
  Map<String, dynamic> dataCollect = {};
  dataCollect['geometry'] = {};
  dataCollect['geometry']['location'] = {};
  dataCollect['geometry']['location']['lat'] =
      location.address.geometry?.location?.lat ?? 0;
  dataCollect['geometry']['location']['lng'] =
      location.address.geometry?.location?.lng ?? 0;
  collectJson = jsonEncode(dataCollect);

  var response = await http
      .post(Helper.getUri('driver/findNearBy'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "collect_address_data": collectJson,
          }))
      .timeout(const Duration(seconds: 15));
  print('response ${response.body}');
  if (response.statusCode == HttpStatus.ok) {
    return jsonDecode(response.body)['data']
        .map((courier) => NearbyCourier.fromJSON(courier))
        .toList()
        .cast<NearbyCourier>();
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<OrderSimulation> simulate(
    CreateOrderAddress pickup,
    List<CreateOrderAddress> delivery,
    NearbyCourier courier,
    bool returnRequired) async {
  final deliveryJson = {};
  delivery.forEach((element) {
    deliveryJson.addAll({"geometry": jsonEncode(element.toJSON())});
  });

  var response = await http
      .post(Helper.getUri('orders/simulate'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "collect_address_data": jsonEncode(pickup.toJSON()),
            "delivery_address_data": deliveryJson,
            "slug": courier.slug,
            "return_required": returnRequired
          }))
      .timeout(const Duration(seconds: 15));
  print('response ${response.body}');
  if (response.statusCode == HttpStatus.ok) {
    return OrderSimulation.fromJSON(json.decode(response.body));
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<String> submit(
    CreateOrderAddress pickup,
    List<CreateOrderAddress> delivery,
    NearbyCourier courier,
    SelectedPaymentMethod paymentMethod,
    String? observation,
    bool returnRequired) async {
  final deliveryJson = [];
  delivery.forEach((element) {
    deliveryJson.add(jsonEncode(element.toJSON()));
  });

  Map<String, dynamic> body = {
    "collect_address_data": jsonEncode(pickup.toJSON()),
    "collect_place": pickup.address.formattedAddress,
    "delivery_address_data": deliveryJson,
    "slug": courier.slug,
    'observation': observation,
    "return_required": returnRequired,
    "payment_method_type": paymentMethod.paymentType.name,
    "payment_method": paymentMethod.id,
  };

  var response = await http
      .post(Helper.getUri('orders'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(body))
      .timeout(const Duration(seconds: 15));
      
  if (response.statusCode == HttpStatus.ok) {
    return json.decode(response.body)['id'].toString();
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<Map<String, dynamic>> getOrders(
    {int? pageSize,
    int currentItem = 0,
    DateTime? dateTimeStart,
    DateTime? dateTimeEnd}) async {
  Map<String, String> queryParameters = {};
  if (pageSize != null) {
    queryParameters.addAll(
        {'limit': pageSize.toString(), 'current_item': currentItem.toString()});
  }
  if (dateTimeStart != null) {
    queryParameters.addAll({
      'datetime_start': dateTimeStart.toString(),
    });
  }
  if (dateTimeEnd != null) {
    queryParameters.addAll({'datetime_end': dateTimeEnd.toString()});
  }
  var response = await http.get(
      Helper.getUri('orders', queryParam: queryParameters),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    List<Order> orders = jsonDecode(response.body)['data']['orders']
        .map((order) => Order.fromJSON(order))
        .toList()
        .cast<Order>();
    bool hasMoreOrders = jsonDecode(response.body)['data']['has_more_orders'];

    return {'hasMoreOrders': hasMoreOrders, 'orders': orders};
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<Order> getOrder(String orderId) async {
  var response = await http
      .get(Helper.getUri('orders/$orderId'), headers: <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  }).timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    return Order.fromJSON(json.decode(response.body)['data']);
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<List<Category>> loadCategories() async {
  var response = await http
      .get(Helper.getUri('settings/categories'), headers: <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  }).timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    return jsonDecode(response.body)['data']
        .map((order) => Category.fromJSON(order))
        .toList()
        .cast<Category>();
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<Map<String, dynamic>> initializePayment(Order order) async {
  var response = await http
      .post(Helper.getUri('orders/initializePayment'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'order_id': order.id}))
      .timeout(const Duration(seconds: 15));
  log(response.body);
  if (response.statusCode == HttpStatus.ok) {
    return json.decode(response.body);
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<StatusEnum?> checkPaymentStatus(Order order) async {
  var response = await http.get(
    Helper.getUri('orders/${order.id}/checkPaymentByOrderID'),
    headers: <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  ).timeout(const Duration(seconds: 15));

  if (response.statusCode == HttpStatus.ok) {
    return StatusEnumHelper.enumFromString(json.decode(response.body)['data']);
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<LatLng> updateCourierLocation(Order order) async {
  var response = await http
      .post(
        Helper.getUri('orders/getCourierPosition'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'order_id': order.id}),
      )
      .timeout(const Duration(seconds: 15));

  final jsonReponse = json.decode(response.body);
  if (response.statusCode == HttpStatus.ok && jsonReponse['success'] == 1) {
    return LatLng(jsonReponse['lat'], jsonReponse['lng']);
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

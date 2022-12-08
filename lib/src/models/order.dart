import 'dart:convert';

import 'address.dart';
import 'courier.dart';
import 'offline_payment_method.dart';
import 'payment_gateway_enum.dart';
import 'status_enum.dart';

class Order {
  String id;
  String? cancellationReason;
  Courier? courier;
  String? descriptionPickupLocation;
  Address? pickupLocation;
  List<Address> deliveryLocation;
  bool returnRequired;
  StatusEnum? orderStatus;
  StatusEnum? paymentStatus;
  PaymentGatewayEnum? paymentGateway;
  OfflinePaymentMethod? offlinePaymentMethod;
  String? observation;
  double distance;
  double amount;
  double courierValue;
  double appValue;
  bool finalized;
  DateTime? createdAt;
  DateTime? orderStatusDate;

  Order({
    this.id = "",
    this.deliveryLocation = const [],
    this.returnRequired = false,
    this.observation = "",
    this.distance = 0.00,
    this.amount = 0.00,
    this.courierValue = 0.00,
    this.appValue = 0.00,
    this.finalized = false,
    this.paymentGateway = PaymentGatewayEnum.online,
  });

  Order.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        cancellationReason = jsonMap['motivo_cancelamento']?.toString(),
        courier = jsonMap['courier'] != null
            ? Courier.fromJSON(jsonMap['courier'])
            : null,
        descriptionPickupLocation = jsonMap['local_coleta'] != null
            ? jsonMap['local_coleta']!.toString()
            : null,
        pickupLocation = jsonMap['pickup_location_data'] != null
            ? Address.fromJSON(jsonDecode(jsonMap['pickup_location_data']))
            : null,
        deliveryLocation = jsonMap['delivery_locations_data'] != null
            ? jsonDecode(jsonMap['delivery_locations_data'])
                    .map((address) => Address.fromJSON(address))
                    .toList()
                    .cast<Address>() ??
                []
            : null,
        returnRequired = jsonMap['need_return_to_pickup_location'] ?? false,
        orderStatus = jsonMap['order_status'] != null
            ? StatusEnumHelper.enumFromString(jsonMap['order_status'])
            : null,
        paymentStatus = jsonMap['payment_status'] != null
            ? StatusEnumHelper.enumFromString(jsonMap['payment_status']) ??
                StatusEnum.pending
            : StatusEnum.pending,
        paymentGateway =
            PaymentGatewayEnumHelper.enumFromString(jsonMap['payment_gateway']),
        offlinePaymentMethod = jsonMap['offline_payment_method'] != null
            ? OfflinePaymentMethod.fromJSON(jsonMap['offline_payment_method'])
            : null,
        observation = jsonMap['status_observation'] != null
            ? jsonMap['status_observation']
            : null,
        distance = jsonMap['distance'] != null
            ? double.parse(jsonMap['distance'].toString())
            : 0.00,
        amount = jsonMap['total_value'] != null
            ? double.parse(jsonMap['total_value'].toString())
            : 0.00,
        courierValue = jsonMap['courier_value'] != null
            ? double.parse(jsonMap['courier_value'].toString())
            : 0.00,
        appValue = jsonMap['app_value'] != null
            ? double.parse(jsonMap['app_value'].toString())
            : 0.00,
        finalized = StatusEnumHelper.enumFromString(jsonMap['order_status']) ==
                StatusEnum.completed ||
            StatusEnumHelper.enumFromString(jsonMap['order_status']) ==
                StatusEnum.rejected ||
            StatusEnumHelper.enumFromString(jsonMap['order_status']) ==
                StatusEnum.cancelled,
        createdAt = jsonMap['created_at'] != null
            ? DateTime.tryParse(jsonMap['created_at']) ?? null
            : null,
        orderStatusDate = jsonMap['order_status_date'] != null
            ? DateTime.tryParse(jsonMap['order_status_date']) ?? null
            : null;

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'courier': courier?.toJSON(),
      'distance': distance,
      'observacao': observation,
      'valor_total': amount,
      'finalizado': finalized,
    };
  }
}

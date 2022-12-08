class NearbyCourier {
  String id;
  String slug;
  String name;
  String? distance;
  String? avatar;
  String ordersCount;

  NearbyCourier({
    this.id = "",
    this.slug = "",
    this.name = "",
    this.ordersCount = "",
  });

  NearbyCourier.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        slug = jsonMap['slug'] ?? '',
        name = jsonMap['name'] ?? '',
        distance = jsonMap['distance'],
        avatar = jsonMap['avatar'],
        ordersCount = jsonMap['orders_count'] ?? '';
}

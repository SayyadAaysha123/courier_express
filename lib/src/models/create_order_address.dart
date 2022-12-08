import 'package:google_place/google_place.dart';

class CreateOrderAddress {
  String? number;
  DetailsResult address;

  CreateOrderAddress(this.address);

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {};
    json['formatted_address'] = address.formattedAddress;
    json['geometry'] = {};
    json['geometry']['location'] = {};
    json['geometry']['location']['lat'] = address.geometry?.location?.lat ?? 0;
    json['geometry']['location']['lng'] = address.geometry?.location?.lng ?? 0;
    json['geometry']['viewport'] = {};
    json['geometry']['viewport']['south'] =
        address.geometry?.viewport?.southwest?.lat ?? 0;
    json['geometry']['viewport']['west'] =
        address.geometry?.viewport?.southwest?.lng ?? 0;
    json['geometry']['viewport']['north'] =
        address.geometry?.viewport?.northeast?.lat ?? 0;
    json['geometry']['viewport']['east'] =
        address.geometry?.viewport?.northeast?.lng ?? 0;
    json['name'] = address.name;
    json['place_id'] = address.placeId;
    json['number'] = number ?? '';

    return json;
  }
}

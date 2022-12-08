import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:courier_customer_app/src/helper/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/order.dart';

class OrderTrackingWidget extends StatefulWidget {
  final Order order;

  OrderTrackingWidget({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderTrackingWidget> createState() => OrderTrackingWidgetState();
}

class OrderTrackingWidgetState extends State<OrderTrackingWidget> {
  Completer<GoogleMapController> _controller = Completer();
  bool locked = true;
  BitmapDescriptor? icon;

  void setIcon() async {
    ByteData data = await rootBundle.load(Images.courierIcon);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: 200);
    ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List markerIcon =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
    setState(() {
      icon = BitmapDescriptor.fromBytes(markerIcon);
    });
  }

  Future<void> animateToMarker({bool manual = true}) async {
    if (widget.order.courier?.lat != null &&
        widget.order.courier?.lng != null &&
        (manual == true || locked == true)) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(widget.order.courier!.lat!, widget.order.courier!.lng!),
            zoom: await controller.getZoomLevel(),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    setIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GoogleMap(
            markers: Set<Marker>.of(
              [
                Marker(
                    markerId: MarkerId('1'),
                    position: LatLng(
                      widget.order.courier?.lat ?? 0,
                      widget.order.courier?.lng ?? 0,
                    ),
                    icon: icon ?? BitmapDescriptor.defaultMarker)
              ],
            ),
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.order.courier?.lat ?? 0,
                  widget.order.courier?.lng ?? 0),
              zoom: 14.5,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "buttonAnimateToMarker",
                    onPressed: () => animateToMarker(),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(
                      Icons.motorcycle_outlined,
                      size: 36.0,
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  FloatingActionButton(
                    heroTag: "buttonLockTracking",
                    onPressed: () => setState(() => locked = !locked),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(
                      locked ? Icons.lock : Icons.lock_open,
                      size: 36.0,
                      color: Theme.of(context).highlightColor,
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

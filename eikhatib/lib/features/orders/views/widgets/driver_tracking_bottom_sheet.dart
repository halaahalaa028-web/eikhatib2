// ignore_for_file: prefer_final_fields, deprecated_member_use

import 'package:eikhatib/features/orders/logic/orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/orders/data/models/order_model.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:dio/dio.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class DriverTrackingBottomSheet extends StatefulWidget {
  final OrderModel order;

  const DriverTrackingBottomSheet({super.key, required this.order});

  static void show(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DriverTrackingBottomSheet(order: order),
    );
  }

  @override
  State<DriverTrackingBottomSheet> createState() =>
      _DriverTrackingBottomSheetState();
}

class _DriverTrackingBottomSheetState extends State<DriverTrackingBottomSheet> {
  GoogleMapController? _mapController;

  late LatLng _destination;
  LatLng? _currentDriverPosition;

  List<LatLng> _routePoints = [];
  double _currentBearing = 0.0;

  BitmapDescriptor? _carIcon;
  bool _hasArrived = false;

  @override
  void initState() {
    super.initState();
    _destination = LatLng(
      widget.order.address!.latitude,
      widget.order.address!.longitude,
    );

    if (widget.order.driverLatitude != null &&
        widget.order.driverLongitude != null) {
      _currentDriverPosition = LatLng(
        widget.order.driverLatitude!,
        widget.order.driverLongitude!,
      );
      _currentBearing = _calculateBearing(
        _currentDriverPosition!,
        _destination,
      );
      _fetchRoute();
    }

    _loadCarIcon();
  }

  Future<void> _fetchRoute() async {
    if (_currentDriverPosition == null) return;
    try {
      final dio = Dio();
      final url =
          'http://router.project-osrm.org/route/v1/driving/${_currentDriverPosition!.longitude},${_currentDriverPosition!.latitude};${_destination.longitude},${_destination.latitude}?geometries=geojson';
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final coords = data['routes'][0]['geometry']['coordinates'] as List;
          _routePoints = coords.map((c) => LatLng(c[1], c[0])).toList();
          setState(() {});
        }
      }
    } catch (e) {
      // Fallback to straight line on error
    }
  }

  Future<void> _loadCarIcon() async {
    final customIcon = await _createDriverMarker();
    setState(() {
      _carIcon = customIcon;
    });
  }

  Future<BitmapDescriptor> _createDriverMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 160.0;

    // Draw Driver Circle (Top)
    final Paint borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final Paint whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(size / 2, 40), 30, borderPaint);
    canvas.drawCircle(const Offset(size / 2, 40), 26, whitePaint);

    TextPainter driverPainter = TextPainter(textDirection: TextDirection.ltr);
    driverPainter.text = TextSpan(
      text: String.fromCharCode(Icons.person_rounded.codePoint),
      style: TextStyle(
        fontSize: 34,
        fontFamily: Icons.person_rounded.fontFamily,
        package: Icons.person_rounded.fontPackage,
        color: Colors.grey,
      ),
    );
    driverPainter.layout();
    driverPainter.paint(
      canvas,
      Offset(size / 2 - driverPainter.width / 2, 40 - driverPainter.height / 2),
    );

    // Draw connecting line to car
    final Paint linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3;
    canvas.drawLine(
      const Offset(size / 2, 70),
      const Offset(size / 2, 90),
      linePaint,
    );

    // Draw Car background (Bottom)
    canvas.drawCircle(const Offset(size / 2, 110), 30, borderPaint);
    canvas.drawCircle(const Offset(size / 2, 110), 26, whitePaint);

    TextPainter carPainter = TextPainter(textDirection: TextDirection.ltr);
    carPainter.text = TextSpan(
      text: String.fromCharCode(Icons.local_taxi_rounded.codePoint),
      style: TextStyle(
        fontSize: 34,
        fontFamily: Icons.local_taxi_rounded.fontFamily,
        package: Icons.local_taxi_rounded.fontPackage,
        color: AppColors.primary,
      ),
    );
    carPainter.layout();
    carPainter.paint(
      canvas,
      Offset(size / 2 - carPainter.width / 2, 110 - carPainter.height / 2),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt() + 20,
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) return BitmapDescriptor.defaultMarker;

    return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final currentOrder = state.orders.firstWhere(
          (o) => o.id == widget.order.id,
          orElse: () => widget.order,
        );

        if (currentOrder.driverLatitude != null &&
            currentOrder.driverLongitude != null) {
          final newPos = LatLng(
            currentOrder.driverLatitude!,
            currentOrder.driverLongitude!,
          );
          if (_currentDriverPosition != newPos) {
            _currentDriverPosition = newPos;
            if (_mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newLatLng(_currentDriverPosition!),
              );
            }
          }
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تتبع السائق',
                          style: GoogleFonts.tajawal(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _hasArrived
                              ? 'وصل السائق، استلم طلبك!'
                              : _currentDriverPosition == null
                              ? 'في انتظار استلام السائق للطلب...'
                              : 'جاري تتبع السائق مباشرة...',
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _hasArrived
                                ? Colors.green
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.black87,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentDriverPosition ?? _destination,
                        zoom: 16,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      markers: {
                        Marker(
                          markerId: const MarkerId('destination'),
                          position: _destination,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue,
                          ),
                        ),
                        if (_currentDriverPosition != null)
                          Marker(
                            markerId: const MarkerId('driver'),
                            position: _currentDriverPosition!,
                            icon:
                                _carIcon ??
                                BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueOrange,
                                ),
                            rotation: _currentBearing,
                          ),
                      },
                      polylines: {
                        if (_routePoints.isNotEmpty)
                          Polyline(
                            polylineId: const PolylineId('route'),
                            points: _routePoints,
                            color: AppColors.primary.withValues(alpha: 0.8),
                            width: 6,
                          ),
                      },
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                    ),

                    // Bottom Info Card overlaid on map
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'أحمد محمد (السائق)',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.8',
                                        style: GoogleFonts.tajawal(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'تويوتا كورولا - أبيض',
                                        style: GoogleFonts.tajawal(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.phone_in_talk_rounded,
                                color: Colors.green,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final double startLat = start.latitude * math.pi / 180;
    final double startLng = start.longitude * math.pi / 180;
    final double endLat = end.latitude * math.pi / 180;
    final double endLng = end.longitude * math.pi / 180;

    final double dLng = endLng - startLng;

    final double y = math.sin(dLng) * math.cos(endLat);
    final double x =
        math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(dLng);

    double brng = math.atan2(y, x);
    brng = (brng * 180) / math.pi;
    brng = (brng + 360) % 360;

    return brng;
  }
}

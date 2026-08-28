import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/orders/data/models/order_model.dart';
import 'package:eikhatib/features/orders/logic/directions_service.dart';
import 'package:eikhatib/features/orders/logic/orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class DriverLiveTrackingScreen extends StatefulWidget {
  final OrderModel order;
  const DriverLiveTrackingScreen({super.key, required this.order});

  @override
  State<DriverLiveTrackingScreen> createState() => _DriverLiveTrackingScreenState();
}

class _DriverLiveTrackingScreenState extends State<DriverLiveTrackingScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;
  LatLng? _currentPosition;
  List<LatLng> _polylineCoordinates = [];
  String _distance = '-- كم';
  String _duration = '-- دقيقة';
  BitmapDescriptor? _carIcon;
  bool _isLoading = true;
  LatLngBounds? _routeBounds;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _loadCarIcon();
    _startTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadCarIcon() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 120.0;

    final Paint paint = Paint()..color = AppColors.primary;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: String.fromCharCode(Icons.local_taxi_rounded.codePoint),
      style: TextStyle(
        fontSize: 80,
        fontFamily: Icons.local_taxi_rounded.fontFamily,
        package: Icons.local_taxi_rounded.fontPackage,
        color: Colors.white,
      ),
    );
    painter.layout();
    painter.paint(canvas, Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2));

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      setState(() => _carIcon = BitmapDescriptor.fromBytes(byteData.buffer.asUint8List()));
    }
  }

  void _startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final startPos = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(startPos.latitude, startPos.longitude);
    
    await _fetchDirections(true);

    setState(() => _isLoading = false);

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters for smoothness
      ),
    ).listen((Position position) {
      final newPos = LatLng(position.latitude, position.longitude);
      setState(() => _currentPosition = newPos);
      
      context.read<OrdersCubit>().updateOrderLocation(
        widget.order.id, 
        position.latitude, 
        position.longitude,
      );

      // Refresh ETA and small path updates
      _fetchDirections(false);
      
      if (_isFirstLoad) {
        _fitBounds();
        _isFirstLoad = false;
      } else {
        _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
      }
    });
  }

  Future<void> _fetchDirections(bool isInitial) async {
    if (_currentPosition == null) return;
    
    final customerPos = LatLng(
      widget.order.address?.latitude ?? 0, 
      widget.order.address?.longitude ?? 0
    );

    final directions = await DirectionsService().getDirections(
      origin: _currentPosition!,
      destination: customerPos,
    );

    if (directions != null) {
      setState(() {
        _polylineCoordinates = directions['polyline_coordinates'];
        _distance = directions['distance'];
        _duration = directions['duration'];
        _routeBounds = directions['bounds'];
      });
      if (isInitial) _fitBounds();
    }
  }

  void _fitBounds() {
    if (_mapController == null || _routeBounds == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(_routeBounds!, 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('تتبع حي (Uber Mode)', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fitBounds,
            icon: const Icon(Icons.center_focus_strong_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 16,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_routeBounds != null) _fitBounds();
                },
                markers: {
                  if (_currentPosition != null)
                    Marker(
                      markerId: const MarkerId('driver'),
                      position: _currentPosition!,
                      icon: _carIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      rotation: 0, // In a real app we'd calculate bearing
                      anchor: const Offset(0.5, 0.5),
                    ),
                  Marker(
                    markerId: const MarkerId('customer'),
                    position: LatLng(
                      widget.order.address?.latitude ?? 0, 
                      widget.order.address?.longitude ?? 0
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                  ),
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: _polylineCoordinates,
                    color: AppColors.primary,
                    width: 6,
                    jointType: JointType.round,
                    startCap: Cap.roundCap,
                    endCap: Cap.roundCap,
                  ),
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
              _buildTripStatsOverlay(),
              _buildTripActionCard(),
            ],
          ),
    );
  }

  Widget _buildTripStatsOverlay() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 2)],
        ),
        child: Row(
          children: [
            _buildStatItem(Icons.access_time_filled_rounded, 'الوقت المقدر', _duration),
            const VerticalDivider(),
            _buildStatItem(Icons.straighten_rounded, 'المسافة', _distance),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.tajawal(fontSize: 10, color: Colors.grey)),
            ],
          ),
          Text(value, style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTripActionCard() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person, color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'العميل: ${widget.order.address?.firstName ?? ''} ${widget.order.address?.lastName ?? ''}',
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(widget.order.address?.street ?? '', style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.phone, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<OrdersCubit>().updateStatus(widget.order.id, 'تم التوصيل');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              child: Text('إنهاء الطلب وتأكيد التوصيل', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

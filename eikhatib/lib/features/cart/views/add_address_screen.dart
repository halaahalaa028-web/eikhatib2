// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:eikhatib/core/routes/app_router.dart';
import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/auth/logic/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/address_model.dart';
import '../logic/address_cubit.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng _currentPosition = const LatLng(31.9539, 35.9106);

  final Dio _dio = Dio();
  final String _googleApiKey = "AIzaSyDse2PDyMsk1P9u8nq8BsFvv6fWz0cLgiU";

  List<dynamic> _placePredictions = [];
  Timer? _debounce;
  bool _isLocating = false;

  final _searchController = TextEditingController();
  final _titleController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _notesController = TextEditingController();

  // Customer info controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-fill from logged-in user
    final user = context.read<UserCubit>().state.user;
    if (user != null) {
      if (_firstNameController.text.isEmpty && user.firstName != null) {
        _firstNameController.text = user.firstName!;
      }
      if (_lastNameController.text.isEmpty && user.lastName != null) {
        _lastNameController.text = user.lastName!;
      }
      if (_storeNameController.text.isEmpty) {
        _storeNameController.text = user.name;
      }
      if (_phoneController.text.isEmpty && user.phoneNumber != null) {
        _phoneController.text = user.phoneNumber!;
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _titleController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _notesController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _storeNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ─── Location ──────────────────────────────────────────────────────────────

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      if (perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      final ctrl = await _mapController.future;
      ctrl.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
      _updateAddressDetails(latLng);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ─── Reverse Geocoding ─────────────────────────────────────────────────────

  void _updateAddressDetails(LatLng position) async {
    setState(() {
      _currentPosition = position;
      _countryController.text = 'جاري التحديد...';
      _cityController.text = 'جاري التحديد...';
    });

    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&accept-language=ar';
      final res = await _dio.get(
        url,
        options: Options(headers: {'User-Agent': 'eikhatib-app/1.0'}),
      );
      if (res.statusCode == 200 && mounted) {
        final addr = res.data['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final country = addr['country'] as String? ?? '';
          final city =
              (addr['city'] as String?) ??
              (addr['town'] as String?) ??
              (addr['state'] as String?) ??
              (addr['county'] as String?) ??
              '';
          final road = (addr['road'] as String?) ?? '';
          final suburb = (addr['suburb'] as String?) ?? '';
          if (mounted) {
            setState(() {
              _countryController.text = country.isNotEmpty ? country : 'غير محدد';
              _cityController.text = city.isNotEmpty ? city : 'غير محدد';
              if (road.isNotEmpty || suburb.isNotEmpty) {
                _streetController.text = '$road $suburb'.trim();
              }
            });
          }
          return;
        }
      }
    } catch (_) {}

    try {
      final marks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (marks.isNotEmpty && mounted) {
        final p = marks.first;
        final country = p.country ?? '';
        final city = p.locality?.isNotEmpty == true
            ? p.locality!
            : (p.subAdministrativeArea?.isNotEmpty == true
                  ? p.subAdministrativeArea!
                  : (p.administrativeArea ?? ''));
        final street = '${p.street ?? ''} ${p.subLocality ?? ''}'.trim();
        setState(() {
          _countryController.text = country.isNotEmpty ? country : 'غير محدد';
          _cityController.text = city.isNotEmpty ? city : 'غير محدد';
          if (street.isNotEmpty) _streetController.text = street;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _countryController.text = 'غير محدد';
        _cityController.text = 'غير محدد';
      });
    }
  }

  // ─── Search ────────────────────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() => _placePredictions = []);
        return;
      }
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleApiKey&language=ar';
      try {
        final res = await _dio.get(url);
        if (res.statusCode == 200 && mounted) {
          setState(() => _placePredictions = res.data['predictions']);
        }
      } catch (_) {}
    });
  }

  void _onPlaceSelected(String placeId, String description) async {
    setState(() {
      _placePredictions = [];
      _searchController.text = description;
    });
    FocusScope.of(context).unfocus();

    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleApiKey&language=ar';
    try {
      final res = await _dio.get(url);
      if (res.statusCode == 200) {
        final loc = res.data['result']['geometry']['location'];
        final newPos = LatLng(loc['lat'], loc['lng']);
        final ctrl = await _mapController.future;
        ctrl.animateCamera(CameraUpdate.newLatLngZoom(newPos, 16));
        _updateAddressDetails(newPos);
      }
    } catch (_) {}
  }

  // ─── Map callbacks ─────────────────────────────────────────────────────────

  void _onCameraIdle() => _updateAddressDetails(_currentPosition);

  Future<void> _zoom(bool zoomIn) async {
    final ctrl = await _mapController.future;
    ctrl.animateCamera(zoomIn ? CameraUpdate.zoomIn() : CameraUpdate.zoomOut());
  }

  // ─── Save ──────────────────────────────────────────────────────────────────

  void _onSaveAddress() {
    final firstName = _firstNameController.text.trim();
    final storeName = _storeNameController.text.trim();

    if (storeName.isEmpty && firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى إدخال اسم المحل أو اسم العميل',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Use store name as title, or first+last name
    final title = storeName.isNotEmpty
        ? storeName
        : '$firstName ${_lastNameController.text.trim()}'.trim();

    // Update user profile if data was changed
    final user = context.read<UserCubit>().state.user;
    if (user != null) {
      final sName = storeName.isNotEmpty ? storeName : null;
      final fName = firstName.isNotEmpty ? firstName : null;
      final lName = _lastNameController.text.trim().isNotEmpty
          ? _lastNameController.text.trim()
          : null;
      if (sName != null || fName != null || lName != null) {
        context.read<UserCubit>().updateProfile(
              storeName: sName,
              firstName: fName,
              lastName: lName,
            );
      }
    }

    context.read<AddressCubit>().addAddress(
          AddressModel(
            id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            street: _streetController.text.trim(),
            city: _cityController.text.trim(),
            country: _countryController.text.trim(),
            latitude: _currentPosition.latitude,
            longitude: _currentPosition.longitude,
            firstName: firstName.isNotEmpty ? firstName : null,
            lastName: _lastNameController.text.trim().isNotEmpty
                ? _lastNameController.text.trim()
                : null,
            storeName: storeName.isNotEmpty ? storeName : null,
            phoneNumber: _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
          ),
        );
    AppRouter.goBack(context);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black87,
                size: 20,
              ),
              onPressed: () => AppRouter.goBack(context),
            ),
            title: Text(
              'إضافة عنوان',
              style: GoogleFonts.tajawal(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(color: Colors.grey.shade100, height: 1),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top intro ──
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        AppAssets.location,
                        height: 120,
                        width: 120,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'حدد موقعك على الخريطة',
                        style: GoogleFonts.tajawal(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'يمكنك تحريك الخريطة لاختيار الموقع الدقيق، أو البحث مباشرةً',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Search ──
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن مكان أو شارع...',
                            hintStyle: GoogleFonts.tajawal(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Colors.grey,
                              size: 22,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      if (_placePredictions.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            itemCount: _placePredictions.length,
                            separatorBuilder: (_, __) =>
                                Divider(color: Colors.grey.shade100, height: 1),
                            itemBuilder: (context, i) {
                              final p = _placePredictions[i];
                              return ListTile(
                                dense: true,
                                leading: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.place_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  p['description'],
                                  style: GoogleFonts.tajawal(fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _onPlaceSelected(
                                  p['place_id'],
                                  p['description'],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Map ──
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 260,
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition,
                              zoom: 16,
                            ),
                            onMapCreated: (ctrl) =>
                                _mapController.complete(ctrl),
                            onCameraMove: (pos) =>
                                _currentPosition = pos.target,
                            onCameraIdle: _onCameraIdle,
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            myLocationEnabled: false,
                            mapToolbarEnabled: false,
                          ),

                          // Center Pin
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 48),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'موقعك المحدد',
                                          style: GoogleFonts.tajawal(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 13,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 44,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // GPS button
                          Positioned(
                            top: 12,
                            left: 12,
                            child: GestureDetector(
                              onTap: _getCurrentLocation,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _isLocating
                                    ? const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.my_location_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),

                          // Zoom controls
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      color: Colors.black54,
                                      size: 18,
                                    ),
                                    onPressed: () => _zoom(true),
                                  ),
                                  Container(
                                    height: 1,
                                    width: 30,
                                    color: Colors.grey.shade200,
                                  ),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    icon: const Icon(
                                      Icons.remove_rounded,
                                      color: Colors.black54,
                                      size: 18,
                                    ),
                                    onPressed: () => _zoom(false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Location Details Card ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'تفاصيل الموقع',
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _infoRow(Icons.flag_rounded, 'البلد', _countryController),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        _infoRow(Icons.location_city_rounded, 'المدينة', _cityController),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        _infoRow(Icons.streetview_rounded, 'الشارع', _streetController),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.gps_fixed_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'الإحداثيات:',
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_currentPosition.latitude.toStringAsFixed(5)}, ${_currentPosition.longitude.toStringAsFixed(5)}',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Customer Info Form ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('بيانات العميل'),
                        const SizedBox(height: 6),
                        Text(
                          'سيتم تحديث بياناتك الشخصية تلقائياً عند الحفظ',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Store Name
                        _field(
                          'اسم المحل',
                          _storeNameController,
                          icon: Icons.store_outlined,
                        ),
                        const SizedBox(height: 14),

                        // First + Last Name row
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                'الاسم الأول',
                                _firstNameController,
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _field(
                                'اسم العائلة',
                                _lastNameController,
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Phone
                        _field(
                          'رقم الهاتف',
                          _phoneController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),

                        // Notes
                        _field(
                          'ملاحظات للمندوب (اختياري)',
                          _notesController,
                          icon: Icons.notes_rounded,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _onSaveAddress,
                            icon: const Icon(Icons.save_rounded, size: 20),
                            label: Text(
                              'حفظ العنوان',
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _infoRow(IconData icon, String label, TextEditingController ctrl) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: GoogleFonts.tajawal(fontSize: 13, color: Colors.grey.shade500),
        ),
        const Spacer(),
        Expanded(
          child: TextField(
            controller: ctrl,
            textAlign: TextAlign.left,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _field(
    String hint,
    TextEditingController ctrl, {
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: maxLines > 1 ? 12 : 0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: ctrl,
              maxLines: maxLines,
              textDirection: TextDirection.rtl,
              keyboardType: keyboardType,
              style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.tajawal(
                  color: Colors.black45,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

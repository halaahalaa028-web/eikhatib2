// ignore_for_file: unused_element, unused_field, deprecated_member_use

import 'package:eikhatib/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/routes.dart';
import '../../logic/address_cubit.dart';

class AddressesBottomSheet extends StatefulWidget {
  const AddressesBottomSheet({super.key});

  @override
  State<AddressesBottomSheet> createState() => _AddressesBottomSheetState();
}

class _AddressesBottomSheetState extends State<AddressesBottomSheet> {
  bool _isLoadingLocation = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isLoadingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get a human-readable address
      String locationName = 'الموقع الحالي';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            if ((p.name ?? '').isNotEmpty && p.name != p.street) p.name,
            if ((p.street ?? '').isNotEmpty) p.street,
            if ((p.subLocality ?? '').isNotEmpty) p.subLocality,
            if ((p.locality ?? '').isNotEmpty) p.locality,
          ].whereType<String>().toSet().toList();
          if (parts.isNotEmpty) locationName = parts.join('، ');
        }
      } catch (_) {
        // keep default if geocoding fails
      }

      if (mounted) {
        context.read<AddressCubit>().setCurrentLocation(
          'الموقع الحالي',
          locationName,
          position.latitude,
          position.longitude,
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFBFBFB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'اختر عنوان التوصيل',
                      style: GoogleFonts.tajawal(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 16),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // // ─── Current Location Card ───
                    // GestureDetector(
                    //   onTap: _isLoadingLocation ? null : _useCurrentLocation,
                    //   child: AnimatedContainer(
                    //     duration: const Duration(milliseconds: 200),
                    //     padding: const EdgeInsets.all(16),
                    //     decoration: BoxDecoration(
                    //       gradient: LinearGradient(
                    //         colors: [
                    //           AppColors.primary.withOpacity(0.06),
                    //           AppColors.primary.withOpacity(0.03),
                    //         ],
                    //       ),
                    //       borderRadius: BorderRadius.circular(14),
                    //       border: Border.all(
                    //         color: AppColors.primary.withOpacity(0.35),
                    //       ),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         Container(
                    //           width: 44,
                    //           height: 44,
                    //           decoration: BoxDecoration(
                    //             color: AppColors.primary.withOpacity(0.15),
                    //             borderRadius: BorderRadius.circular(12),
                    //           ),
                    //           child: _isLoadingLocation
                    //               ? const Padding(
                    //                   padding: EdgeInsets.all(10),
                    //                   child: CircularProgressIndicator(
                    //                     strokeWidth: 2,
                    //                     color: AppColors.primary,
                    //                   ),
                    //                 )
                    //               : const Icon(
                    //                   Icons.my_location_rounded,
                    //                   color: AppColors.primary,
                    //                   size: 22,
                    //                 ),
                    //         ),
                    //         const SizedBox(width: 14),
                    //         Expanded(
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Text(
                    //                 'الموقع الحالي',
                    //                 style: GoogleFonts.tajawal(
                    //                   fontSize: 15,
                    //                   fontWeight: FontWeight.bold,
                    //                   color: AppColors.primary,
                    //                 ),
                    //               ),
                    //               Text(
                    //                 _isLoadingLocation
                    //                     ? 'جاري تحديد موقعك...'
                    //                     : 'اضغط لاستخدام موقعك الحالي',
                    //                 style: GoogleFonts.tajawal(
                    //                   fontSize: 12,
                    //                   color: Colors.grey.shade600,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //         Icon(
                    //           Icons.arrow_back_ios_new_rounded,
                    //           size: 14,
                    //           color: Colors.grey.shade400,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 24),

                    // ─── Saved Addresses ───
                    Row(
                      children: [
                        Text(
                          'عناويني',
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        BlocBuilder<AddressCubit, AddressState>(
                          builder: (context, state) {
                            if (state.addresses.isEmpty) {
                              return const SizedBox();
                            }
                            return Text(
                              '${state.addresses.length} عناوين',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    BlocBuilder<AddressCubit, AddressState>(
                      builder: (context, state) {
                        if (state.addresses.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.location_off_outlined,
                                  size: 36,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'لا توجد عناوين محفوظة بعد',
                                  style: GoogleFonts.tajawal(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.addresses.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final addr = state.addresses[index];
                            final isSelected =
                                state.selectedAddress?.id == addr.id;
                            return GestureDetector(
                              onTap: () {
                                context.read<AddressCubit>().selectAddress(
                                  addr,
                                );
                                Navigator.pop(context);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.05)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade200,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary.withOpacity(0.1)
                                            : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: Icon(
                                        Icons.location_on_rounded,
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.grey.shade500,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            addr.title,
                                            style: GoogleFonts.tajawal(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            [
                                              if (addr.street.isNotEmpty)
                                                addr.street,
                                              if (addr.city.isNotEmpty)
                                                addr.city,
                                              if (addr.country.isNotEmpty)
                                                addr.country,
                                            ].join('، '),
                                            style: GoogleFonts.tajawal(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 20,
                                        color: AppColors.primary,
                                      )
                                    else
                                      Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 14,
                                        color: Colors.grey.shade400,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ─── Add Address Button ───
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          AppRouter.navigateTo(context, Routes.addAddress);
                        },
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        label: Text(
                          'إضافة عنوان جديد',
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: AppColors.primary.withOpacity(0.04),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

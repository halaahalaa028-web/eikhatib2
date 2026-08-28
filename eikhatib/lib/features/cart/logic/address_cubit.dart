import 'package:dio/dio.dart';
import 'package:eikhatib/core/api/end_point.dart';
import 'package:eikhatib/core/cache/cache_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/address_model.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit() : super(const AddressState()) {
    fetchAddresses();
  }

  final Dio _dio = Dio();

  // ─── Fetch addresses from API ──────────────────────────────────────────────
  Future<void> fetchAddresses() async {
    final token = await SecureCacheHelper().getData(key: ApiKey.token);
    if (token == null) return;

    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.addresses}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data['addresses'] ?? [];
      final addresses = data.map((e) => AddressModel.fromJson(e)).toList();
      
      // If we have addresses but nothing is selected, select the first one
      AddressModel? selected = state.selectedAddress;
      if (selected == null && addresses.isNotEmpty) {
        selected = addresses.first;
      }

      emit(state.copyWith(
        addresses: addresses,
        selectedAddress: selected,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'فشل تحميل العناوين'));
    }
  }

  // ─── Add address via API ───────────────────────────────────────────────────
  Future<void> addAddress(AddressModel address) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
    final token = await SecureCacheHelper().getData(key: ApiKey.token);
    final response = await _dio.post(
      '${EndPoint.baseUrl}${EndPoint.addresses}',
      data: address.toJson(),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

      final saved = AddressModel.fromJson(response.data['address']);
      final updated = List<AddressModel>.from(state.addresses)..add(saved);
      emit(state.copyWith(
        addresses: updated,
        selectedAddress: saved,
        isLoading: false,
      ));
    } catch (e) {
      // Fallback: add locally even if API fails
      final updated = List<AddressModel>.from(state.addresses)..add(address);
      emit(state.copyWith(
        addresses: updated,
        selectedAddress: address,
        isLoading: false,
        error: 'تم الحفظ محلياً فقط',
      ));
    }
  }

  // ─── Delete address via API ────────────────────────────────────────────────
  Future<void> deleteAddress(String addressId) async {
    try {
    final token = await SecureCacheHelper().getData(key: ApiKey.token);
    await _dio.delete(
      '${EndPoint.baseUrl}${EndPoint.deleteAddress(addressId)}',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
      final updated = state.addresses.where((a) => a.id != addressId).toList();
      final selected = state.selectedAddress?.id == addressId
          ? (updated.isNotEmpty ? updated.first : null)
          : state.selectedAddress;
      emit(state.copyWith(addresses: updated, selectedAddress: selected));
    } catch (e) {
      emit(state.copyWith(error: 'فشل حذف العنوان'));
    }
  }

  // ─── Select address (local only) ──────────────────────────────────────────
  void selectAddress(AddressModel address) {
    emit(state.copyWith(selectedAddress: address));
  }

  // ─── Set current location (local only, no API) ────────────────────────────
  void setCurrentLocation(
    String title,
    String details,
    double lat,
    double lng,
  ) {
    final current = AddressModel(
      id: 'current_loc_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      street: details,
      city: '',
      country: '',
      latitude: lat,
      longitude: lng,
    );
    emit(state.copyWith(selectedAddress: current));
  }
}

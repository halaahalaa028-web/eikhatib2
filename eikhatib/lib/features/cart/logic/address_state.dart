part of 'address_cubit.dart';

class AddressState extends Equatable {
  final List<AddressModel> addresses;
  final AddressModel? selectedAddress;
  final bool isLoading;
  final String? error;

  const AddressState({
    this.addresses = const [],
    this.selectedAddress,
    this.isLoading = false,
    this.error,
  });

  AddressState copyWith({
    List<AddressModel>? addresses,
    AddressModel? selectedAddress,
    bool? isLoading,
    String? error,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [addresses, selectedAddress, isLoading, error];
}

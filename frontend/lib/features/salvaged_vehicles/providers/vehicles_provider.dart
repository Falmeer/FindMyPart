import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/vehicle_model.dart';
import '../data/repositories/vehicles_repository.dart';

final featuredVehiclesProvider = FutureProvider<List<VehicleModel>>((ref) async {
  return ref.read(vehiclesRepositoryProvider).getVehicles(page: 1);
});

final vehiclesListProvider = FutureProvider.family<List<VehicleModel>, VehicleFilter>((ref, filter) async {
  return ref.read(vehiclesRepositoryProvider).getVehicles(
        page: filter.page,
        brand: filter.brand,
        model: filter.model,
        yearFrom: filter.yearFrom,
        yearTo: filter.yearTo,
        condition: filter.condition,
        search: filter.search,
      );
});

final vehicleDetailProvider = FutureProvider.family<VehicleModel, int>((ref, id) async {
  return ref.read(vehiclesRepositoryProvider).getVehicle(id);
});

class VehicleFilter {
  final int page;
  final String? brand;
  final String? model;
  final int? yearFrom;
  final int? yearTo;
  final String? condition;
  final String? search;

  const VehicleFilter({
    this.page = 1,
    this.brand,
    this.model,
    this.yearFrom,
    this.yearTo,
    this.condition,
    this.search,
  });

  @override
  bool operator ==(Object other) =>
      other is VehicleFilter &&
      page == other.page &&
      brand == other.brand &&
      model == other.model &&
      yearFrom == other.yearFrom &&
      yearTo == other.yearTo &&
      condition == other.condition &&
      search == other.search;

  @override
  int get hashCode => Object.hash(page, brand, model, yearFrom, yearTo, condition, search);
}

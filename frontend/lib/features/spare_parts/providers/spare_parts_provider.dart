import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/models/spare_part_model.dart';
import '../data/repositories/spare_parts_repository.dart';

class CategoryModel {
  final int id;
  final String name;
  const CategoryModel({required this.id, required this.name});
  factory CategoryModel.fromJson(Map<String, dynamic> j) =>
      CategoryModel(id: j['id'] as int, name: j['name'] as String);
}

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final response = await ref.read(apiClientProvider).get('/categories');
  final data = response.data['data'] as List;
  return data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
});

final featuredPartsProvider = FutureProvider<List<SparePartModel>>((ref) async {
  return ref.read(sparePartsRepositoryProvider).getParts(page: 1);
});

final sparePartsListProvider =
    FutureProvider.family<List<SparePartModel>, SparePartFilter>((ref, filter) async {
  return ref.read(sparePartsRepositoryProvider).getParts(
        page: filter.page,
        category: filter.category,
        condition: filter.condition,
        minPrice: filter.minPrice,
        maxPrice: filter.maxPrice,
        search: filter.search,
      );
});

final sparePartDetailProvider = FutureProvider.family<SparePartModel, int>((ref, id) async {
  return ref.read(sparePartsRepositoryProvider).getPart(id);
});

class SparePartFilter {
  final int page;
  final String? category;
  final String? condition;
  final double? minPrice;
  final double? maxPrice;
  final String? search;

  const SparePartFilter({
    this.page = 1,
    this.category,
    this.condition,
    this.minPrice,
    this.maxPrice,
    this.search,
  });

  @override
  bool operator ==(Object other) =>
      other is SparePartFilter &&
      page == other.page &&
      category == other.category &&
      condition == other.condition &&
      minPrice == other.minPrice &&
      maxPrice == other.maxPrice &&
      search == other.search;

  @override
  int get hashCode => Object.hash(page, category, condition, minPrice, maxPrice, search);
}

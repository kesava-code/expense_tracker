import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:categories_client/data/category_repository.dart';
import 'package:categories_client/models/category.dart';
import 'package:categories_client/services/category_service.dart';

import 'categories_client_test.mocks.dart';

@GenerateMocks([CategoryRepository])
void main() {
  late MockCategoryRepository mockCategoryRepository;
  late CategoryService categoryService;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    categoryService = CategoryService(categoryRepository: mockCategoryRepository);
  });

  group('CategoryService Tests', () {
    final testCategory1 = Category(name: 'Food', id: 1);
    final testCategory2 = Category(name: 'Shopping', id: 2);

    group('getCategories', () {
      test('should get all categories when no filters are provided', () async {
        final categories = [testCategory1, testCategory2];
        when(mockCategoryRepository.getCategories()).thenAnswer((_) async => categories);

        final result = await categoryService.getCategories();

        expect(result, categories);
        verify(mockCategoryRepository.getCategories()).called(1);
      });

      test('should filter by IDs', () async {
        final ids = [1];
        final filteredCategories = [testCategory1];
        when(mockCategoryRepository.getCategories(ids: ids))
            .thenAnswer((_) async => filteredCategories);

        final result = await categoryService.getCategories(ids: ids);

        expect(result, filteredCategories);
        verify(mockCategoryRepository.getCategories(ids: ids)).called(1);
      });

      test('should search categories', () async {
        final searchTerm = 'shop';
        final matchingCategories = [testCategory2];
        when(mockCategoryRepository.getCategories(searchTerm: searchTerm))
            .thenAnswer((_) async => matchingCategories);

        final result = await categoryService.getCategories(searchTerm: searchTerm);

        expect(result, matchingCategories);
        verify(mockCategoryRepository.getCategories(searchTerm: searchTerm)).called(1);
      });

      test('should sort categories in ascending order', () async {
        final sortBy = 'name';
        final sortOrder = 'ASC';
        final sortedCategories = [testCategory1, testCategory2]; // Already sorted
        when(mockCategoryRepository.getCategories(sortBy: sortBy, sortOrder: sortOrder))
            .thenAnswer((_) async => sortedCategories);

        final result = await categoryService.getCategories(sortBy: sortBy, sortOrder: sortOrder);

        expect(result, sortedCategories);
        verify(mockCategoryRepository.getCategories(sortBy: sortBy, sortOrder: sortOrder)).called(1);
      });

      test('should sort categories in descending order', () async {
        final sortBy = 'name';
        final sortOrder = 'DESC';
        final sortedCategories = [testCategory2, testCategory1]; // Reversed order
        when(mockCategoryRepository.getCategories(sortBy: sortBy, sortOrder: sortOrder))
            .thenAnswer((_) async => sortedCategories);

        final result = await categoryService.getCategories(sortBy: sortBy, sortOrder: sortOrder);

        expect(result, sortedCategories);
        verify(mockCategoryRepository.getCategories(sortBy: sortBy, sortOrder: sortOrder)).called(1);
      });

      test('should combine filtering, searching, and sorting', () async {
        final ids = [2];
        final searchTerm = 'shop';
        final sortBy = 'name';
        final sortOrder = 'DESC';
        final combinedResult = [testCategory2];

        when(mockCategoryRepository.getCategories(
          ids: ids,
          searchTerm: searchTerm,
          sortBy: sortBy,
          sortOrder: sortOrder,
        )).thenAnswer((_) async => combinedResult);

        final result = await categoryService.getCategories(
          ids: ids,
          searchTerm: searchTerm,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );

        expect(result, combinedResult);
        verify(mockCategoryRepository.getCategories(
          ids: ids,
          searchTerm: searchTerm,
          sortBy: sortBy,
          sortOrder: sortOrder,
        )).called(1);
      });

      test('should handle exceptions from the repository', () async {
        when(mockCategoryRepository.getCategories())
            .thenThrow(Exception('Database error'));

        expect(() async => await categoryService.getCategories(),
            throwsA(isA<Exception>()));
      });
    });

    // ... other tests (addCategory, updateCategory, deleteCategory)
  });
}
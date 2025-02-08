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
    final testCategory = Category(name: 'Food');

    group('getCategories', () {
      test('should get all categories from repository when searchTerm is null or empty', () async {
        final categories = [testCategory];
        when(mockCategoryRepository.getCategories()).thenAnswer((_) async => categories);
        when(mockCategoryRepository.getCategories(searchTerm: '')).thenAnswer((_) async => categories); // Test with empty string too

        final result1 = await categoryService.getCategories();
        final result2 = await categoryService.getCategories(searchTerm: '');

        expect(result1, categories);
        expect(result2, categories);
        verify(mockCategoryRepository.getCategories()).called(1);
        verify(mockCategoryRepository.getCategories(searchTerm: '')).called(1);
      });

      test('should search categories using searchTerm', () async {
        final searchTerm = 'foo';
        final matchingCategories = [Category(name: 'Food')]; // Matches "Food"
        when(mockCategoryRepository.getCategories(searchTerm: searchTerm))
            .thenAnswer((_) async => matchingCategories);

        final result = await categoryService.getCategories(searchTerm: searchTerm);

        expect(result, matchingCategories);
        verify(mockCategoryRepository.getCategories(searchTerm: searchTerm)).called(1);
      });

        test('should return empty list if no categories match search term', () async {
        final searchTerm = 'nonexistent';
        when(mockCategoryRepository.getCategories(searchTerm: searchTerm))
            .thenAnswer((_) async => []);

        final result = await categoryService.getCategories(searchTerm: searchTerm);

        expect(result, []);
        verify(mockCategoryRepository.getCategories(searchTerm: searchTerm)).called(1);
      });

      test('should handle repository exceptions', () async {
        when(mockCategoryRepository.getCategories()).thenThrow(Exception('Failed to get categories'));

        expect(() async => await categoryService.getCategories(), throwsA(isA<Exception>()));
        verify(mockCategoryRepository.getCategories()).called(1);
      });
    });

    // ... (Tests for addCategory, updateCategory, deleteCategory - these likely don't need changes unless you modified them)
  });
}
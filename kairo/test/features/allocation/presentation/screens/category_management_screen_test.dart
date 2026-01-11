import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_category.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';
import 'package:kairo/features/allocation/presentation/screens/category_management_screen.dart';
import 'package:kairo/features/auth/domain/entities/user_entity.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';
import 'package:mocktail/mocktail.dart';

// Mock providers
class MockAllocationCategoriesNotifier extends AsyncNotifier<List<AllocationCategory>>
    with Mock {
  @override
  Future<List<AllocationCategory>> build() async => [];
}

class MockReorderCategoriesNotifier extends AutoDisposeAsyncNotifier<void>
    with Mock {
  @override
  Future<void> build() async {}
}

class MockDeleteCategoryNotifier extends AutoDisposeAsyncNotifier<void>
    with Mock {
  @override
  Future<void> build() async {}
}

void main() {
  late List<AllocationCategory> mockCategories;
  late MockReorderCategoriesNotifier mockReorderNotifier;

  setUpAll(() {
    registerFallbackValue(
      AllocationCategory(
        id: 'test-id',
        userId: 'test-user-id',
        name: 'Test Category',
        color: '#EF4444',
        icon: 'test',
        isDefault: false,
        displayOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockCategories = [
      AllocationCategory(
        id: 'cat-1',
        userId: 'user-1',
        name: 'Family Support',
        color: '#EF4444',
        icon: 'family',
        isDefault: true,
        displayOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AllocationCategory(
        id: 'cat-2',
        userId: 'user-1',
        name: 'Emergencies',
        color: '#F97316',
        icon: 'emergency',
        isDefault: true,
        displayOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AllocationCategory(
        id: 'cat-3',
        userId: 'user-1',
        name: 'Savings',
        color: '#10B981',
        icon: 'savings',
        isDefault: true,
        displayOrder: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AllocationCategory(
        id: 'cat-4',
        userId: 'user-1',
        name: 'Custom Category',
        color: '#8B5CF6',
        icon: 'custom',
        isDefault: false,
        displayOrder: 4,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    mockReorderNotifier = MockReorderCategoriesNotifier();
  });

  Widget createTestWidget({
    List<AllocationCategory>? categories,
    MockReorderCategoriesNotifier? reorderNotifier,
  }) {
    return ProviderScope(
      overrides: [
        allocationCategoriesProvider.overrideWith(
          (ref) => Future.value(categories ?? mockCategories),
        ),
        currentUserProvider.overrideWith(
          (ref) => Future.value(
            UserEntity(
              id: 'user-1',
              email: 'test@example.com',
              role: 'user',
              profile: UserProfile(
                firstName: 'Test',
                lastName: 'User',
                phoneNumber: '+1234567890',
                dateOfBirth: DateTime(1990, 1, 1),
              ),
              preferences: const UserPreferences(
                notificationsEnabled: true,
                dataShareConsent: false,
                theme: 'system',
              ),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        home: const CategoryManagementScreen(),
      ),
    );
  }

  group('CategoryManagementScreen - Reordering', () {
    testWidgets('should display all categories in order', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify all categories are displayed
      expect(find.text('Family Support'), findsOneWidget);
      expect(find.text('Emergencies'), findsOneWidget);
      expect(find.text('Savings'), findsOneWidget);
      expect(find.text('Custom Category'), findsOneWidget);

      // Verify order by checking positions
      final familyFinder = find.text('Family Support');
      final emergenciesFinder = find.text('Emergencies');
      final familyY = tester.getTopLeft(familyFinder).dy;
      final emergenciesY = tester.getTopLeft(emergenciesFinder).dy;

      expect(familyY, lessThan(emergenciesY));
    });

    testWidgets('should show drag handle for reorderable list', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // ReorderableListView should be present
      expect(find.byType(ReorderableListView), findsOneWidget);
    });

    testWidgets('should display default and custom category badges', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Default categories should show "Default category"
      expect(find.text('Default category'), findsNWidgets(3)); // 3 default categories

      // Custom category should show "Custom category"
      expect(find.text('Custom category'), findsOneWidget);
    });

    testWidgets('should not allow deleting default categories', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find all delete buttons (only custom categories should have them)
      final deleteButtons = find.widgetWithIcon(IconButton, Icons.delete);

      // Should only have 1 delete button (for the custom category)
      expect(deleteButtons, findsOneWidget);
    });

    testWidgets('should show edit button for all categories', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // All 4 categories should have edit buttons
      final editButtons = find.widgetWithIcon(IconButton, Icons.edit);
      expect(editButtons, findsNWidgets(4));
    });

    testWidgets('should display category colors correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find CircleAvatars (category color indicators)
      final avatars = find.byType(CircleAvatar);
      expect(avatars, findsNWidgets(4));
    });

    testWidgets('should show empty state when no categories', (tester) async {
      await tester.pumpWidget(createTestWidget(categories: []));
      await tester.pumpAndSettle();

      expect(find.text('No categories yet'), findsOneWidget);
      expect(find.text('Tap the button below to add your first category'), findsOneWidget);
    });

    testWidgets('should show floating action button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add Category'), findsOneWidget);
    });
  });
}

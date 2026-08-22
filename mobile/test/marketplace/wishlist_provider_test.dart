import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/marketplace/data/models/tool_models.dart';
import 'package:mobile/features/marketplace/presentation/providers/tool_providers.dart';

void main() {
  Tool tool(String id, String name) => Tool.fromJson({
    'id': id,
    'slug': name.toLowerCase(),
    'name': name,
    'category': 'Power tools',
    'description': 'A handy $name.',
    'price': 1000,
    'currency': 'LKR',
    'available': true,
  });

  test('wishlistIdsProvider derives the set of saved tool ids', () async {
    final container = ProviderContainer(
      overrides: [
        wishlistProvider.overrideWith((ref) async => [tool('t1', 'Drill'), tool('t2', 'Ladder')]),
      ],
    );
    addTearDown(container.dispose);

    await container.read(wishlistProvider.future);
    final ids = container.read(wishlistIdsProvider);

    expect(ids, containsAll(['t1', 't2']));
    expect(ids, hasLength(2));
  });

  test('wishlistIdsProvider is empty before data resolves', () {
    final container = ProviderContainer(
      overrides: [
        wishlistProvider.overrideWith((ref) => Future.value([tool('t1', 'Drill')])),
      ],
    );
    addTearDown(container.dispose);

    // Not awaited -> still loading -> empty set (orElse).
    expect(container.read(wishlistIdsProvider), isEmpty);
  });
}

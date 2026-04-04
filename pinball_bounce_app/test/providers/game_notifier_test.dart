import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinball_bounce/presentation/providers/game_notifier.dart';
import 'package:pinball_bounce/presentation/providers/providers.dart';

void main() {
  group('GameNotifier', () {
    test('should provide initial state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(gameProvider);
      expect(state, isNotNull);
    });

    test('notifier should be accessible', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      expect(notifier, isA<GameNotifier>());
    });
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_hooks_test/flutter_hooks_test.dart';
import 'package:mockito/mockito.dart';

import 'hooks/use_counter.dart';
import 'hooks/use_latest.dart';
import 'hooks/use_mount.dart';
import 'hooks/use_update.dart';

class MockEffect extends Mock {
  VoidCallback? call();
}

void main() {
  testWidgets('Not using flutter_hooks_test', (tester) async {
    // Before
    const key = Key('button');
    var buildCount = 0;

    // called count is 1
    await tester.pumpWidget(HookBuilder(builder: (context) {
      final update = useUpdate();
      buildCount++;
      return GestureDetector(
        key: key,
        onTap: () => update(),
      );
    }));
    // called count is 2
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle(const Duration(milliseconds: 1));
    expect(buildCount, 2);
  });

  testWidgets('Using flutter_hooks_test', (tester) async {
    // After
    var buildCount = 0;
    final result = await buildHook((_) {
      buildCount++;
      return useUpdate();
    });

    expect(buildCount, 1);
    final update = result.current;
    await act(() => update());
    expect(buildCount, 2);
  });

  testWidgets('should rebuild after act()', (tester) async {
    final result = await buildHook((_) => useCounter(5));
    await act(() => result.current.inc());
    expect(result.current.value, 6);
  });

  testWidgets('should unmount after unmount()', (tester) async {
    final effect = MockEffect();
    final result = await buildHook((_) => useMount(() => effect()));
    verify(effect()).called(1);
    verifyNoMoreInteractions(effect);
    await result.unmount();
    verifyNever(effect());
    verifyNoMoreInteractions(effect);
  });

  testWidgets('should rebuild after rebuild()', (tester) async {
    final effect = MockEffect();
    final result = await buildHook((_) => useMount(() => effect()));
    await result.rebuild();
    verify(effect()).called(1);
    verifyNoMoreInteractions(effect);
  });

  testWidgets('should rebuild after rebuild() with parameter', (tester) async {
    final result = await buildHook(
      (count) => useLatest(count),
      initialProps: 123,
    );
    expect(result.current, 123);
    await result.rebuild(456);
    expect(result.current, 456);
  });
}

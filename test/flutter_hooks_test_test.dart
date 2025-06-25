import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:flutter_hooks_test/flutter_hooks_test.dart';
import 'package:flutter_test/flutter_test.dart';
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
    final result = await buildHook(
      () {
        buildCount++;
        return useUpdate();
      },
      wrapper: (child) => Container(child: child),
    );

    expect(buildCount, 1);
    final update = result.current;
    await act(() => update());
    expect(buildCount, 2);
  });

  testWidgets('should rebuild after act()', (tester) async {
    final result = await buildHook(() => useCounter(5));
    await act(() => result.current.inc());
    expect(result.current.value, 6);
  });

  testWidgets('should unmount after unmount()', (tester) async {
    final effect = MockEffect();
    final result = await buildHook(
      () => useMount(
        () => effect(),
      ),
    );
    verify(effect()).called(1);
    verifyNoMoreInteractions(effect);
    await result.unmount();
    verifyNever(effect());
    verifyNoMoreInteractions(effect);
  });

  testWidgets('should rebuild after rebuild()', (tester) async {
    final effect = MockEffect();
    final result = await buildHook(() => useMount(() => effect()));
    await result.rebuild();
    verify(effect()).called(1);
    verifyNoMoreInteractions(effect);
  });

  testWidgets('should rebuild after rebuild() with parameter', (tester) async {
    final result = await buildHookWithProps(
      (count) => useLatest(count),
      initialProps: 123,
    );
    expect(result.current, 123);
    await result.rebuildWithProps(456);
    expect(result.current, 456);
  });

  testWidgets('should track build history', (tester) async {
    final result = await buildHook(() => useCounter(0));

    // Initial build
    expect(result.buildCount, 1);
    expect(result.all.length, 1);
    expect(result.all.first.value, 0);

    // Trigger state change and rebuild
    result.current.inc();
    await result.rebuild();

    // History should track the new state
    expect(result.buildCount, 2);
    expect(result.all.length, 2);
    expect(result.all.last.value, 1);
  });

  testWidgets('should provide build count and history', (tester) async {
    final result = await buildHook(() => useCounter(5));

    expect(result.current.value, 5);
    expect(result.buildCount, 1);
    expect(result.all.length, 1);
  });

  testWidgets('should work with new API for props', (tester) async {
    final result = await buildHookWithProps(
      (count) => useLatest(count),
      initialProps: 100,
    );

    expect(result.current, 100);
    await result.rebuildWithProps(200);
    expect(result.current, 200);
  });

  group('waitFor utilities', () {
    testWidgets('waitFor basic functionality demonstration', (tester) async {
      final result = await buildHook(() => useCounter(0));

      // Demonstrate waitFor with immediate condition
      await waitFor(() => result.current.value == 0);
      expect(result.current.value, 0);

      // Increment and wait for the change to be reflected
      await act(() => result.current.inc());
      await waitFor(() => result.current.value == 1);
      expect(result.current.value, 1);
    });

    testWidgets('waitForValueToMatch should work with predicate',
        (tester) async {
      final result = await buildHook(() => useCounter(5));

      // Wait for a condition that's already true
      final value = await result.waitForValueToMatch(
        (counter) => counter.value >= 5,
      );

      expect(value.value, 5);
    });
  });
}

library flutter_hooks_test;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Base class for hook test results providing access to hook state and lifecycle methods.
abstract class HookResult<T> {
  /// The current value returned by the hook.
  T get current;

  /// Rebuilds the hook widget and adds the result to history.
  Future<void> rebuild();

  /// Unmounts the hook widget, triggering cleanup effects.
  Future<void> unmount();

  /// All values returned by the hook after each build.
  /// Each call to rebuild() adds a new entry to this list.
  List<T> get all;

  /// The number of times the hook has been built (length of history).
  int get buildCount => all.length;
}

/// Base implementation for hook results with history tracking.
abstract class _BaseHookResult<T> extends HookResult<T> {
  _BaseHookResult(this._current, this._unmount) {
    _addToHistory();
  }

  final T Function() _current;
  final Future<void> Function() _unmount;
  final List<T> _all = [];

  @override
  T get current => _current();

  @override
  List<T> get all => List.unmodifiable(_all);

  @override
  Future<void> unmount() => _unmount();

  /// Adds the current hook value to build history.
  /// Called automatically during construction and rebuild operations.
  void _addToHistory() {
    final value = _current();
    // Always add to history on rebuild to track state changes
    _all.add(value);
  }
}

/// Result for hooks without props.
class _SimpleHookResult<T> extends _BaseHookResult<T> {
  _SimpleHookResult(super.current, this._rebuild, super.unmount);

  final Future<void> Function() _rebuild;

  @override
  Future<void> rebuild() async {
    await _rebuild();
    _addToHistory();
  }
}

/// Result for hooks with props.
class HookResultWithProps<T, P> extends _BaseHookResult<T> {
  HookResultWithProps(
      super.current, this._rebuildWithProps, super.unmount, this._initialProps);

  final Future<void> Function(P props) _rebuildWithProps;
  final P _initialProps;

  @override
  Future<void> rebuild() async {
    await _rebuildWithProps(_initialProps);
    _addToHistory();
  }

  /// Rebuilds the hook with different props and updates history.
  Future<void> rebuildWithProps(P props) async {
    await _rebuildWithProps(props);
    _addToHistory();
  }
}

/// Default empty widget used as a placeholder in hook tests.
const Widget _kEmptyWidget = SizedBox.shrink();

/// Applies a wrapper to a child widget, or returns the child if no wrapper is provided.
Widget _applyWrapper(Widget child, Widget Function(Widget)? wrapper) {
  return wrapper?.call(child) ?? child;
}

/// Creates a test harness for a hook that doesn't require props.
Future<HookResult<T>> buildHook<T>(
  T Function() hook, {
  Widget Function(Widget child)? wrapper,
}) async {
  late T result;

  Widget builder() {
    return HookBuilder(builder: (context) {
      result = hook();
      return _kEmptyWidget;
    });
  }

  final wrappedBuilder = _applyWrapper(builder(), wrapper);
  await _build(wrappedBuilder);

  Future<void> rebuild() => _build(_applyWrapper(builder(), wrapper));
  Future<void> unmount() => _build(_kEmptyWidget);

  return _SimpleHookResult<T>(() => result, rebuild, unmount);
}

/// Creates a test harness for a hook that requires props.
Future<HookResultWithProps<T, P>> buildHookWithProps<T, P>(
  T Function(P props) hook, {
  required P initialProps,
  Widget Function(Widget child)? wrapper,
}) async {
  late T result;

  Widget builder(P props) {
    return HookBuilder(builder: (context) {
      result = hook(props);
      return _kEmptyWidget;
    });
  }

  final wrappedBuilder = _applyWrapper(builder(initialProps), wrapper);
  await _build(wrappedBuilder);

  Future<void> rebuildWithProps(P props) =>
      _build(_applyWrapper(builder(props), wrapper));
  Future<void> unmount() => _build(_kEmptyWidget);

  return HookResultWithProps<T, P>(
      () => result, rebuildWithProps, unmount, initialProps);
}

const String _kDeprecationMessage =
    'Use buildHook(() => hook()) for hooks without props '
    'or buildHookWithProps((props) => hook(props), initialProps: props) for hooks with props';

/// Deprecated: Use buildHook() or buildHookWithProps() instead.
@Deprecated(_kDeprecationMessage)
// ignore: library_private_types_in_public_api
Future<_HookTestingAction<T, P>> buildHookLegacy<T, P>(
  T Function(P? props) hook, {
  P? initialProps,
  Widget Function(Widget child)? wrapper,
}) async {
  late T result;

  Widget builder([P? props]) {
    return HookBuilder(builder: (context) {
      result = hook(props);
      return _kEmptyWidget;
    });
  }

  final wrappedBuilder = _applyWrapper(builder(initialProps), wrapper);
  await _build(wrappedBuilder);

  Future<void> rebuild([P? props]) =>
      _build(_applyWrapper(builder(props), wrapper));
  Future<void> unmount() => _build(_kEmptyWidget);

  return _HookTestingAction<T, P>(() => result, rebuild, unmount);
}

Future<void> act(void Function() fn) {
  return TestAsyncUtils.guard<void>(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    fn();
    binding.scheduleFrame();
    return binding.pump();
  });
}

/// Waits for a condition to become true by repeatedly pumping the widget tree.
///
/// This function checks the [condition] after each pump until it returns true.
/// Use this to wait for asynchronous state changes in your hooks.
///
/// Example:
/// ```dart
/// await waitFor(() => result.current.value > 5);
/// ```
Future<void> waitFor(bool Function() condition) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  while (!condition()) {
    await binding.pump();
  }
}

/// Waits for a value to change by comparing with its initial state.
///
/// Captures the current value and waits until [getValue] returns a different value.
///
/// Example:
/// ```dart
/// await waitForValueToChange(() => result.current.count);
/// ```
Future<T> waitForValueToChange<T>(T Function() getValue) async {
  final initialValue = getValue();
  await waitFor(() => getValue() != initialValue);
  return getValue();
}

/// Extension methods for HookResult to provide additional waiting utilities
extension HookResultWaitExtensions<T> on HookResult<T> {
  /// Waits for the next update to occur on this hook result.
  ///
  /// This method waits until the build count increases, indicating that
  /// the hook has been rebuilt.
  ///
  /// Example:
  /// ```dart
  /// await act(() => result.current.increment());
  /// await result.waitForNextUpdate();
  /// ```
  Future<void> waitForNextUpdate() async {
    final currentBuildCount = buildCount;
    await waitFor(() => buildCount > currentBuildCount);
  }

  /// Waits for the current value to change.
  ///
  /// This method captures the current value and waits until it changes
  /// to a different value.
  ///
  /// Example:
  /// ```dart
  /// await act(() => result.current.increment());
  /// await result.waitForValueToChange();
  /// ```
  Future<T> waitForValueToChange() async {
    final initialValue = current;
    await waitFor(() => current != initialValue);
    return current;
  }

  /// Waits for a specific condition to be met on the current value.
  ///
  /// This method repeatedly checks the current value against the provided
  /// predicate until it returns true.
  ///
  /// Example:
  /// ```dart
  /// await act(() => result.current.increment());
  /// await result.waitForValueToMatch((value) => value > 10);
  /// ```
  Future<T> waitForValueToMatch(bool Function(T value) predicate) async {
    await waitFor(() => predicate(current));
    return current;
  }
}

/// Legacy class for backward compatibility
@Deprecated('Use HookResult<T> or HookResultWithProps<T, P> instead')
class _HookTestingAction<T, P> {
  const _HookTestingAction(this._current, this.rebuild, this.unmount);

  /// The current value of the result will reflect the latest of whatever is
  /// returned from the callback passed to buildHook.
  final T Function() _current;
  T get current => _current();

  /// Rebuilds the test widget with optional new props.
  final Future<void> Function([P? props]) rebuild;

  /// Unmounts the test widget, triggering cleanup effects.
  final Future<void> Function() unmount;
}

Future<void> _build(Widget widget) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  return TestAsyncUtils.guard<void>(() {
    binding.attachRootWidget(binding.wrapWithDefaultView(widget));
    binding.scheduleFrame();
    return binding.pump();
  });
}

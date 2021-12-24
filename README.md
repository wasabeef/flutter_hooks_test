<div align="center">
    <h1>Flutter Hooks Testing Library</h1>
    <a href="https://www.emojione.com">
    <br />
    <br />
    <img
        height="128"
        width="128"
        alt="fishing pole"
        src="https://raw.githubusercontent.com/wasabeef/flutter_hooks_test/main/art/fishing_pole.gif?token=AAN7UAVEVOSUHLYWSWALQDDBZ2KTG" />
    </a>
    <br />
    <br />
    <p>Simple and complete Flutter hooks testing utilities that encourage good testing practices.</p>
    <br />
    <strong>Inspired by <a href="https://react-hooks-testing-library.com/">react-hooks-testing-library</a>.</strong>
    <br />
    <br />
    <br />
    <a href="https://pub.dev/packages/flutter_lints">
      <img src="https://img.shields.io/badge/style-flutter__lints-40c4ff.svg" alt="flutter_lints" />
    </a>
</div>

## The first thing

This package respect [react-hooks-testing-library](https://github.com/testing-library/react-hooks-testing-library) so much. so the idea is based on that.

## The problem

You're writing an awesome custom hook and you want to test it, but as soon as you call it you see
the following error:

> Invariant Violation: Hooks can only be called inside the body of a function component.

You don't really want to write a component solely for testing this hook and have to work out how you
were going to trigger all the various ways the hook can be updated, especially given the
complexities of how you've wired the whole thing together.

## The solution

The `Flutter Hooks Testing Library` allows you to create a simple test harness for Flutter hooks that
handles running them within the body of a function component, as well as providing various useful
utility functions for updating the inputs and retrieving the outputs of your amazing custom hook.
This library aims to provide a testing experience as close as possible to natively using your hook
from within a real component.

Using this library, you do not have to concern yourself with how to construct, render or interact
with the flutter component in order to test your hook. You can just use the hook directly and assert
the results.

## When to use this library

1. You're writing a library with one or more custom hooks that are not directly tied to a component
2. You have a complex hook that is difficult to test through component interactions

## When not to use this library

1. Your hook is defined alongside a component and is only used there
2. Your hook is easy to test by just testing the components using it



## Installation

```sh
flutter pub add flutter_use
```

## Example

### `use_update.dart`

```dart
VoidCallback useUpdate() {
  final attempt = useState(0);
  return () => attempt.value++;
}
```

### `use_update_test.dart`

**Not using**
```dart
testWidgets('should re-build component each time returned function is called', (tester) async {
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
```

**Using**

```dart
testWidgets('should re-build component each time returned function is called', (tester) async {
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
```

## Issues

Please file [Flutter Hooks Testing Library](https://github.com/wasabeef/flutter_hooks_test) specific issues, bugs, or feature requests in our [issue tracker](https://github.com/wasabeef/flutter_hooks_test/issues/new).

Plugin issues that are not specific to [Flutter Hooks Testing Library](https://github.com/wasabeef/flutter_hooks_test) can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

## Contributing

If you wish to contribute a change to any of the existing plugins in this repo,
please review our [contribution guide](https://github.com/wasabeef/flutter_hooks_test/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/wasabeef/flutter_hooks_test/pulls).

## 1.0.0

**Feature**

- Update flutter_hooks to "^0.21.2"

**Development**

- Update to Melos 6.3.3

## 0.0.7+1

**Development**

- Update some documents

## 0.0.6, 0.0.7

**Feature**

- [#40](https://github.com/wasabeef/flutter_hooks_test/pull/40) Add a parameter "wrapper" to allow adding providers to hooks. by [@KalSat](https://github.com/KalSat)

  ```dart
  final result = await buildHook(
    (_) {
      buildCount++;
      return useUpdate();
    },
    wrapper: (child) => Container(child: child), // this
  );
  ```

- Update Flutter to ">=3.20.0"
- Update flutter_hooks to ">=0.20.0"

## 0.0.5

**Feature**

- [#35](https://github.com/wasabeef/flutter_hooks_test/pull/35) Support Flutter 3.16.0.

## 0.0.3, 0.0.4

**Feature**

- Update Dart to ">=2.17.0 <4.0.0"
- Update Flutter to ">=3.0.0"
- Update flutter_hooks to ">=0.18.0"

**Development**

- Update to Melos 3.0.1

## 0.0.1, 0.0.2

initial release.

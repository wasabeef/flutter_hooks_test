# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter Hooks Test is a testing utility library for Flutter hooks, inspired by React's `react-hooks-testing-library`. It provides a simple API to test custom hooks in isolation.

## Development Commands

### Essential Commands

```bash
# Install dependencies
melos get
bun install

# Run tests
melos test

# Run code analysis
melos analyze

# Format code (Dart + Prettier)
melos format

# Run all checks (analyze + format + test)
melos analyze && melos format && melos test

# Run a single test file
flutter test test/flutter_hooks_test_test.dart

# Run tests with coverage
flutter test --coverage
```

### Additional Commands

```bash
# Upgrade dependencies
melos upgrade

# Clean build artifacts
melos clean

# Format with Prettier only
bun run format

# Setup git hooks
bun run prepare
```

## Architecture and Code Structure

### Core API (v2.0.0)

The library exports a single file `lib/flutter_hooks_test.dart` containing:

1. **`buildHook<T>()`** - Test hooks without props
   - Generic `T`: Return type of the hook
   - Returns `HookResult<T>` with methods:
     - `current`: Access current hook value
     - `rebuild()`: Trigger rebuild and update history
     - `unmount()`: Unmount the hook
     - `all`: Build history for debugging
     - `buildCount`: Number of builds

2. **`buildHookWithProps<T, P>()`** - Test hooks with props
   - Generic `T`: Return type, `P`: Props type
   - Returns `HookResultWithProps<T, P>` with additional:
     - `rebuildWithProps(P props)`: Rebuild with new props

3. **`act`** - Wraps state changes to ensure proper Flutter test lifecycle

4. **`waitFor` utilities** - Async testing helpers
   - `waitFor(condition)`: Wait for condition to be true
   - `waitForValueToChange(getValue)`: Wait for value change
   - `result.waitForNextUpdate()`: Wait for hook rebuild
   - `result.waitForValueToMatch(predicate)`: Wait for specific condition
   - Similar to React's `act` function
   - Required when changing hook state

### Testing Patterns (v2.0.0)

```dart
// Basic hook test (no props)
final result = await buildHook(() => useMyHook());
await act(() => result.current.doSomething());
expect(result.current.value, expectedValue);

// Hook with props
final result = await buildHookWithProps(
  (count) => useCounter(count),
  initialProps: 5,
);
await result.rebuildWithProps(10);
expect(result.current.value, 10);

// With wrapper widget
final result = await buildHook(
  () => useMyHook(),
  wrapper: (child) => Provider(child: child),
);

// Async testing with waitFor
await act(() => result.current.startAsync());
await waitFor(() => !result.current.isLoading);
expect(result.current.data, isNotNull);

// History tracking
expect(result.buildCount, 1);
expect(result.all.length, 1);
await result.rebuild();
expect(result.buildCount, 2);
```

### Internal Implementation (v2.0.0)

- Uses `TestWidgetsFlutterBinding` for test environment
- Creates minimal widget tree with `HookBuilder`
- `_BaseHookResult<T>` base class eliminates code duplication
- Build history tracking with automatic value capture
- Separate result classes for hooks with/without props
- Helper functions (`_applyWrapper`) and constants (`_kEmptyWidget`)

## Testing Approach

- All tests go in `test/` directory
- Example hooks in `test/hooks/` demonstrate testable patterns
- Use `testWidgets` for widget-based tests
- Use Mockito for mocking dependencies

## Code Quality

- Flutter lints are enforced via `analysis_options.yaml`
- Example directory is excluded from analysis
- Pre-commit hooks format code automatically
- CI runs on Ubuntu with asdf version management

## Important Conventions (v2.0.0)

1. **API Selection**: Use `buildHook()` for hooks without props, `buildHookWithProps()` for hooks with props
2. **Type Safety**: Generic types are automatically inferred in most cases
3. **Act Wrapper**: Always wrap state changes in `act()`
4. **Async Testing**: Use `waitFor` utilities for async operations
5. **History Tracking**: Use `result.all` and `result.buildCount` for debugging
6. **Rebuilds**: Call `rebuild()` after state changes to update history
7. **Testing**: Test mount/unmount/rebuild scenarios and async state changes

## Version Requirements

- Dart SDK: `>=2.17.0 <4.0.0`
- Flutter: `>=3.20.0`
- Uses Flutter hooks `^0.21.2`

## Release Process (v2.0.0+)

Releases are fully automated via GitHub Actions with OIDC authentication:

### Creating a Release

1. **Update version**: Update version in `pubspec.yaml`
2. **Commit changes**: `git commit -am "chore: bump version to v2.0.1"`
3. **Create tag**: `git tag v2.0.1`
4. **Push**: `git push origin main --tags`

Changelog is automatically generated from conventional commits.

### Automated Release Steps

When a tag matching `v[0-9]+.[0-9]+.[0-9]+*` is pushed:

1. **Environment Setup**: Flutter, Dart, Bun, and Melos
2. **Dependencies**: Install and bootstrap packages with Melos and Bun
3. **CI Validation**: All tests, formatting, and analysis must pass
4. **Dry Run**: Package publication tested with OIDC authentication
5. **Release Notes**: Auto-generated using git-cliff from conventional commits
6. **GitHub Release**: Created with generated release notes
7. **pub.dev Publication**: Published automatically with OIDC (no token required)

### Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/) for automatic release note generation:

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `test:` - Test improvements
- `refactor:` - Code refactoring
- `perf:` - Performance improvements

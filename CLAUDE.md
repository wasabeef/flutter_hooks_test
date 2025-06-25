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

### Core API

The library exports a single file `lib/flutter_hooks_test.dart` containing:

1. **`buildHook<T, P>`** - Main function to test hooks

   - Generic `T`: Return type of the hook
   - Generic `P`: Props type for parameterized hooks
   - Returns `_HookTestingAction<T>` with methods:
     - `current`: Access current hook value
     - `rebuild([props])`: Trigger rebuild with optional new props
     - `unmount()`: Unmount the hook

2. **`act`** - Wraps state changes to ensure proper Flutter test lifecycle
   - Similar to React's `act` function
   - Required when changing hook state

### Testing Pattern

```dart
// Basic hook test structure
final result = await buildHook((_) => useMyHook());
await act(() => result.current.doSomething());
expect(result.current.value, expectedValue);

// With wrapper widget
final result = await buildHook(
  (_) => useMyHook(),
  wrapper: (child) => Provider(child: child),
);
```

### Internal Implementation

- Uses `TestWidgetsFlutterBinding` for test environment
- Creates a minimal widget tree with `HookBuilder`
- Manages completer-based async operations for mount/unmount
- Preserves hook state across rebuilds using keys

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

## Important Conventions

1. **Type Safety**: Always specify generic types when using `buildHook`
2. **Act Wrapper**: Always wrap state changes in `act()`
3. **Async Handling**: Most operations return Futures - use `await`
4. **Testing**: Test both happy paths and edge cases (mount/unmount/rebuild)

## Version Requirements

- Dart SDK: `>=2.17.0 <4.0.0`
- Flutter: `>=3.20.0`
- Uses Flutter hooks `^0.21.2`

## Release Process

Releases are fully automated via GitHub Actions:

### Creating a Release

1. **Update version**: Update version in `pubspec.yaml`
2. **Update changelog**: Run `git cliff --unreleased --tag v1.0.1 --output CHANGELOG.md`
3. **Commit changes**: `git commit -am "chore(release): prepare for v1.0.1"`
4. **Create tag**: `git tag v1.0.1`
5. **Push**: `git push origin main --tags`

### Automated Release Steps

When a tag matching `v[0-9]+.[0-9]+.[0-9]+*` is pushed:

1. **CI Validation**: All tests, formatting, and analysis must pass
2. **Dry Run**: Package publication is tested
3. **Release Notes**: Auto-generated using git-cliff from conventional commits
4. **GitHub Release**: Created with generated release notes
5. **pub.dev Publication**: Package is published automatically

### Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/) for automatic release note generation:

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `test:` - Test improvements
- `refactor:` - Code refactoring
- `perf:` - Performance improvements

import 'package:flutter/foundation.dart';

import 'use_effect_once.dart';

/// Flutter lifecycle hook that calls a function after the component is mounted.
/// Use useLifecycles if you need both a mount and unmount function.
void useMount(VoidCallback fn) {
  return useEffectOnce(() {
    fn();
    return;
  });
}

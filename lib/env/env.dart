//lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@envied
abstract class Env {
    @EnviedField(varName: 'KEY')
    static const String key = _Env.key;
}
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
final class Env {
  @EnviedField(varName: 'apiKey')
  static const String apiKey = _Env.apiKey;
}

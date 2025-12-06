import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Currently empty, but good practice for dependency injection if needed later.
final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  // $initGetIt(getIt);
}

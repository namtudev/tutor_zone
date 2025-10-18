// Default entry point - runs the dev flavor
// For different flavors, use:
// - flutter run                          (dev, default)
// - flutter run -t lib/main_staging.dart (staging)
// - flutter run -t lib/main_prod.dart    (production)
import 'package:tutor_zone/main_dev.dart' as main_dev;

Future<void> main() async {
  await main_dev.main();
}

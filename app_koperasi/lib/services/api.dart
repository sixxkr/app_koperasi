import 'package:universal_platform/universal_platform.dart';

String get baseUrl {
  if (UniversalPlatform.isWeb) {
    return 'http://localhost:5000'; // untuk Web
  } else if (UniversalPlatform.isAndroid) {
    return 'http://10.0.2.2:5000'; // Android emulator
  } else if (UniversalPlatform.isIOS) {
    return 'http://localhost:5000'; // iOS emulator
  } else {
    return 'http://localhost:5000'; // fallback untuk device lain
  }
}

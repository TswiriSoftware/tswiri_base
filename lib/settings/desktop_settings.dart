import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global_settings.dart';

export 'package:tswiri_base/settings/global_settings.dart';

Future<void> loadDesktopSettings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  //Default barcode size.
  defaultBarcodeSize =
      prefs.getDouble(defaultBarcodeSizePref) ?? defaultBarcodeSize;

  //Color Mode.
  colorModeEnabled = prefs.getBool(colorModeEnabledPref) ?? false;

  //Spaces
  currentSpacePath = prefs.getString(currentSpacePathPref) ??
      '${(await getApplicationSupportDirectory()).path}/main_space';
}

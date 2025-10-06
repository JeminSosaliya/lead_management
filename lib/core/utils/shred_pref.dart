import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

final SharedPreference preferences = SharedPreference();

class SharedPreference {
  SharedPreferences? _preferences;

  static const String isLogIn = "isLogIn";
  static const String uid = "uid";
  // static const String role = "role";
  static const String email = "email";

  static const String deviceType = "deviceType";
  static const String appStoreVersion = "App-Store-Version";
  static const String appDeviceName = "App-Device-Name";
  static const String appDeviceId = "App-Device-Id";
  static const String macAddress = "Mac-Address";
  static const String appOsVersion = "App-Os-Version";
  static const String appStoreBuildNumber = "App-Store-Build-Number";


  init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  bool getBool(String key, {bool defValue = false}) {
    return _preferences == null
        ? defValue
        : _preferences!.getBool(key) ?? defValue;
  }

  Future<void> putAppDeviceInfo() async {
    bool isiOS = Platform.isIOS;
    putString(deviceType, isiOS ? "iOS" : "Android");
    var deviceInfo = await appDeviceInfo();

    // PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // if (isiOS) {
    //   IosDeviceInfo iosDeviceInfo = (deviceInfo as IosDeviceInfo);
    //   putString(appDeviceName, deviceInfo.name);
    //   putString(appOsVersion, "iOS ${iosDeviceInfo.systemVersion}");
    //   putString(appDeviceId, iosDeviceInfo.identifierForVendor ?? "");
    //   putString(macAddress, "");
    // } else {
    //   AndroidDeviceInfo androidDeviceInfo = (deviceInfo as AndroidDeviceInfo);
    //   putString(appDeviceName, androidDeviceInfo.model);
    //   putString(appOsVersion, androidDeviceInfo.version.release);
    //   putString(appDeviceId, androidDeviceInfo.id);
    // }
    // putString(appStoreVersion, packageInfo.version);
    // putString(appStoreBuildNumber, packageInfo.buildNumber);
  }

  Future<dynamic> appDeviceInfo() async {
    // return Platform.isIOS
    //     ? await DeviceInfoPlugin().iosInfo
    //     : await DeviceInfoPlugin().androidInfo;
  }

  void clearUserItem() async {
    _preferences?.clear();
    _preferences = null;
    await init();
    await putAppDeviceInfo();
    // putBool(isOnboarding, true);
    // Get.offAllNamed(AppRoutes.login);
  }

  Future<bool?> putString(String key, String value) async {
    return _preferences!.setString(key, value);
  }

  Future<bool?> putList(String key, List<String> value) async {
    return _preferences?.setStringList(key, value);
  }

  List<String>? getList(String key, {List<String> defValue = const []}) {
    return _preferences == null
        ? defValue
        : _preferences?.getStringList(key) ?? defValue;
  }

  String? getString(String key, {String defValue = ""}) {
    return _preferences == null
        ? defValue
        : _preferences?.getString(key) ?? defValue;
  }

  Future<bool?> putInt(String key, int value) async {
    return _preferences?.setInt(key, value);
  }

  int? getInt(String key, {int defValue = 0}) {
    return _preferences == null
        ? defValue
        : _preferences?.getInt(key) ?? defValue;
  }

  Future<bool?> putDouble(String key, double value) async {
    return _preferences?.setDouble(key, value);
  }

  double getDouble(String key, {double defValue = 0.0}) {
    return _preferences == null
        ? defValue
        : _preferences?.getDouble(key) ?? defValue;
  }

  Future<bool?> putBool(String key, bool value) async {
    return _preferences?.setBool(key, value);
  }
}

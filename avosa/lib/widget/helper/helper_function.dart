import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  // keys
  static String setName = "LoggedName";
  static String setPassword = "LoggedPassword";
  static String setDatabaseName = "DatabaseName";
  static String setMobileNumber = "MobileNumber";
  static String userRememberKey = "RememberKey";
  static String userTokenExpires = "TokenExpires";
  static String userLoggedInkey = "LoggedInKey";
  static String userLoginIdkey = "LoginIdKey";
  static String userAuthTokenKey = "AuthToken";
  static String userLanguageKey = "UserLanguage";
  static String userLanguagesKey = "UserLanguages";
  static String userMinistryIdKey = "MinistryIdKey";
  static String userMinistryIdsKey = "MinistryIdsKey";
  static String userIdKey = "IdKey";
  static String userIdsKey = "IdsKey";
  static String userNameKey = "NameKey";
  static String userRoleKey = "RoleKey";
  static String isReadKey = "ReadKey";

  // Saving the data to Shared Preferences
  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInkey, isUserLoggedIn);
  }

  // Getting the data to Shared Preferences
  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInkey);
  }

  static Future getUserLoggedOutStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.clear();
  }

  static setUserLoginSF(isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool('userLoggedInkey', isUserLoggedIn);
  }

  static setAuthTokenSF(authToken) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userAuthTokenKey', authToken);
  }

  static setUserRememberSF(isUserRemember) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool('userRememberKey', isUserRemember);
  }

  static setNameSF(name) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('setName', name);
  }

  static setPasswordSF(password) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('setPassword', password);
  }

  static setDatabaseNameSF(databaseName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('setDatabaseName', databaseName);
  }

  static setMobileNumberSF(mobile) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('setMobileNumber', mobile);
  }

  static setTokenExpiresSF(tokenExpires) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userTokenExpires', tokenExpires);
  }

  static setLoginIdSF(loginId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userLoginIdkey', loginId);
  }

  static setUserNameSF(userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userNameKey', userName);
  }

  static setUserRoleSF(userRole) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userRoleKey', userRole);
  }

  static setUserImageSF(userImage) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userImageKey', userImage);
  }

  static setUserEmailSF(userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userEmailKey', userEmail);
  }

  static setUserMobileSF(userMobile) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userMobileKey', userMobile);
  }

  static setUserLanguageSF(userLanguageId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userLanguageKey', userLanguageId);
  }

  static setUserLanguagesSF(userLanguageIds) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userLanguagesKey', userLanguageIds);
  }

  static setMinistryIdSF(ministryId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userMinistryIdKey', ministryId);
  }

  static setMinistryIdsSF(ministryIds) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userMinistryIdsKey', ministryIds);
  }

  static setUserIdSF(userId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userIdKey', userId);
  }

  static setUserIdsSF(userIds) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userIdsKey', userIds);
  }

  static setNotificationReadSF(isNotificationRead) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool('isReadKey', isNotificationRead);
  }
}

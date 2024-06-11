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
  static String userDioceseKey = "UserDiocese";
  static String userDiocesesKey = "UserDioceses";
  static String userParishKey = "UserParish";
  static String userMemberIdKey = "MemberIdKey";
  static String userMemberIdsKey = "MemberIdsKey";
  static String userFamilyIdKey = "FamilyIdKey";
  static String userFamilyIdsKey = "FamilyIdsKey";
  static String userBCCIdKey = "FamilyIdKey";
  static String userBCCIdsKey = "FamilyIdsKey";
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

  static setUserDioceseSF(userDiocese) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userDioceseKey', userDiocese);
  }

  static setUserDiocesesSF(userDiocese) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userDiocesesKey', userDiocese);
  }

  static setUserParishSF(userParish) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userParishKey', userParish);
  }

  static setFamilyIdSF(familyId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userFamilyIdKey', familyId);
  }

  static setFamilyIdsSF(familyIds) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userFamilyIdsKey', familyIds);
  }

  static setBCCIdSF(bccId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userBCCIdKey', bccId);
  }

  static setBCCIdsSF(bccIds) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userBCCIdsKey', bccIds);
  }

  static setZoneIdSF(zoneId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userZoneIdKey', zoneId);
  }

  static setZoneIdsSF(zoneIds) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userZoneIdsKey', zoneIds);
  }

  static setMemberIdSF(memberId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userMemberIdKey', memberId);
  }

  static setMemberIdsSF(memberIds) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userMemberIdsKey', memberIds);
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

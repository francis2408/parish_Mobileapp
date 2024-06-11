// Test Server
// const baseUrl = 'http://104.156.60.120:3000/api';
// String db = 'cristo_uae_sep5_2023';
// Live Server
const baseUrl = 'https://cristo.avosa.org/api';
const db = 'cristo_uae_live';

// Static Values
String parishID = '15';

// Headers
var headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Cookie': 'session_id=c56cc4b7133e65db5cfc736403080a84d7675045'
};

var header = {
  'Authorization': authToken,
  'Content-Type': 'application/json',
  'Accept': 'application/json'
};

// Current Date Time 
DateTime currentDateTime = DateTime.now();

// Token Expire Time
DateTime? expiryDateTime;

// Login
bool isSignedIn = false;
String userName = '';
String userImage = '';
String userRole = '';
String tokenExpire = '';
String authToken = '';
var DioceseId;
var memberId;
var userId;
var superiorId;
var databaseName;
bool appbarVisible = false;
String loginID = '';

// Home
List bannerImage = [];

// Read Notification Count
var unReadNotificationCount;
var unReadNewsCount;
var unReadEventCount;
var unReadCircularCount;

// App Version
var curentVersion;
var latestVersion;
var updateAvailable;

// Login
String loginName = '';
String loginEmail = '';
String loginPassword = '';
String deviceName = '';
String mobileNumber = '';
String deviceToken = '';
bool? remember;

// Local Variable
String userMember = '';

// ForgotPassword
String userEmail = '';
String userMobile = '';
String userLanguage = '';
String userLanguageName = '';
String userMinistry = '';
String userMinistryName = '';

// Notification
var notificationId;
String notificationName = '';
String notificationDate = '';
String notificationMessage = '';
int notificationCount = 0;
var read;

// Event
String selectedTab = 'All';

// Location
var destinationLatitude;
var destinationLongitude;
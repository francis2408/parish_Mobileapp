// Test Server
const baseUrl = 'http://demo.parish.cristolive.org/api';
String db = 'parish_diocese_test';
// Live Server
// const baseUrl = 'http://parish.cristolive.org/api';
// const db = 'parish_diocese_live_v3';

// Static Values
String parishID = '22032';

// Headers
var headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Cookie': 'session_id=c56cc4b7133e65db5cfc736403080a84d7675045'
};

var sendHeader = {
  'Content-Type': 'application/json',
  'Cookie': 'session_id=7ff391441382398eed92720e69294cbe6050b1b9'
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
const KDefaultPadding = 28.0;
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
String loginPassword = '';
String deviceName = '';
String mobileNumber = '';
String deviceToken = '';
String myProfile = '';
bool? remember;

// Local Variable
String userMember = '';
String institution = '';
String house = '';

// ForgotPassword
String userLogin = '';
String userEmail = '';

// News
var newsID;

// Notification
var notificationId;
String notificationName = '';
int notificationCount = 0;
var read;

// Obituary
var obituaryCount;
var obituaryTab = 'Upcoming';

// Celebration
var celebrationTab = 'Birthday';

// Birthday
var birthdayCount;
var feastdayCount;
var birthdayTab = 'Upcoming';
var feastTab = 'Upcoming';

// Ordination
var ordinationTab = 'Upcoming';
var ordinationCount;

// Circular
var letterTab = 'Circular';
var circularID;
var letterID;
String circularName = '';
String letterName = '';
String localPath = '';
var fileName;

// Event
var eventID;
var deleteID;
String selectedTab = 'All';
String requestTab = 'Parishioner';
int eventPage = 0;
int eventLimit = 20;

// House
var houseID;
String houseName = '';
var houseMemberId;
String houseMemberName = '';
var houseTab;

// Institute
var instituteID;
String instituteName = '';

// Commission
var commissionID;

// Member
var id;
String name = '';
String memberSelectedTab = 'All';
var communityId;

// Education
var educationId;

// Emergency
var emergencyId;

// Family
var familyId;
var familyIds;

// Holy order
var holyOrderId;

// Formation
var formationId;

// Statutory
var statutoryId;

// Publication
var publicationId;

// Profession
var professionId;

// Document View
String field = '';

// Province
var provinceTab = 'Profile';

// Zone
var zoneId;

// BCC
var bccId;

// Gallery
String galleryId = '';

// Bible
var englishNew;
var englishOld;
var bookId;
var bookName = '';
var chapterId;
List chapter = [];
List separatedValues = [];
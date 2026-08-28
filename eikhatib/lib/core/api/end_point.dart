class EndPoint {
  static const String markRead = 'notifications/mark_read.php';

  // Use 10.0.2.2 for Android Emulator, or adjust to your local IP for physical devices:
  // static const String baseUrl = 'http://192.168.1.6:5000/api/';
  // static const String imageBaseUrl = 'http://192.168.1.6:5000';
  static const String baseUrl = "http://153.75.246.8:5000/api/";

  static const String imageBaseUrl = "http://153.75.246.8:5000";
  // Auth Endpoints
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resendOtp = 'auth/resend-otp';
  static const String getProfile = 'auth/profile';
  static const String refreshToken = 'auth/refresh-token';
  static const String logout = 'auth/logout';
  static const String deleteAccount = 'auth/delete-account';
  static const String getAllDrivers = 'auth/drivers';

  // Address Endpoints
  static const String addresses = 'addresses';
  static String deleteAddress(String id) => 'addresses/$id';

  // Home Endpoints
  static const String home = 'home';

  // Categories & Products Endpoints
  static const String categories = 'categories';
  static const String products = 'products';
  static const String cart = 'cart';
  static const String orders = 'orders';
  static const String driverAvailable = 'orders/driver/available';
  static const String driverMyOrders = 'orders/driver/my-orders';
  static String acceptOrder(String id) => 'orders/$id/accept';
  static String updateOrderStatus(String id) => 'orders/$id/status';
  static String updateLocation(String id) => 'orders/$id/location';
  static const String uploadDriverDocuments = 'auth/driver/upload-documents';

  static const String googleLogin = 'auth/google_login';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetStatus = 'auth/reset-status';
  static const String resetPassword = 'auth/reset-password';
  static const String getComments = 'comments';
  static const String getLibrary = 'library';
  static const String updateProfile = 'members'; // members/:id
  static const String uploadAvatar = 'members'; // members/:id/avatar
  static const String uploadBanner = 'members'; // members/:id/banner

  // Device management
  static const String myDevices = 'devices/my';
  static const String requestDevice = 'devices/request';
  static String memberDevices(String memberId) => 'devices/$memberId';
  static String approveDevice(String memberId, String deviceDbId) =>
      'devices/$memberId/approve/$deviceDbId';
  static String rejectDevice(String memberId, String deviceDbId) =>
      'devices/$memberId/reject/$deviceDbId';
  static String deleteMyDevice(String deviceDbId) => 'devices/my/$deviceDbId';
  static String deleteDeviceAdmin(String memberId, String deviceDbId) =>
      'devices/$memberId/$deviceDbId';

  // Captain/Teacher sections
  static const String captainStats = 'captain/stats';
  static const String captainCourses = 'captain/courses';
  static const String captainAnnouncements = 'captain/announcements';
  static const String captainWithdrawals = 'captain/withdrawals';
  static const String paymentMethods = 'payment-methods';

  // System / Help Center Endpoints
  static const String contactLinks = 'system/contact-links';
  static const String submitSupport = 'system/support';

  // Security / 2FA Endpoints
  static const String toggle2FA = 'auth/2fa';
  static const String sendOtpSecure = 'auth/send-otp-secure';
  static const String verifyOtpSecure = 'auth/verify-otp-secure';
}

class ApiKey {
  static String id = 'id';
  static String token = 'token';
  static String message = 'message';
  static String status = 'status';
  static String errormessage = 'ErrorMessage';
  static String name = 'name';
  static String storeName = 'storeName';
  static String tradeType = 'tradeType';
  static String city = 'city';
  static String address = 'address';
  static String email = 'email';
  static String password = 'password';
  static String confirmPassword = 'confirmPassword';
  static String phone = 'phone';
  static String profileImage = 'profileImage';
  static String imageDocument = 'imageDocument';
  static String verifyotpphone = 'verifyotpphone';
  static String verifyotpemail = 'otp_code';
  static String oldPassword = 'Old_password';
  static String newPassword = 'New_password';
  static String count = 'count';
  static String nameAddFayah = 'nameaddFayah';
  static String vehicle = 'vehicle';
  static String plate = 'plate';
}

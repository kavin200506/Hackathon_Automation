class AppConstants {
  // API Configuration
  static const String dynamicUrlEndpoint = 'https://server-url-chi.vercel.app/url';
  static const String defaultBaseUrl = 'http://localhost:8000';
  static const String apiBasePath = '/api/v1/events';
  static const int apiTimeout = 30000;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userTypeKey = 'user_type';
  static const String bypassAuthKey = 'BYPASS_AUTH';

  // User Types
  static const String userTypeStudent = 'student';
  static const String userTypeCollege = 'college';
  static const String userTypeDepartment = 'department';
  static const String userTypeAdmin = 'admin';

  // Routes
  static const String routeHome = '/';
  static const String routeStudentLogin = '/student/login';
  static const String routeStudentRegister = '/student/register';
  static const String routeStudentVerifyOtp = '/student/verify-otp';
  static const String routeStudentSetPassword = '/student/set-password';
  static const String routeStudentDashboard = '/student/dashboard';
  static const String routeStudentCreateTeam = '/student/create-team';
  static const String routeStudentMyTeams = '/student/my-teams';
  static const String routeStudentJoinHackathon = '/student/join-hackathon';
  static const String routeStudentTeamPayment = '/student/team-payment';
  static const String routeStudentAnnouncements = '/student/announcements';

  static const String routeCollegeLogin = '/college/login';
  static const String routeCollegeRegister = '/college/register';
  static const String routeCollegeVerifyOtp = '/college/verify-otp';
  static const String routeCollegeSetPassword = '/college/set-password';
  static const String routeCollegeDashboard = '/college/dashboard';
  static const String routeCollegeCreateDepartment = '/college/create-department';
  static const String routeCollegeViewDepartments = '/college/view-departments';
  static const String routeCollegeViewTeams = '/college/view-teams';

  static const String routeDepartmentLogin = '/department/login';
  static const String routeDepartmentDashboard = '/department/dashboard';
  static const String routeDepartmentViewTeams = '/department/view-teams';

  static const String routeAdminLogin = '/admin/login';
  static const String routeAdminDashboard = '/admin/dashboard';
  static const String routeAdminCreateHackathon = '/admin/create-hackathon';
  static const String routeAdminManageTopics = '/admin/manage-topics';
  static const String routeAdminManageAnnouncements = '/admin/manage-announcements';
  static const String routeAdminViewColleges = '/admin/view-colleges';
  static const String routeAdminViewTeams = '/admin/view-teams';
}







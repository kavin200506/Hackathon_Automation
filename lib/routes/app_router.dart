import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../screens/landing.dart';
import '../screens/student/student_login.dart';
import '../screens/student/student_register.dart';
import '../screens/student/student_otp_verification.dart';
import '../screens/student/student_set_password.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/student/create_team.dart';
import '../screens/student/my_teams.dart';
import '../screens/student/join_hackathon.dart';
import '../screens/student/team_payment.dart';
import '../screens/student/announcements.dart';
import '../screens/college/college_login.dart';
import '../screens/college/college_register.dart';
import '../screens/college/college_otp_verification.dart';
import '../screens/college/college_set_password.dart';
import '../screens/college/college_dashboard.dart';
import '../screens/college/create_department.dart';
import '../screens/college/view_departments.dart';
import '../screens/college/view_all_teams.dart';
import '../screens/department/department_login.dart';
import '../screens/department/department_dashboard.dart';
import '../screens/department/view_department_teams.dart';
import '../screens/admin/admin_login.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/create_hackathon.dart';
import '../screens/admin/manage_topics.dart';
import '../screens/admin/manage_announcements.dart';
import '../screens/admin/view_colleges.dart';
import '../screens/admin/view_all_teams.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: AppConstants.routeHome,
    redirect: (context, state) async {
      // If user opens app and has valid token + userType, redirect to their dashboard
      if (state.matchedLocation == AppConstants.routeHome) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConstants.accessTokenKey);
        final userType = prefs.getString(AppConstants.userTypeKey);

        if (token != null && userType != null) {
          switch (userType) {
            case AppConstants.userTypeStudent:
              return AppConstants.routeStudentDashboard;
            case AppConstants.userTypeCollege:
              return AppConstants.routeCollegeDashboard;
            case AppConstants.userTypeDepartment:
              return AppConstants.routeDepartmentDashboard;
            case AppConstants.userTypeAdmin:
              return AppConstants.routeAdminDashboard;
            default:
              return null; // Stay on landing if unknown userType
          }
        }
        return null; // No token, stay on landing
      }

      // Check protected routes
      final isProtected = _isProtectedRoute(state.matchedLocation);
      if (isProtected) {
        final allowedTypes = _getAllowedUserTypes(state.matchedLocation);
        return await _checkAuth(allowedTypes);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeHome,
        builder: (context, state) => const LandingScreen(),
      ),
      
      // Student Routes
      GoRoute(
        path: AppConstants.routeStudentLogin,
        builder: (context, state) => const StudentLoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeStudentRegister,
        builder: (context, state) => const StudentRegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.routeStudentVerifyOtp,
        builder: (context, state) => const StudentOTPVerificationScreen(),
      ),
      GoRoute(
        path: AppConstants.routeStudentSetPassword,
        builder: (context, state) => const StudentSetPasswordScreen(),
      ),
      GoRoute(
        path: AppConstants.routeStudentDashboard,
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.routeStudentCreateTeam,
        builder: (context, state) => const CreateTeamScreen(),
      ),
      GoRoute(
        path: AppConstants.routeStudentMyTeams,
        builder: (context, state) => const MyTeamsScreen(),
      ),
      GoRoute(
        path: AppConstants.routeStudentJoinHackathon,
        builder: (context, state) => const JoinHackathonScreen(),
      ),
      GoRoute(
        path: '${AppConstants.routeStudentTeamPayment}/:teamId',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId'] ?? '';
          return TeamPaymentScreen(teamId: teamId);
        },
      ),
      GoRoute(
        path: AppConstants.routeStudentAnnouncements,
        builder: (context, state) => const AnnouncementsScreen(),
      ),
      
      // College Routes
      GoRoute(
        path: AppConstants.routeCollegeLogin,
        builder: (context, state) => const CollegeLoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeCollegeRegister,
        builder: (context, state) => const CollegeRegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.routeCollegeVerifyOtp,
        builder: (context, state) => const CollegeOTPVerificationScreen(),
      ),
      GoRoute(
        path: AppConstants.routeCollegeSetPassword,
        builder: (context, state) => const CollegeSetPasswordScreen(),
      ),
      GoRoute(
        path: AppConstants.routeCollegeDashboard,
        builder: (context, state) => const CollegeDashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.routeCollegeCreateDepartment,
        builder: (context, state) => const CreateDepartmentScreen(),
      ),
      GoRoute(
        path: AppConstants.routeCollegeViewDepartments,
        builder: (context, state) => const ViewDepartmentsScreen(),
      ),
      GoRoute(
        path: AppConstants.routeCollegeViewTeams,
        builder: (context, state) => const ViewAllTeamsScreen(),
      ),
      
      // Department Routes
      GoRoute(
        path: AppConstants.routeDepartmentLogin,
        builder: (context, state) => const DepartmentLoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeDepartmentDashboard,
        builder: (context, state) => const DepartmentDashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.routeDepartmentViewTeams,
        builder: (context, state) => const ViewDepartmentTeamsScreen(),
      ),
      
      // Admin Routes
      GoRoute(
        path: AppConstants.routeAdminLogin,
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAdminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAdminCreateHackathon,
        builder: (context, state) => const CreateHackathonScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAdminManageTopics,
        builder: (context, state) => const ManageTopicsScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAdminManageAnnouncements,
        builder: (context, state) => const ManageAnnouncementsScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAdminViewColleges,
        builder: (context, state) => const ViewCollegesScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAdminViewTeams,
        builder: (context, state) => const AdminViewAllTeamsScreen(),
      ),
    ],
  );

  static bool _isProtectedRoute(String path) {
    final protectedPaths = [
      AppConstants.routeStudentDashboard,
      AppConstants.routeStudentCreateTeam,
      AppConstants.routeStudentMyTeams,
      AppConstants.routeStudentJoinHackathon,
      AppConstants.routeStudentTeamPayment,
      AppConstants.routeStudentAnnouncements,
      AppConstants.routeCollegeDashboard,
      AppConstants.routeCollegeCreateDepartment,
      AppConstants.routeCollegeViewDepartments,
      AppConstants.routeCollegeViewTeams,
      AppConstants.routeDepartmentDashboard,
      AppConstants.routeDepartmentViewTeams,
      AppConstants.routeAdminDashboard,
      AppConstants.routeAdminCreateHackathon,
      AppConstants.routeAdminManageTopics,
      AppConstants.routeAdminManageAnnouncements,
      AppConstants.routeAdminViewColleges,
      AppConstants.routeAdminViewTeams,
    ];
    return protectedPaths.any((p) => path.startsWith(p));
  }

  static List<String>? _getAllowedUserTypes(String path) {
    if (path.startsWith('/student/')) {
      return [AppConstants.userTypeStudent];
    } else if (path.startsWith('/college/')) {
      return [AppConstants.userTypeCollege];
    } else if (path.startsWith('/department/')) {
      return [AppConstants.userTypeDepartment];
    } else if (path.startsWith('/admin/')) {
      return [AppConstants.userTypeAdmin];
    }
    return null;
  }

  static Future<String?> _checkAuth(List<String>? allowedUserTypes) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.accessTokenKey);
    final userType = prefs.getString(AppConstants.userTypeKey);
    final bypass = prefs.getBool(AppConstants.bypassAuthKey) ?? false;

    if (bypass) {
      return null; // Allow access
    }

    if (token == null) {
      return AppConstants.routeHome; // Redirect to home
    }

    if (allowedUserTypes != null && !allowedUserTypes.contains(userType)) {
      return AppConstants.routeHome; // Redirect to home
    }

    return null; // Allow access
  }
}


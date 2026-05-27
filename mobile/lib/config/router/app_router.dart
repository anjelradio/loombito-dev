import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/config/router/app_router_notifier.dart';
import 'package:mobile/features/attendance/attendance.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/communications/communications.dart';
import 'package:mobile/features/evaluations/evaluations.dart';
import 'package:mobile/features/home/home.dart';
import 'package:mobile/features/intelligence/intelligence.dart';
import 'package:mobile/features/introduction/tutorial.dart';
import 'package:mobile/features/licenses/licenses.dart';
import 'package:mobile/features/schools/schools.dart';
import 'package:mobile/features/students/students.dart';

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.read(goRouterNotifierProvider);
  return GoRouter(
    initialLocation: '/check',
    refreshListenable: goRouterNotifier,
    routes: [
      // Checking auth
      GoRoute(
        path: '/check',
        builder: (context, state) => const CheckAuthStatusScreen(),
      ),

      // Home placeholder
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

      // Introduction
      GoRoute(
        path: '/introduction',
        builder: (context, state) => const AppIntroductionScreen(),
      ),

      // Auth Routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile/personal-data',
        builder: (context, state) => const PersonalDataScreen(),
      ),
      GoRoute(
        path: '/join/school-code',
        builder: (context, state) => const JoinSchoolCodeScreen(),
      ),
      GoRoute(
        path: '/join/student-code',
        builder: (context, state) => const JoinStudentCodeScreen(),
      ),
      GoRoute(
        path: '/schools/:schoolId/home',
        builder: (context, state) {
          final schoolId = state.pathParameters['schoolId'] ?? '';
          return SchoolHomeScreen(schoolId: schoolId);
        },
      ),
      GoRoute(
        path: '/schools/:schoolId/teacher/evaluaciones/:assignmentId',
        builder: (context, state) {
          final schoolId = state.pathParameters['schoolId'] ?? '';
          final assignmentId = state.pathParameters['assignmentId'] ?? '';
          return AssignmentEvaluationsScreen(
            schoolId: schoolId,
            assignmentId: assignmentId,
          );
        },
      ),
      GoRoute(
        path: '/schools/:schoolId/teacher/evaluar/:evaluationId',
        builder: (context, state) {
          final schoolId = state.pathParameters['schoolId'] ?? '';
          final evaluationId = state.pathParameters['evaluationId'] ?? '';
          return EvaluateEvaluationScreen(
            schoolId: schoolId,
            evaluationId: evaluationId,
          );
        },
      ),
      GoRoute(
        path: '/schools/:schoolId/teacher/asistencias/:assignmentId',
        builder: (context, state) {
          final schoolId = state.pathParameters['schoolId'] ?? '';
          final assignmentId = state.pathParameters['assignmentId'] ?? '';
          return AssignmentAttendanceScreen(
            schoolId: schoolId,
            assignmentId: assignmentId,
          );
        },
      ),
      GoRoute(
        path: '/schools/:schoolId/teacher/asistir/:sessionId',
        builder: (context, state) {
          final schoolId = state.pathParameters['schoolId'] ?? '';
          final sessionId = state.pathParameters['sessionId'] ?? '';
          return AttendanceSessionDetailScreen(
            schoolId: schoolId,
            sessionId: sessionId,
          );
        },
      ),
      GoRoute(
        path: '/schools/:schoolId/teacher/promedios/:assignmentId',
        builder: (context, state) {
          final schoolId = state.pathParameters['schoolId'] ?? '';
          final assignmentId = state.pathParameters['assignmentId'] ?? '';
          return TermAveragesScreen(
            schoolId: schoolId,
            assignmentId: assignmentId,
          );
        },
      ),
      GoRoute(
        path: '/schools/:schoolId/teacher/clasificacion/:assignmentId',
        builder: (context, state) {
          final schoolId = state.pathParameters['schoolId'] ?? '';
          final assignmentId = state.pathParameters['assignmentId'] ?? '';
          return StudentClassificationScreen(
            schoolId: schoolId,
            assignmentId: assignmentId,
          );
        },
      ),
      GoRoute(
        path: '/schools/:schoolId/teacher/comunicados/:courseId/:studentId',
        builder: (context, state) {
          final schoolId = state.pathParameters['schoolId'] ?? '';
          final courseId = state.pathParameters['courseId'] ?? '';
          final studentId = state.pathParameters['studentId'] ?? '';
          final payload = state.extra;
          final extras = payload is Map<String, dynamic> ? payload : null;

          return StudentCommunicationsScreen(
            schoolId: schoolId,
            courseId: courseId,
            studentId: studentId,
            courseName: extras?['courseName']?.toString(),
            studentName: extras?['studentName']?.toString(),
          );
        },
      ),
      GoRoute(
        path: '/communications/notifications',
        builder: (context, state) => const NotificationsInboxScreen(),
      ),
      GoRoute(
        path: '/schools/:schoolId/students/:studentId/licenses',
        builder: (context, state) {
          final schoolId = state.pathParameters['schoolId'] ?? '';
          final studentId = state.pathParameters['studentId'] ?? '';
          final payload = state.extra;
          final extras = payload is Map<String, dynamic> ? payload : null;

          return StudentLicensesScreen(
            schoolId: schoolId,
            studentId: studentId,
            studentName: extras?['studentName']?.toString(),
          );
        },
      ),
    ],
    redirect: (context, state) {
      final isGoingTo = state.matchedLocation;
      final authStatus = goRouterNotifier.authStatus;

      if (authStatus == AuthStatus.checking) {
        return isGoingTo == '/check' ? null : '/check';
      }

      if (authStatus == AuthStatus.notAuthenticated) {
        if (isGoingTo == '/login' ||
            isGoingTo == '/register' ||
            isGoingTo == '/introduction') {
          return null;
        }
        return '/login';
      }

      if (authStatus == AuthStatus.authenticated) {
        if (isGoingTo == '/login' ||
            isGoingTo == '/register' ||
            isGoingTo == '/check' ||
            isGoingTo == '/introduction') {
          return '/';
        }
      }
      return null;
    },
  );
});

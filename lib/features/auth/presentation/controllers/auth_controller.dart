import 'package:get/get.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../data/datasources/firebase_auth_service.dart';

/// Authentication Controller using GetX
/// Manages authentication state and operations
class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final FirebaseAuthService authService;

  AuthController({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.googleSignInUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.authService,
  });

  // Observable state
  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initAuthStateListener();
    _loadCurrentUser();
  }

  /// Initialize authentication state listener
  void _initAuthStateListener() {
    authService.authStateChanges.listen((user) {
      currentUser.value = user;
      isAuthenticated.value = user != null;
      Logger.log('Auth state changed: ${user?.email ?? "null"}', tag: 'AUTH_CONTROLLER');
    });
  }

  /// Load current user on initialization
  Future<void> _loadCurrentUser() async {
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) {
        Logger.error('Failed to load current user: ${failure.message}', tag: 'AUTH_CONTROLLER');
        currentUser.value = null;
        isAuthenticated.value = false;
      },
      (user) {
        currentUser.value = user;
        isAuthenticated.value = user != null;
      },
    );
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await loginUseCase(
        email: email.trim(),
        password: password,
      );

      return result.fold(
        (failure) {
          errorMessage.value = failure.message;
          Logger.error('Sign in failed: ${failure.message}', tag: 'AUTH_CONTROLLER');
          Get.snackbar(
            'Sign In Failed',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        },
        (user) {
          currentUser.value = user;
          isAuthenticated.value = true;
          Logger.success('User signed in: ${user.email}', tag: 'AUTH_CONTROLLER');
          Get.snackbar(
            'Welcome Back!',
            'Signed in as ${user.email}',
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await signUpUseCase(
        email: email.trim(),
        password: password,
        displayName: displayName.trim(),
      );

      return result.fold(
        (failure) {
          errorMessage.value = failure.message;
          Logger.error('Sign up failed: ${failure.message}', tag: 'AUTH_CONTROLLER');
          Get.snackbar(
            'Sign Up Failed',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        },
        (user) {
          currentUser.value = user;
          isAuthenticated.value = true;
          Logger.success('User signed up: ${user.email}', tag: 'AUTH_CONTROLLER');
          Get.snackbar(
            'Welcome!',
            'Account created successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await googleSignInUseCase();

      return result.fold(
        (failure) {
          errorMessage.value = failure.message;
          Logger.error('Google sign in failed: ${failure.message}', tag: 'AUTH_CONTROLLER');
          Get.snackbar(
            'Google Sign In Failed',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        },
        (user) {
          currentUser.value = user;
          isAuthenticated.value = true;
          Logger.success('User signed in with Google: ${user.email}', tag: 'AUTH_CONTROLLER');
          Get.snackbar(
            'Welcome!',
            'Signed in with Google',
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await logoutUseCase();

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          Logger.error('Sign out failed: ${failure.message}', tag: 'AUTH_CONTROLLER');
          Get.snackbar(
            'Sign Out Failed',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (_) {
          currentUser.value = null;
          isAuthenticated.value = false;
          Logger.success('User signed out', tag: 'AUTH_CONTROLLER');
          Get.snackbar(
            'Signed Out',
            'You have been signed out successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}

import 'package:get/get.dart';
import 'data/datasources/firebase_auth_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'domain/usecases/google_signin_usecase.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/signup_usecase.dart';
import 'presentation/controllers/auth_controller.dart';

/// Authentication Bindings
/// Sets up dependency injection for auth module
class AuthBindings extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<FirebaseAuthService>(
      () => FirebaseAuthService(),
      fenix: true,
    );

    // Repositories
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        authService: Get.find<FirebaseAuthService>(),
      ),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut<LoginUseCase>(
      () => LoginUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<SignUpUseCase>(
      () => SignUpUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<GoogleSignInUseCase>(
      () => GoogleSignInUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<LogoutUseCase>(
      () => LogoutUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(Get.find<AuthRepository>()),
    );

    // Controllers
    Get.lazyPut<AuthController>(
      () => AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        signUpUseCase: Get.find<SignUpUseCase>(),
        googleSignInUseCase: Get.find<GoogleSignInUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
        authService: Get.find<FirebaseAuthService>(),
      ),
      fenix: true,
    );
  }
}

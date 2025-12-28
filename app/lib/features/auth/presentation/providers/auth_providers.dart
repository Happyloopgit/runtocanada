import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import '../../domain/models/user_model.dart';

/// Provider for AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for Firebase Auth state changes
/// Returns null when user is not authenticated
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for current user profile
/// Returns null when user is not authenticated or profile doesn't exist
final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final authService = ref.watch(authServiceProvider);

  await for (final user in authService.authStateChanges) {
    if (user == null) {
      yield null;
    } else {
      try {
        final userModel = await authService.getUserProfile(user.uid);
        yield userModel;
      } catch (e) {
        // Log error but don't crash the app
        yield null;
      }
    }
  }
});

/// Auth controller state
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  /// Clear all messages
  AuthState clearMessages() {
    return AuthState(
      isLoading: isLoading,
    );
  }
}

/// Auth controller for handling authentication actions
class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(AuthState());

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
      );

      state = AuthState(
        isLoading: false,
        successMessage: 'Account created successfully! Welcome to Run to Canada.',
      );
      return true;
    } on AuthException catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = AuthState(
        isLoading: false,
        successMessage: 'Welcome back!',
      );
      return true;
    } on AuthException catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.signInWithGoogle();

      state = AuthState(
        isLoading: false,
        successMessage: 'Welcome!',
      );
      return true;
    } on AuthException catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.signOut();
      state = AuthState(
        isLoading: false,
        successMessage: 'Signed out successfully',
      );
    } on AuthException catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: 'Failed to sign out. Please try again.',
      );
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.sendPasswordResetEmail(email);
      state = AuthState(
        isLoading: false,
        successMessage: 'Password reset email sent! Please check your inbox.',
      );
      return true;
    } on AuthException catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: 'Failed to send password reset email. Please try again.',
      );
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UserModel user) async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.updateUserProfile(user);
      state = AuthState(
        isLoading: false,
        successMessage: 'Profile updated successfully',
      );
      return true;
    } on AuthException catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: 'Failed to update profile. Please try again.',
      );
      return false;
    }
  }

  /// Update user settings
  Future<bool> updateSettings(String uid, UserSettings settings) async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.updateUserSettings(uid, settings);
      state = AuthState(
        isLoading: false,
        successMessage: 'Settings updated successfully',
      );
      return true;
    } on AuthException catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: 'Failed to update settings. Please try again.',
      );
      return false;
    }
  }

  /// Clear messages (error and success)
  void clearMessages() {
    state = state.clearMessages();
  }
}

/// Provider for AuthController
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});

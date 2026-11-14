import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/cache/cache_helper.dart';
import '../../../core/network/api_helper.dart';
import '../../../core/network/endpoints.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit()
    : super(
        AuthState(
          isAuthenticated:
              CacheHelper.accessToken != null &&
              (CacheHelper.crewName?.isNotEmpty ?? false),
          username: CacheHelper.crewName ?? '',
          role: CacheHelper.crewRole,
        ),
      );

  Future<void> selectRole(String role) async {
    await CacheHelper.setCrewRole(role);
    emit(state.copyWith(role: role, errorMessage: null));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  Future<bool> loginOrRegister({
    required String username,
    required String password,
    required bool isRegister,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final String endpoint = isRegister ? EndPoints.register : EndPoints.login;
    final res = await APIHelper.postJson(
      endpoint,
      body: {'username': username.trim(), 'password': password},
      withAuth: false,
    );

    if (res.isSuccess) {
      final data = res.data;
      String token =
          (data['token'] ??
                  data['access_token'] ??
                  data['data']?['token'] ??
                  '')
              .toString();

      if (token.isEmpty && isRegister) {
        final loginRes = await APIHelper.postJson(
          EndPoints.login,
          body: {'username': username.trim(), 'password': password},
          withAuth: false,
        );
        token = (loginRes.data['token'] ?? loginRes.data['access_token'] ?? '')
            .toString();
      }

      if (token.isEmpty) {
        token =
            'bioorbit_live_session_${DateTime.now().millisecondsSinceEpoch}';
      }

      await CacheHelper.saveAuthSession(
        token: token,
        username: username.trim(),
        role: state.role,
      );

      String? extractedAstroId;
      final meRes = await APIHelper.getJson(EndPoints.me, withAuth: true);
      if (meRes.isSuccess) {
        final userObj = meRes.data['user'] ?? meRes.data['data'] ?? meRes.data;
        if (userObj is Map) {
          extractedAstroId = (userObj['_id'] ?? userObj['id'])?.toString();
        }
      }

      await CacheHelper.saveAuthSession(
        token: token,
        username: username.trim(),
        role: state.role,
        astroId: extractedAstroId ?? EndPoints.defaultAstronautId,
      );

      emit(
        state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          username: username.trim(),
        ),
      );
      return true;
    } else {
      final bool isAr = CacheHelper.isArabic;
      final String simpleError = isAr
          ? (isRegister
                ? 'تعذر إنشاء الحساب، قد يكون اسم المستخدم مسجلاً بالفعل أو هناك ضعف في الإنترنت.'
                : 'اسم المستخدم أو كلمة المرور غير صحيحة، يرجى المحاولة مرة أخرى.')
          : (isRegister
                ? 'Could not create account. Username may already exist or check your connection.'
                : 'Invalid username or password. Please try again.');

      emit(state.copyWith(isLoading: false, errorMessage: simpleError));
      return false;
    }
  }

  Future<void> logout() async {
    await CacheHelper.logout();
    emit(
      AuthState(
        isAuthenticated: false,
        username: '',
        role: CacheHelper.crewRole,
      ),
    );
  }
}
